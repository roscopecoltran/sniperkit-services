from py2neo import Graph

graph = Graph("http://localhost:7474/db/data/")

# graph.cypher.execute("MATCH (n:_Network_Node)<--(s:_Set_Node)-->(x:_Network_Node) WITH n, count(DISTINCT x) as degree SET n.degree = degree")

x = graph.cypher.execute("MATCH (n) RETURN count(n)")

print x

# for record in res:
#     print record;
