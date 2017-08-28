from py2neo import Graph
import csv
import codecs
import sys


def to_val(v):
  if isinstance(v, basestring):
    # print v
    return u'"' + v + u'"'
  elif isinstance(v, list):
    return u'[' + u', '.join(map(to_val, v)) + u']'
  else:
    return str(v)


def add_list_string(strlist, l):
  strlist.append(to_val(l))


def add_on_create_property_string(strlist, properties):
  if len(properties) < 0:
    return
  strlist.append(u" ON CREATE SET ")

  def convert(key, value):
    return u'el.{0}={1}'.format(key, to_val(value))

  strlist.append(u', '.join([convert(r, v) for r, v in properties.iteritems()]))


def add_on_match_property_string(strlist, properties):
  if len(properties) < 0:
    return

  def to_update_val(k, v):
    if isinstance(v, list):
      return u'CASE WHEN NOT (HAS (el.{0})) THEN {1} ELSE el.{0} + {1} END'.format(k, to_val(v))
    return to_val(v)

  def convert(key, value):
    return u'el.{0}={1}'.format(key, to_update_val(key, value))

  strlist.append(u" SET ")
  strlist.append(u', '.join([convert(r, v) for r, v in properties.iteritems()]))


def create_node_query(labels, node_id, properties):
  strlist = [u'MERGE (el:{0} {{id:"{1}" }}) '.format(u':'.join(labels), node_id)]
  add_on_create_property_string(strlist, properties)
  if len(properties) > 0:
    strlist.append(u" ON MATCH ")
    add_on_match_property_string(strlist, properties)
  return u"".join(strlist)


def create_edge_query(type, source_node_id, target_node_id, properties, source_type='_Network_Node', update_only=False):
  merge = u"""MATCH (source:{0} {{id:"{1}"}})
  MATCH (target:_Network_Node {{id:"{2}"}})
  MERGE (source)-[el:{3}]->(target) """.format(source_type, source_node_id, target_node_id, type)
  update = u'MATCH (source:{0} {{id:"{1}"}})-[el:{3}]->(target:_Network_Node {{id:"{2}"}}) '.format(source_node_id, target_node_id, type)
  strlist = [merge if not update_only else update]

  if len(properties) > 0:
    if not update_only:
      add_on_create_property_string(strlist, properties)
      strlist.append(u" ON MATCH ")
    add_on_match_property_string(strlist, properties)
  return u"".join(strlist)


def add_node(tx, labels, node_id, properties):
  tx.append(create_node_query(labels, node_id, properties))


def add_edge(tx, type, source_node_id, target_node_id, properties, source_type=u'_Network_Node', update_only=False):
  q = create_edge_query(type, source_node_id, target_node_id, properties, source_type, update_only)
  tx.append(q)


class GraphImporter(object):
  def __init__(self, graphurl, commit_every=100):
    self.graph = Graph(graphurl)
    self.commit_every = commit_every
    self._act = None
    self._actC = commit_every

  def delete_all(self):
    self.graph.delete_all()
    self.graph.cypher.run('CREATE INDEX ON :_Network_Node(id)')
    self.graph.cypher.run('CREATE INDEX ON :_Set_Node(id)')

  def _tx(self):
    if self._act is not None:
      return self._act
    self._act = self.graph.cypher.begin()
    self._actC = self.commit_every
    return self._act

  def _done(self):
    self._actC -= 1
    if self._actC == 0:  # commit
      self._act.process()
      self._act.commit()
      sys.stdout.write('.')
      self._act = None

  def _close(self):
    if self._act is not None:  # commit last tx
      self._actC = 1
      self._done()

  def add_node(self, labels, node_id, properties):
    tx = self._tx()
    add_node(tx, labels, node_id, properties)
    self._done()

  def done_nodes(self):
    self._done()

  def append(self, query):
    tx = self._tx()
    tx.append(query)
    self._done()

  def add_edge(self, label, source_node_id, target_node_id, properties, source_type=u'_Network_Node',
               update_only=False):
    tx = self._tx()
    add_edge(tx, label, source_node_id, target_node_id, properties, source_type, update_only)
    self._done()

  def __call__(self, query):
    tx = self._tx()
    tx.append(query)
    self._done()

  def finish(self):
    self._close()


class UTF8Recoder:
  """
  Iterator
  that
  reads
  an
  encoded
  stream and reencodes
  the
  input
  to
  UTF - 8
  """

  def __init__(self, f, encoding):
    self.reader = codecs.getreader(encoding)(f)

  def __iter__(self):
    return self

  def next(self):
    return self.reader.next().encode("utf-8")


class UnicodeReader:
  """
  A
  CSV
  reader
  which
  will
  iterate
  over
  lines in the
  CSV
  file
  "f",
  which is encoded in the
  given
  encoding.
  """

  def __init__(self, f, dialect=csv.excel, encoding="utf-8", **kwds):
    f = UTF8Recoder(f, encoding)
    self.reader = csv.reader(f, dialect=dialect, **kwds)

  def next(self):
    row = self.reader.next()
    return [unicode(s, "utf-8") for s in row]

  def __iter__(self):
    return self
