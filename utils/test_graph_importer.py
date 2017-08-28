from py2neo import Graph, Node, Relationship
from py2neo.cypher import CreateStatement

graph = Graph("http://127.0.0.1:7474/db/data/")
graph.delete_all()

nodes = {"a": Node("NETWORK_NODE", id="A", name="A"),
         "b": Node("NETWORK_NODE", id="B", name="B"),
         "c": Node("NETWORK_NODE", id="C", name="C"),
         "d": Node("NETWORK_NODE", id="D", name="D"),
         "e": Node("NETWORK_NODE", id="E", name="E"),
         "f": Node("NETWORK_NODE", id="F", name="F"),
         "g": Node("NETWORK_NODE", id="G", name="G")}

edges = [Relationship(nodes["a"], "EDGE", nodes["b"], **{"_isNetworkEdge": True, "pathways": ["hsa01"]}),
         Relationship(nodes["a"], "EDGE", nodes["d"])]

# Relationship(nodes["b"], "RELATIONSHIP", nodes["c"]),
# Relationship(nodes["b"], "RELATIONSHIP", nodes["d"]),
# Relationship(nodes["b"], "RELATIONSHIP", nodes["e"]),
# Relationship(nodes["c"], "RELATIONSHIP", nodes["e"]),
# Relationship(nodes["d"], "RELATIONSHIP", nodes["c"]),
# Relationship(nodes["d"], "RELATIONSHIP", nodes["f"]),
# Relationship(nodes["e"], "RELATIONSHIP", nodes["g"]),
#      Relationship(nodes["e"], "RELATIONSHIP", nodes["f"]),
#      Relationship(nodes["f"], "RELATIONSHIP", nodes["g"]),
#      Relationship(nodes["g"], "RELATIONSHIP", nodes["a"])]

builder = CreateStatement(graph)

# graph.create(nodeDict.values())
for node in nodes.values():
  builder.create(node)
for edge in edges:
  builder.create(edge)
builder.execute()


def edge_query(source, target):
  return ("MATCH (source:NETWORK_NODE {id: '" + source + "'}) "
                                                         "MATCH (target:NETWORK_NODE {id: '" + target + "'}) "
                                                                                                        "MERGE (source)-[rel:EDGE]->(target) "
                                                                                                        "ON CREATE SET rel._isSetEdge=true, rel.pathways=[\"hsa02\"], rel.try=true "
                                                                                                        "ON MATCH SET rel._isSetEdge=true, rel.pathways= CASE WHEN NOT (HAS (rel.pathways)) THEN [\"hsa02\"] ELSE rel.pathways + [\"hsa02\", \"hsa03\"] END, rel.try=true ")


graph.cypher.execute("CREATE CONSTRAINT ON (n:NETWORK_NODE) ASSERT n.id IS UNIQUE")

graph.cypher.execute("MERGE (node:NETWORK_NODE {id: \"A\"}) "
                     "ON CREATE SET node.name=\"A\""
                     "ON MATCH SET node.name=\"A\"")

graph.cypher.execute("MERGE (node:NETWORK_NODE {id: \"Q\"}) "
                     "ON CREATE SET node.name=\"Q\""
                     "ON MATCH SET node.name=\"Q\"")

graph.cypher.execute(edge_query("A", "B"))
graph.cypher.execute(edge_query("F", "G"))
graph.cypher.execute(edge_query("A", "D"))


# for record in res:
#     print record;
