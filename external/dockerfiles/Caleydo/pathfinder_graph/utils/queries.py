# import Bio
from py2neo import Graph


def get_path():
  # session = cypher.Session("http://localhost:7474")
  # tx = session.create_transaction()
  # tx.append("MATCH (s {name:'GAPD'}), (e {name:'C00236'}), p = shortestPath((s)-[*]-(e)) RETURN p")
  # # tx.append("START beginning=node(3), end=node(16) MATCH p = shortestPath(beginning-[*..500]-end) RETURN p")
  # for record in tx.execute():
  #     print (record)

  graph = Graph("http://127.0.0.1:7474/db/data/")
  # tx = graph.cypher.begin()
  # query = "MATCH (n {name:'C00024'}) RETURN n"
  # query = "MATCH (start {name:'GAPD'}) RETURN start"
  # query = "MATCH (s {name:'GAPD'}), (e {name:'C00236'}) RETURN s, e"
  # query = "START beginning=node(1033), end=node(1126) MATCH p = (beginning)-[*..8]-(end) RETURN p AS shortestPath LIMIT 1"
  # query = "MATCH (s {name:'GAPD'}), (e {name:'C00236'}), p = shortestPath((s)-[*]-(e)) RETURN p"

  query = "MATCH (n {name:'C00024'}) RETURN n.name AS name"

  # for record in graph.cypher.execute(query):
  #     return record

  # result = neo4j.CypherQuery("http://127.0.0.1:7474/db/data/", query).execute()
  # tx.append(query)
  for record in graph.cypher.execute(query):
    print (record)


get_path()
