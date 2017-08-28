import httplib
import urllib
import json
from py2neo import Graph
from phovea_server.ns import Namespace, request, Response, jsonify
from flask import g
from phovea_server.config import view as configview, get as configget
import phovea_server.websocket as ws
import phovea_server.util as utils
import memcache
import logging

_log = logging.getLogger(__name__)
c = configview('pathfinder_graph')

app = Namespace(__name__)
websocket = ws.Socket(app)
mc = memcache.Client([c.memcached], debug=0)

mc_prefix = 'pathways_'


class Config(object):
  def __init__(self, id, sett):
    self.id = id
    self.raw = sett
    self.port = sett.get('port', c.port)
    self.host = sett.get('host', c.host)
    self.url = sett.get('url', 'http://' + self.host + ':' + str(self.port))

    self.node_label = sett.get('node_label', '_Network_Node')
    self.node_id = sett.get('node_id', 'id')
    self.set_label = sett.get('set_label', '_Set_Node')

    self.directions = sett.get('directions',
                               dict(Edge='out', ConsistsOfEdge='both'))  # both ConsistsOf for the reversal
    self.directions_neighbor = sett.get('directions_neighbor', self.directions)  # both ConsistsOf for the reversal
    # by default inline ConsistsOfEdges
    self.inline = sett.get('inline', dict(inline='ConsistsOfEdge', undirectional=False, flag='_isSetEdge',
                                          aggregate=dict(pathways='pathways'), toaggregate='id', type='Edge'))

    self.client_conf = sett.get('client')


def find_use_case(uc):
  base = c.uc.get(uc, None)
  if base is not None:
    return base
  # check extension configs
  view = configget('pathfinder_graph_' + uc)
  return view


def update_config(args):
  uc = args.get('uc', 'dblp')
  # print args, uc
  # store in request context
  g.config = Config(uc, find_use_case(uc))


@app.before_request
def resolve_usecase():
  # print 'before'
  update_config(request.args)


def resolve_db(config=None):
  if config is None:
    config = g.config
  graph = Graph(config.url + '/db/data/')
  return graph


@app.route('/config.json')
def get_config():
  return jsonify(g.config.client_conf)


def lookup_gene_id(dss, node):
  labels = map(str, node.labels())
  for ds in dss:
    for n in ds['mapping_nodes']:
      if n['node_label'] in labels:
        return node.properties[n['id_property']]
  return None


def add_datasets(prop, node):
  if 'datasets' not in g.config.client_conf:
    return
  import pathfinder_ccle.ccle as ccle
  gene_id = lookup_gene_id(g.config.client_conf['datasets'], node)
  if gene_id:
    data = ccle.boxplot_api2(gene_id)
    for k, v in data.iteritems():
      prop[k] = v


def preform_search(s, limit=20, label=None, prop='name'):
  """ performs a search for a given search query
  :param s:
  :param limit: maximal number of results
  :return:
  """
  if label is None:
    label = g.config.node_label

  if len(s) < 2:  # too short search query
    return []

  import re
  # convert to reqex expression
  s = '.*' + re.escape(s.lower()).replace('\\', '\\\\') + '.*'

  graph = resolve_db()

  query = """
  MATCH (n:{0}) WHERE n.{1} =~ "(?i){2}"
  RETURN id(n) as id, n.{1} as name, n.{4} as nid, labels(n) as labels
  ORDER BY n.{1} LIMIT {3}""".format(label, prop, s, limit, g.config.node_id)

  _log.debug('search query: %s', query)

  records = graph.run(query)

  def convert(result):
    return dict(value=result['id'], label=result['name'], id=result['nid'], labels=result['labels'])

  return [convert(r) for r in records]


@app.route('/search')
def find_node():
  s = request.args.get('q', '')
  limit = request.args.get('limit', 20)
  label = request.args.get('label', g.config.node_label)
  prop = request.args.get('prop', 'name')

  results = preform_search(s, limit, label, prop)

  return jsonify(q=s, linit=limit, label=label, prop=prop, results=results)


def parse_incremental_json(text, on_chunk):
  """
  an incremental json parser, assumes a data stream like: [{...},{...},...]
  :param text: text to parse
  :param on_chunk: callback to call when a chunk was found
  :return: the not yet parsed text
  """
  act = 0
  open_braces = 0
  l = len(text)

  if l > 0 and (text[act] == '[' or text[act] == ','):  # skip initial:
    act = 1

  start = act

  while act < l:
    c = text[act]
    if c == '{':  # starting object
      open_braces += 1
    elif c == '}':  # end object
      open_braces -= 1
      if open_braces == 0:  # at the root
        on_chunk(json.loads(text[start:act + 1]))
        start = act + 1
        act += 1
        if act < l and text[act] == ',':  # skip separator
          start += 1
          act += 1
    act += 1
  if start == 0:
    return text
  return text[start:]


class SocketTask(object):
  def __init__(self, socket_ns):
    self.socket_ns = socket_ns

  def send_impl(self, t, msg):
    # print 'send'+t+str(msg)
    d = json.dumps(dict(type=t, data=msg))
    self.socket_ns.send(d)

  def send_str(self, t, s):
    d = '{ "type": "' + t + '", "data": ' + s + '}'
    self.socket_ns.send(d)


class NodeAsyncTask(SocketTask):
  def __init__(self, q, socket_ns, config):
    super(NodeAsyncTask, self).__init__(socket_ns)
    self.q = q
    self.conn = httplib.HTTPConnection(config.host, config.port)
    from threading import Event
    self.config = config
    self.shutdown = Event()
    self._sent_nodes = set()
    self._sent_relationships = set()
    self._graph = resolve_db()

  def abort(self):
    if self.shutdown.isSet():
      return
    self.conn.close()
    self.shutdown.set()

  def send_incremental(self, path):
    pass

  def send_start(self):
    pass

  def send_done(self):
    pass

  def send_node(self, node, **kwargs):
    nid = node['id']
    if nid in self._sent_nodes:
      return  # already sent during this query
    _log.debug('send_node ' + str(nid))
    key = mc_prefix + self.config.id + '_n' + str(nid)
    sobj = mc.get(key)
    obj = None
    if not sobj:
      try:
        gnode = self._graph.node(nid)
        props = gnode.properties.copy()
        add_datasets(props, gnode)
        obj = dict(id=nid, labels=map(str, gnode.labels()), properties=props)
      except ValueError:
        obj = node
      sobj = utils.to_json(obj)
      mc.set(key, sobj)

    if len(kwargs) > 0:
      if obj is None:
        obj = json.loads(sobj)
      # we have additional stuff to transfer use a custom one
      for k, v in kwargs.iteritems():
        obj[k] = v
      sobj = utils.to_json(obj)

    self.send_str('new_node', sobj)
    self._sent_nodes.add(nid)

  def send_relationship(self, rel):
    rid = rel['id']
    if rid < 0:  # its a fake one
      return
    if rid in self._sent_relationships:
      return  # already sent during this query
    _log.debug('send_relationship ' + str(rid))
    key = mc_prefix + self.config.id + '_r' + str(rid)
    obj = mc.get(key)
    if not obj:
      obj = rel.copy()
      try:
        grel = self._graph.relationship(rid)
        obj['properties'] = grel.properties
      except ValueError:  # ignore not found ones
        pass
      except IndexError:  # ignore not found ones
        pass
      obj = json.dumps(obj)
      mc.set(key, obj)
    self.send_str('new_relationship', obj)
    self._sent_relationships.add(rid)

  def to_url(self, args):
    return '/caleydo/kShortestPaths/?{0}'.format(args)

  def run(self):
    headers = {'Content-type': 'application/json', 'Accept': 'application/json'}
    args = {k: json.dumps(v) if isinstance(v, dict) else v for k, v in self.q.iteritems()}
    _log.debug(args)
    args = urllib.urlencode(args)
    url = self.to_url(args)
    _log.debug(url)
    body = ''
    self.conn.request('GET', url, body, headers)
    self.send_start()
    self.stream()

  def stream(self):
    response = self.conn.getresponse()
    if self.shutdown.isSet():
      _log.info('aborted early')
      return
    content_length = int(response.getheader('Content-Length', '0'))
    _log.debug('waiting for response: ' + str(content_length))
    # Read data until we've read Content-Length bytes or the socket is closed
    l = 0
    data = ''
    while not self.shutdown.isSet() and (l < content_length or content_length == 0):
      s = response.read(4)  # read at most 32 byte
      if not s or self.shutdown.isSet():
        break
      data += s
      l += len(s)
      data = parse_incremental_json(data, self.send_incremental)

    if self.shutdown.isSet():
      _log.debug('aborted')
      return

    parse_incremental_json(data, self.send_incremental)
    # print response.status, response.reason
    # data = response.read()
    self.send_done()

    self.conn.close()
    self.shutdown.set()
    _log.debug('end')


class Query(NodeAsyncTask):
  def __init__(self, q, socket_ns, config):
    super(Query, self).__init__(q, socket_ns, config)
    self.paths = []

  def send_incremental(self, path):
    if self.shutdown.isSet():
      return
    self.paths.append(path)
    # check for all nodes in the path and load and send their missing data
    for n in path['nodes']:
      self.send_node(n)
    for e in path['edges']:
      self.send_relationship(e)
    _log.debug('sending paths %d', len(self.paths))
    self.send_impl('query_path', dict(query=self.q, path=path, i=len(self.paths)))

  def send_start(self):
    self.send_impl('query_start', dict(query=self.q))

  def send_done(self):
    _log.debug('sending done %d paths', len(self.paths))
    self.send_impl('query_done', dict(query=self.q))  # ,paths=self.paths))

  def to_url(self, args):
    return '/caleydo/kShortestPaths/?{0}'.format(args)


class Neighbors(NodeAsyncTask):
  def __init__(self, q, tag, socket_ws, config):
    super(Neighbors, self).__init__(q, socket_ws, config)
    self.node = q['node']
    self.tag = tag
    self.neighbors = []

  def send_incremental(self, neighbor):
    if self.shutdown.isSet():
      return
    self.neighbors.append(neighbor)
    edge = neighbor['_edge']
    self.send_node(neighbor)
    self.send_relationship(edge)
    _log.debug('sending %d neighbors', len(self.neighbors))
    self.send_impl('neighbor_neighbor',
                   dict(node=self.node, tag=self.tag, neighbor=neighbor, edge=edge, i=len(self.neighbors)))

  def send_start(self):
    self.send_impl('neighbor_start', dict(node=self.node, tag=self.tag))

  def send_done(self):
    _log.debug('sending %d neighbors done', len(self.neighbors))
    self.send_impl('neighbor_done', dict(node=self.node, tag=self.tag, neighbors=self.neighbors))  # ,paths=self.paths))

  def to_url(self, args):
    return '/caleydo/kShortestPaths/neighborsOf/{0}?{1}'.format(str(self.node), args)


class Find(NodeAsyncTask):
  def __init__(self, q, socket_ws, config):
    super(Find, self).__init__(q, socket_ws, config)
    self.matches = []

  def send_incremental(self, found):
    if self.shutdown.isSet():
      return
    self.matches.append(found)
    self.send_node(found)
    _log.debug('sending %d matches', len(self.matches))
    self.send_impl('found', dict(node=found, i=len(self.matches)))

  def send_start(self):
    self.send_impl('found_start', dict())

  def send_done(self):
    _log.debug('sending %d matches done', len(self.matches))
    self.send_impl('found_done', dict(matches=self.matches))  # ,paths=self.paths))

  def to_url(self, args):
    return '/caleydo/kShortestPaths/find?{0}'.format(args)


current_query = None


@websocket.route('/query')
def websocket_query(ws):
  global current_query
  while True:
    msg = ws.receive()
    if msg is None:
      continue
    _log.debug(msg)
    data = json.loads(msg)
    t = data['type']
    payload = data['data']

    update_config(payload)

    if current_query is not None:
      current_query.abort()
    if t == 'query':
      current_query = Query(to_query(payload), ws, g.config)
    elif t == 'neighbor':
      current_query = Neighbors(to_neighbors_query(payload), payload.get('tag', None), ws, g.config)
    elif t == 'find':
      current_query = Find(to_find_query(payload), ws, g.config)
    current_query.run()


def to_query(msg):
  """
  converts the given message to kShortestPath query arguments
  :param msg:
  :return:
  """
  k = msg.get('k', 1)  # number of paths
  max_depth = msg.get('maxDepth', 10)  # max length
  just_network = msg.get('just_network_edges', False)
  q = msg['query']
  _log.debug(q)

  args = dict(k=k, maxDepth=max_depth)

  min_length = msg.get('minLength', 0)
  if min_length > 0:
    args['minLength'] = min_length

  constraint = {'context': 'node', '$contains': g.config.node_label}

  # TODO generate from config
  directions = dict(g.config.directions)
  inline = g.config.inline

  if q is not None:
    constraint = {'$and': [constraint, q]}

  if inline:
    args['constraints'] = dict(c=constraint, dir=directions, inline=inline, acyclic=True)
    if just_network:
      del directions[inline['inline']]
      c = args['constraints']
      del c['inline']
  else:
    args['constraints'] = dict(c=constraint, dir=directions, acyclic=True)

  return args


def to_neighbors_query(msg):
  """
  based on the message converts to kShortestPaths args
  :param msg: the incoming message, supporting 'just_network_edges' and 'node' attribute
  :return:
  """
  just_network = msg.get('just_network_edges', False)
  node = int(msg.get('node'))
  args = dict(node=node)
  # TODO generate from config
  directions = dict(g.config.directions_neighbor)
  inline = g.config.inline
  if inline:
    args['constraints'] = dict(dir=directions, inline=inline, acyclic=True)
    if just_network:
      del directions[inline['inline']]
      c = args['constraints']
      del c['inline']
  else:
    args['constraints'] = dict(dir=directions, acyclic=True)

  return args


def to_find_query(msg):
  k = msg.get('k', 1)  # number of paths
  q = msg['query']

  args = dict(k=k)

  min_length = msg.get('minLength', 0)
  if min_length > 0:
    args['minLength'] = min_length

  constraint = {'context': 'node', '$contains': g.config.node_label}

  if q is not None:
    constraint = {'$and': [constraint, q]}

  args['constraints'] = dict(c=constraint)
  return args


@app.route("/summary")
def get_graph_summary():
  """
  api for getting a graph summary (nodes, edge, set count)
  :return:
  """
  graph = resolve_db()

  def compute():
    query = 'MATCH (n:{0}) RETURN COUNT(n) AS nodes'.format(g.config.node_label)
    records = graph.data(query)
    num_nodes = records[0]['nodes']

    query = 'MATCH (n1:{0})-[e]->(n2:{0}) RETURN COUNT(e) AS edges'.format(g.config.node_label)
    records = graph.data(query)
    num_edges = records[0]['edges']

    query = 'MATCH (n:{0}) RETURN COUNT(n) AS sets'.format(g.config.set_label)
    records = graph.data(query)
    num_sets = records[0]['sets']

    yield json.dumps(dict(Nodes=num_nodes, Edges=num_edges, Sets=num_sets))

  return Response(compute(), mimetype='application/json')


def create_get_sets_query(sets, config):
  # convert to query form
  set_queries = ['"{0}"'.format(s) for s in sets]

  # create the query
  return 'MATCH (n:{1}) WHERE n.{2} in [{0}] RETURN n, n.{2} as id, id(n) as uid'.format(', '.join(set_queries),
                                                                                         config.set_label, config.node_id)


@app.route('/setinfo')
def get_set_info():
  """
  delivers set information for a given list of set ids
  :return:
  """
  sets = request.args.getlist('sets[]')
  # print sets
  if len(sets) == 0:
    return jsonify()

  config = g.config

  def to_key(s):
    return mc_prefix + config.id + 'setinfo' + '_' + s

  def compute():
    response = dict()
    to_query = []
    for s in sets:
      obj = mc.get(to_key(s))
      if obj:
        response[s] = obj
      else:
        to_query.append(s)
    if len(to_query) >= 0:  # all cached
      graph = resolve_db(config)
      query = create_get_sets_query(to_query, config)
      records = graph.run(query)

      for record in records:
        node = record['n']
        obj = json.dumps(dict(id=record['uid'], labels=map(str, node.labels()), properties=node.properties))
        # cache for next time
        mc.set(to_key(record['id']), obj)
        response[record['id']] = obj

    # print 'sent setinfo for ',sets
    # manually create combined version avoiding partial json loads
    yield '{' + ','.join(('"' + k + '": ' + v for k, v in response.iteritems())) + '}'

  return Response(compute(), mimetype='application/json')


def create():
  """
   entry point of this plugin
  """
  return app


if __name__ == '__main__':
  app.debug = True
  app.run(host='0.0.0.0')
