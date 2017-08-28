from py2neo import Graph
from collections import namedtuple

pathways = Graph('http://localhost:7475/db/data/')
mapping = Graph('http://localhost:7474/db/data/')

Gene = namedtuple('Gene', 'uid, id')

unmapped = []
mapped = []

for entry in pathways.cypher.execute('match (s:Gene) where s.id = s.name return s'):
  n = entry.s
  print n.properties['id']
  q = 'match (s:Entrez {{ id: "{0}" }} )-[:knownAs]-(:David)-[:knownAs]-(t:GeneSymbol) return t.id as tid'.format(n.properties['id'])
  r = mapping.cypher.execute(q)
  if len(r) > 0:
    # print n.properties['name'], r[0].tid
    n.properties['name'] = r[0].tid
    n.push()
    mapped.append(n.properties['id'])
    print n.properties['id']
  else:
    unmapped.append(n.properties['id'])

print mapped
print unmapped
