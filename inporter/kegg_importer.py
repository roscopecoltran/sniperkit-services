import os

from os import listdir
from os.path import isfile, join

from py2neo import Graph

from Bio.KEGG.REST import kegg_list, kegg_get
from Bio.KEGG.KGML import KGML_parser

from import_utils import add_edge, add_node

datapath = os.path.dirname(os.path.realpath(__file__)) + "/data/"

if not os.path.exists(datapath):
  os.makedirs(datapath)

files = [f for f in listdir(datapath) if isfile(join(datapath, f))]

if len(files) == 0:
  # download kgml files
  res = kegg_list('pathway', 'hsa').read()
  items = res.split("\n")
  for item in items[:len(items) - 1]:
    pathway_id = item[5:13]
    print("fetching " + pathway_id)
    kgml = kegg_get(pathway_id, "kgml").read()
    with open(datapath + pathway_id + ".kgml", "w") as text_file:
      text_file.write(kgml)

  files = [f for f in listdir(datapath) if isfile(join(datapath, f))]


def get_names(names):
  n = names.replace("...", "", -14)
  return n.split(", ")


# def create_pathway_edge(edgeDict, sourceNode, targetNode):
#     edgeID = sourceNode.properties["id"] + "_" + targetNode.properties["id"]
#     # edgeID = sourceNode.body["id"] + "_" + targetNode.body["id"]
#     if edgeID not in edgeDict:
#         edge = Relationship(sourceNode, "EDGE", targetNode)
#         edge.properties["_isNetworkEdge"] = True
#         edgeDict[edgeID] = edge


# def create_entities(entities):
# step = 200
# start = 0
# end = min(step, len(entities))
#
# while start < len(entities):
#         graph.create(*(entities[start:end]))
#         print("added " + str(end) + " of " + str(len(entities)) + " entities")
#         start = end
#         end = min(end + step, len(entities))


# def create_property_string(strlist, properties):
#     if len(properties) > 0:
#         strlist.append(" {")
#         is_first = True
#         l = dict()
#         for key in properties.keys():
#             if not is_first:
#                 strlist.append(", ")
#             is_first = False
#             strlist.append(key)
#             strlist.append(":")
#             value = properties[key]
#             if isinstance(value, basestring):
#                 strlist.append("\"" + str(value) + "\"")
#             elif isinstance(value, list):
#                 first_val = True
#                 strlist.append("[")
#                 for v in value:
#                     if isinstance(v, basestring):
#                         if not first_val:
#                             strlist.append(", ")
#                         first_val = False
#                         strlist.append("\"" + str(v) + "\"")
#                     else:
#                         if not first_val:
#                             strlist.append(", ")
#                         first_val = False
#                         strlist.append(str(v))
#                 strlist.append("]")
#             else:
#                 strlist.append(str(properties[key]))
#         strlist.append("}")


# def create_node_query(node):
#     strlist = ["CREATE (n"]
#     for label in node.labels:
#         strlist.append(":" + label)
#     create_property_string(strlist, node.properties)
#     strlist.append(")")
#     return "".join(strlist)


# def create_edge_query(edge):
#     strlist = ["MATCH (source:NETWORK_NODE {id: \""]
#     strlist.append(str(edge.start_node.properties["id"]))
#     strlist.append("\"}) MATCH (target:NETWORK_NODE {id: \"")
#     strlist.append(str(edge.end_node.properties["id"]))
#     strlist.append("\"}) MERGE (source)-[:")
#     strlist.append(edge.type)
#     create_property_string(strlist, edge.properties)
#     strlist.append("]->(target)")
#
#     return "".join(strlist)


# def create_entities(entities, query_function):
#     step = 200
#     start = 0
#     end = min(step, len(entities))
#
#     while start < len(entities):
#         index = start
#         tx = graph.cypher.begin()
#         while index < end:
#             q = query_function(entities[index])
#             tx.append(q)
#             if index == start:
#                 print(q)
#             index += 1
#
#         tx.process()
#         tx.commit()
#         print("added " + str(end) + " of " + str(len(entities)) + " entities")
#         start = end
#         end = min(end + step, len(entities))


# def create_edges(edges):
#     step = 200
#     start = 0
#     end = min(step, len(edges))
#
#     while start < len(edges):
#         index = start
#         tx = graph.cypher.begin()
#         while index < end:
#             q = create_node_query(nodes[index])
#             tx.append(q)
#             if index == start:
#                 print(q)
#             index += 1
#
#         tx.process()
#         tx.commit()
#         print("added " + str(end) + " of " + str(len(nodes)) + " nodes")
#         start = end
#         end = min(end + step, len(nodes))

def commit(tx, num_statements, max_statements, total_num_statements):
  if num_statements >= max_statements:
    tx.process()
    tx.commit()
    print("committed " + str(total_num_statements) + " statements")
    return True
  return False


graph = Graph("http://127.0.0.1:7474/db/data/")
graph.delete_all()

graph.cypher.run("CREATE INDEX ON :_Network_Node(id)")

# Maps from the extracted node id (e.g. EGFR) to the Node Object
nodes = set()
# Map to prevent multiple creation of edges between two nodes uses concatenated node ids as keys (e.g. EGFR_C00010)
# edgeDict = dict()

# batch = WriteBatch(graph)


max_statements = 200
num_statements = 0
total_num_statements = 0

tx = graph.cypher.begin()

for filename in files:
  url = datapath + filename
  print ("Loading file " + url)

  currentNodes = set()

  with open(url) as f:
    pathway = KGML_parser.read(f, 'r')
    # Maps from the reaction id (e.g. rn:R05134) to the Node Objects that are part of this reaction
    reactionToNode = dict()
    # Maps from the internal pathway id (e.g. 23) to the compound id (e.g. C00010)
    compoundDict = dict()

    for gene in pathway.genes:
      for geneName in gene.name.split(" "):
        gene_id = geneName[4:]
        if gene_id not in nodes:
          add_node(tx, ["_Network_Node", "Gene"], gene_id, {"name": gene_id, "idType": "ENTREZ"})
          num_statements += 1
          total_num_statements += 1
          if commit(tx, num_statements, max_statements, total_num_statements):
            num_statements = 0
            tx = graph.cypher.begin()

          # node = Node("NETWORK_NODE", "Gene", id=name, idType="GENE_SYMBOL", name=name)

          # n = batch.create(node)
          nodes.add(gene_id)
        genesInReaction = set()
        if gene.reaction not in reactionToNode:
          reactionToNode[gene.reaction] = genesInReaction
        else:
          genesInReaction = reactionToNode[gene.reaction]
        genesInReaction.add(gene_id)
        currentNodes.add(gene_id)

    # print(reactionToNode)

    for compound in pathway.compounds:
      for compoundName in compound.name.split(" "):
        compound_id = compoundName[4:]
        if compound_id not in nodes:

          add_node(tx, ["_Network_Node", "Compound"], compound_id, {"name": compound_id, "idType": "KEGG_COMPOUND"})
          num_statements += 1
          total_num_statements += 1
          if commit(tx, num_statements, max_statements, total_num_statements):
            num_statements = 0
            tx = graph.cypher.begin()

          # node = Node("NETWORK_NODE", "Compound", id=name, idType="KEGG_COMPOUND", name=name)
          # n = batch.create(node)
          nodes.add(compound_id)
        if compound.id not in compoundDict:
          compoundDict[compound.id] = compound_id
        currentNodes.add(compound_id)

    # Make sure all nodes are committed
    num_statements = 0
    tx.process()
    tx.commit()
    tx = graph.cypher.begin()

    for reaction in pathway.reactions:
      if reaction.name in reactionToNode:
        gene_ids = reactionToNode[reaction.name]
        for gene_id in gene_ids:
          for substrate in reaction.substrates:
            substrate_id = substrate.name[4:]
            if substrate_id in nodes:
              add_edge(tx, "Edge", substrate_id, gene_id, {"_isNetworkEdge": True})
              num_statements += 1
              total_num_statements += 1
              if commit(tx, num_statements, max_statements, total_num_statements):
                num_statements = 0
                tx = graph.cypher.begin()
              # create_pathway_edge(edgeDict, substrateNode, node)
              if reaction.type == "reversible":
                add_edge(tx, "Edge", gene_id, substrate_id, {"_isNetworkEdge": True})
                num_statements += 1
                total_num_statements += 1
                if commit(tx, num_statements, max_statements, total_num_statements):
                  num_statements = 0
                  tx = graph.cypher.begin()
                  # create_pathway_edge(edgeDict, node, substrateNode)

          for product in reaction.products:
            product_id = substrate.name[4:]
            if product_id in nodes:
              add_edge(tx, "Edge", gene_id, product_id, {"_isNetworkEdge": True})
              num_statements += 1
              total_num_statements += 1
              if commit(tx, num_statements, max_statements, total_num_statements):
                num_statements = 0
                tx = graph.cypher.begin()
              # create_pathway_edge(edgeDict, node, productNode)

              if reaction.type == "reversible":
                add_edge(tx, "Edge", product_id, gene_id, {"_isNetworkEdge": True})
                num_statements += 1
                total_num_statements += 1
                if commit(tx, num_statements, max_statements, total_num_statements):
                  num_statements = 0
                  tx = graph.cypher.begin()
                  # create_pathway_edge(edgeDict, productNode, node)

    for relation in pathway.relations:
      isCompound = False
      compounds = []

      for subtype in relation.subtypes:
        if subtype[0] in ("compound", "hidden compound"):
          if subtype[1] in compoundDict:
            compoundName = compoundDict[subtype[1]]
            if compoundName in nodes:
              # compoundNode = nodeDict[compoundName]
              isCompound = True
              compounds.append(compoundName)

      for geneName in relation.entry1.name.split(" "):
        source_gene_id = geneName[4:]
        if source_gene_id in nodes:
          for g in relation.entry2.name.split(" "):
            target_gene_id = g[4:]
            if target_gene_id in nodes:
              if isCompound:
                for compoundNode in compounds:
                  add_edge(tx, "Edge", source_gene_id, compoundNode, {"_isNetworkEdge": True})
                  num_statements += 1
                  total_num_statements += 1
                  if commit(tx, num_statements, max_statements, total_num_statements):
                    num_statements = 0
                    tx = graph.cypher.begin()

                  add_edge(tx, "Edge", compoundNode, target_gene_id, {"_isNetworkEdge": True})
                  num_statements += 1
                  total_num_statements += 1
                  if commit(tx, num_statements, max_statements, total_num_statements):
                    num_statements = 0
                    tx = graph.cypher.begin()
                    # create_pathway_edge(edgeDict, sourceNode, compoundNode)
                    # create_pathway_edge(edgeDict, compoundNode, targetNode)
              else:
                add_edge(tx, "Edge", source_gene_id, target_gene_id, {"_isNetworkEdge": True})
                num_statements += 1
                total_num_statements += 1
                if commit(tx, num_statements, max_statements, total_num_statements):
                  num_statements = 0
                  tx = graph.cypher.begin()
                  # create_pathway_edge(edgeDict, sourceNode, targetNode)

  for node1 in currentNodes:

    # Will actually just add the pathways property to the existing node
    add_node(tx, ["_Network_Node"], node1, {"pathways": [pathway.name[5:]]})
    num_statements += 1
    total_num_statements += 1
    if commit(tx, num_statements, max_statements, total_num_statements):
      num_statements = 0
      tx = graph.cypher.begin()
    # if "pathways" in node1.properties:
    #     nodePathways = node1.properties["pathways"]
    #     nodePathways.append(pathway.name)
    # else:
    #     node1.properties["pathways"] = [pathway.name]

    for node2 in currentNodes:
      if node1 != node2:

        add_edge(tx, "Edge", node1, node2, {"_isSetEdge": True, "pathways": [pathway.name[5:]]})
        num_statements += 1
        total_num_statements += 1
        if commit(tx, num_statements, max_statements, total_num_statements):
          num_statements = 0
          tx = graph.cypher.begin()
          #
          # edgeID = node1.properties["id"] + "_" + node2.properties["id"]
          # edge = 0
          # if edgeID not in edgeDict:
          #     edge = Relationship(node1, "EDGE", node2)
          # else:
          #     edge = edgeDict[edgeID]
          #
          # edge.properties["_isSetEdge"] = True
          # if "pathways" in edge.properties:
          #     edgePathways = edge.properties["pathways"]
          #     edgePathways.append(pathway.name)
          # else:
          #     edge.properties["pathways"] = [pathway.name]
          # edgeDict[edgeID] = edge

  add_node(tx, ["_Set_Node", "Pathway"], pathway.name[5:], {"name": pathway.title, "idType": "KEGG_PATHWAY"})
  num_statements += 1
  total_num_statements += 1
  if commit(tx, num_statements, max_statements, total_num_statements):
    num_statements = 0
    tx = graph.cypher.begin()
  nodes.add(pathway.name)

tx.process()
tx.commit()

print("committed " + str(total_num_statements) + " statements")

# nodeDict[pathway.name] = Node("_Set_Node", "Pathway", id=pathway.name, idType="KEGG_PATHWAY", name=pathway.title)

# watch("httpstream")

# builder = CreateStatement(graph)

# print("Building graph from " + str(len(nodeDict)) + " nodes and " + str(len(edgeDict)) +
#       " edges.")
#
# print("adding nodes")
# create_nodes(nodeDict.values(), create_node_query)
#
# print("creating indexes")
# graph.cypher.run("CREATE INDEX ON :NETWORK_NODE(id)")
#
# print("adding edges")
# create_nodes(edgeDict.values(), create_edge_query)

# print("adding nodes")
# create_entities(nodeDict.values())
#
# print("adding edges")
# create_entities(edgeDict.values())

# graph.create(*edgeDict.values())
# print("adding nodes")
# for node in nodeDict.values():
# batch.create(node)
# builder.create(node)

# counter = 0
# numEdgesAdded = 0
# print("adding edges")
# for edge in edgeDict.values():
# batch.create(edge)
# counter += 1
# if counter == 500:
#         numEdgesAdded += counter
#         counter = 0
#         print(str(numEdgesAdded) + " edges done")
# # builder.create(edge)
# #
# print("Executing build")
# batch.submit()
# builder.execute()
