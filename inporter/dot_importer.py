import csv
import argparse
import pydotplus
import itertools

from import_utils import GraphImporter

parser = argparse.ArgumentParser(description='DOT Importer')
parser.add_argument('--db', default='http://localhost:7475/db/data/')
parser.add_argument('--data_dir', '-d', default='/vagrant_data/dot/', help='data directory')
parser.add_argument('--undirected', action='store_true', help='create undirected graph')
parser.add_argument('--sets', action='store_true', help='create set edges')
parser.add_argument('--clear', action='store_true', help='clear the graph')
parser.add_argument('--commitEvery', type=int, default=100, help='commit every x steps')

args = parser.parse_args()

importer = GraphImporter(args.db, args.commitEvery)


# importer.delete_all()


# extras for creating the fields
# MATCH (a:Disease)-[:`ConsistsOfEdge`]->(b) SET b.diseases = []
# MATCH (a:Disease)-[:`ConsistsOfEdge`]->(b) SET b.diseases = b.disease + a.id
# MATCH (a:Disease)-[:`ConsistsOfEdge`]->(b)-[l:LinkTo]->(c)<-[:ConsistsOfEdge]-(a) SET l.diseases = []
# MATCH (a:Disease)-[:`ConsistsOfEdge`]->(b)-[l:LinkTo]->(c)<-[:ConsistsOfEdge]-(a) SET l.diseases = l.diseases + a.id
# MATCH (a:Pathway)-[:`ConsistsOfEdge`]->(b) SET b.pathways = []
# MATCH (a:Pathway)-[:`ConsistsOfEdge`]->(b) SET b.pathways = b.pathways + a.id
# MATCH (a:Pathway)-[:`ConsistsOfEdge`]->(b)-[l:LinkTo]->(c)<-[:ConsistsOfEdge]-(a) SET l.pathways = []
# MATCH (a:Pathway)-[:`ConsistsOfEdge`]->(b)-[l:LinkTo]->(c)<-[:ConsistsOfEdge]-(a) SET l.pathways = l.pathways + a.id
# MATCH (a:Phenotype)-[:`ConsistsOfEdge`]->(b) SET b.phenotypes = []
# MATCH (a:Phenotype)-[:`ConsistsOfEdge`]->(b) SET b.phenotypes = b.phenotypes + a.id
# MATCH (a:Phenotype)-[:`ConsistsOfEdge`]->(b)-[l:LinkTo]->(c)<-[:ConsistsOfEdge]-(a) SET l.phenotypes = []
# MATCH (a:Phenotype)-[:`ConsistsOfEdge`]->(b)-[l:LinkTo]->(c)<-[:ConsistsOfEdge]-(a) SET l.phenotypes = l.phenotypes + a.id

def clean(n):
  return n.replace('"', '')


def import_file(file):
  importer.delete_all()
  # fix dot file: don't like =\n -> replace by =""\n
  with open(file, 'r') as f:
    content = f.read()
    g = pydotplus.parse_dot_data(content)

  for n in g.get_nodes():
    id = clean(n.get_name())
    attrs = n.get_attributes()
    targetclass = clean(attrs['targetclass'])
    geneids = clean(attrs['geneids'])
    color = clean(attrs['color'])
    label = clean(attrs['label'])
    labels = ['_Network_Node']
    if len(targetclass) > 0:
      labels.append(targetclass.replace(' ', '_'))
    importer.add_node(labels, id, dict(color=color, name=label, geneids=geneids))

  importer.done_nodes()

  for link in g.get_edges():
    source = clean(link.get_source())
    target = clean(link.get_destination())
    attrs = n.get_attributes()
    distance = float(attrs.get('distance', 0))
    weight = float(attrs.get('weight', 0))
    importer.add_edge('LinkTo', source, target, dict(_isNetworkEdge=True, distance=distance, weight=weight))
    # add reverse edge
    if args.undirected:
      importer.add_edge('LinkTo', target, source, dict(_isNetworkEdge=True, distance=distance, weight=weight))

  if args.sets:
    # create set relationship by targetclass
    for k, g in itertools.groupby(sorted(g.get_nodes(), key=lambda x: x.get_label('targetclass')),
                                  lambda x: x.get_label('targetclass')):
      importer.add_node(['_Set_Node'], k, {'name': k})
      groups = list(g)
      for node in groups:
        id = clean(node.get_name())
        importer.add_edge('ConsistsOf', k, id, dict(), '_Set_Node')
        # for node2 in groups:
        #  id2 = node2.get_name()
        #  if id != id2:
        #    importer.add_edge('Edge', id, id2, dict(_isSetEdge=True,targetclass=k))

  importer.finish()


def grouper_it(n, iterable):
  it = iter(iterable)
  while True:
    chunk_it = itertools.islice(it, n)
    try:
      first_el = next(chunk_it)
    except StopIteration:
      return
    yield itertools.chain((first_el,), chunk_it)


def import_pathway():
  importer.append('MATCH (n:Pathway)-[r:ConsistsOfEdge]->(:_Network_Node) DELETE n,r')
  with open(args.data_dir + '/collections.broad.apr18.tsv', 'r') as f:
    for i, row in enumerate(csv.reader(f, delimiter='\t')):
      # print row
      id = row[0]
      category = row[1].capitalize()
      geneids = row[3].split(';')
      # print id, geneids
      try:
        qs = []
        for subids in grouper_it(100, geneids):
          q = u'MATCH (source:Pathway {{id:"{0}"}}), (target:_Network_Node ) WHERE target.geneids in ["{1}"] CREATE source-[el:ConsistsOfEdge]->target' \
              .format(id + '_' + category, u'","'.join(subids))
          qs.append(q)
        importer.add_node(['_Set_Node', 'Pathway', category], id + u'_' + category, dict(name=id, category=category))
        for q in qs:
          importer.append(q)
        importer.done_nodes()
      except UnicodeDecodeError as e:
        print 'cant add pathway edge: ', i, id + '_' + category, e
      except Exception as e:
        print 'cant add pathway edge: ', i, id + '_' + category, e

  importer.finish()


def import_pheno():
  with open(args.data_dir + 'mousePhen.humanGenes.tsv', 'r') as f:
    for row in (r for i, r in enumerate(csv.reader(f, delimiter='\t')) if i > 0):
      # print row
      geneid = row[0]
      pheno = row[5]
      pheno_label = row[6]
      # print id, geneids
      importer.add_node(['_Set_Node', 'Phenotype'], pheno, dict(name=pheno_label))
      try:
        q = u'MATCH (source:Phenotype {{id:"{0}"}}), (target:_Network_Node {{geneids:"{1}"}}) CREATE source-[el:ConsistsOfEdge]->target'.format(pheno, geneid)
        importer.append(q)
      except:
        print 'cant add pheno edge: ', pheno, geneid
  importer.finish()


def import_disease():
  with open(args.data_dir + 'humandisease.txt', 'r') as f:
    for row in (r for i, r in enumerate(csv.reader(f, delimiter='\t')) if i > 0):
      # print row
      geneid = row[0]
      disease = row[2]
      disease_label = row[3]
      # print id, geneids
      importer.add_node(['_Set_Node', 'Disease'], disease, dict(name=disease_label))
      importer.append(u'MATCH (source:Disease {{id:"{0}"}}), (target:_Network_Node {{geneids:"{1}"}}) CREATE source-[el:ConsistsOfEdge]->target'.format(disease, geneid))

  importer.finish()


def update_labels():
  # importer.append(u'MATCH (a:_Network_Node) set a.name = a.id');
  with open(args.data_dir + 'mapping.csv', 'r') as f:
    for row in csv.reader(f, delimiter='\t'):
      # print row
      geneid = row[0]
      genename = clean(row[1])
      importer.append(u'MATCH (a:_Network_Node {{geneids:"{0}"}}) SET a.name="{1}"'.format(geneid, genename))
  importer.finish()


if __name__ == '__main__':
  # import_file('/vagrant_data/dot/targets_per_cpds.dot')
  # update_labels()
  # import_disease()
  # import_pheno()
  import_pathway()
