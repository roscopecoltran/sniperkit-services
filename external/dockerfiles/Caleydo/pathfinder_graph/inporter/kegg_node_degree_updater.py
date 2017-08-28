from py2neo import Graph

graph = Graph("http://192.168.50.52:7475/db/data/")

graph.cypher.execute("MATCH (n:_Network_Node)-[:Edge]-(x) WITH n, count(DISTINCT x) as degree SET n.degree = degree")

# for record in res:
#     print record;
