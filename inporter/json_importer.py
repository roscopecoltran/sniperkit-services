import os
from os.path import join
from py2neo import Graph
import json
from import_utils import add_node, add_edge
import itertools

datapath = '/vagrant_data/'

graph = Graph("http://127.0.0.1:7475/db/data/")
graph.delete_all()

graph.cypher.run("CREATE INDEX ON :_Network_Node(id)")


def importfile(file):
  with open(file, 'r') as f:
    g = json.load(f)
  tx = graph.cypher.begin()

  for key, node in g['nodes'].iteritems():
    id = key
    targetclass = node['targetclass']
    geneids = node['geneids']
    color = node['color']
    label = node['label']
    add_node(tx, ['_Network_Node'], id,
             dict(idType=targetclass, color=color, name=label, geneids=geneids, pathways=[targetclass]))

  tx.process()
  tx.commit()
  tx = graph.cypher.begin()
  i = 0
  for key, link in g['links'].iteritems():
    st = key.split(' -- ')
    source = st[0]
    target = st[1]
    distance = float(link['distance'])
    weight = float(link['weight'])
    add_edge(tx, "Edge", source, target, dict(_isNetworkEdge=True, distance=distance, weight=weight, pathways=[]))
    # add reverse edge
    # add_edge(tx, "Edge", target, source, dict(_isNetworkEdge=True,distance=distance,weight=weight))
    i += 1
    if i > 100:
      tx.process()
      tx.commit()
      tx = graph.cypher.begin()
      i = 0
  tx.process()
  tx.commit()

  tx = graph.cypher.begin()

  # create set relationship by targetclass
  for k, g in itertools.groupby(sorted(g['nodes'].iteritems(), key=lambda x: x[1]['targetclass']),
                                lambda x: x[1]['targetclass']):
    add_node(tx, ["_Set_Node"], k, {"name": k})
    groups = list(g)
    print groups
    for id, node in groups:
      add_edge(tx, "ConsistsOfEdge", k, id, dict(), '_Set_Node')

  # find all network matches and check common set relationships
  tx.append('MATCH (s:_Network_Node)-[r:Edge]->(t:_Network_Node), (s)<-[rc1:ConsistsOfEdge]-(n:_Set_Node)-[rc2:ConsistsOfEdge]->(t) SET r.pathways = r.pathways + n.id')

  # for id2, node2 in groups:
  #  if id != id2:
  #    add_edge(tx, "Edge", id, id2, dict(_isSetEdge=True,pathways=[k]),update_only=True)

  #  i += 1
  #  if i > 100:
  #    tx.process()
  #    tx.commit()
  #    tx = graph.cypher.begin()
  #    i = 0

  tx.process()
  tx.commit()


if __name__ == '__main__':
  if not os.path.exists(datapath):
    os.makedirs(datapath)

  # files = [f for f in listdir(datapath) if isfile(join(datapath, f) and f.endswith('.dot.json'))]

  # for f in files:
  importfile(join(datapath, 'targets_per_cpds.dot.json'))
