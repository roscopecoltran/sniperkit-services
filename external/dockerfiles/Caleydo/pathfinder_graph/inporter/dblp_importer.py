from os import listdir
from os.path import isfile, join
import gzip
import xml.sax
import argparse
from import_utils import GraphImporter

parser = argparse.ArgumentParser(description='DBLP Importer')
parser.add_argument('--db', default="http://localhost:7474/db/data/")
parser.add_argument('--data_dir', '-d', default='/vagrant/_data', help='data directory')
parser.add_argument('--undirected', action='store_true', help='create undirected graph')
parser.add_argument('--sets', action='store_true', help='create set edges')
parser.add_argument('--clear', action='store_true', help='clear the graph')
parser.add_argument('--commitEvery', type=int, default=100, help='commit every x steps')
args = parser.parse_args()

importer = GraphImporter(args.db, args.commitEvery)
if args.clear:
  importer.delete_all()


def fix_string(v):
  v = v.replace(u'"', u"'")
  v = v.replace(u'\\', u'\\\\')
  return v


class DBLPImporter(xml.sax.ContentHandler):
  def __init__(self):
    self.c = 0
    self.last = None
    self.attr = None
    self.attrs = set(['author', 'editor', 'title', 'booktitle', 'pages', 'year', 'address', 'journal', 'volume',
                      'number', 'month', 'url', 'ee', 'cdrom', 'cite', 'publisher', 'note', 'crossref', 'isbn', 'series',
                      'school', 'chapter'])
    self.nodes = set(['article', 'inproceedings', 'proceedings', 'book', 'incollection', 'phdthesis', 'mastersthesis', 'www'])

  @staticmethod
  def fix_list(authors):
    if type(authors) is not list:  # just a single one
      return [fix_string(authors)]
    # corner case with this special characters
    # heuristic if just a single char
    r = []
    for author in authors:
      if (len(author) > 0 and author[0].isupper()) or len(r) == 0:
        r.append(author)
      else:
        r[len(r) - 1] += author
    return [fix_string(ri) for ri in r]

  def create_node(self, elem):
    id = elem['key']

    # if 'journals/tvcg/' not in id and 'conf/chi' not in id: #filter to just tvcg journal
    #  return

    where = u'TVCG' if 'journals/tvcg/' in id else u'CHI'
    kind = u'Journal' if 'journals/tvcg/' in id else u'ConferencePaper'

    if 'editor' in elem and 'author' not in elem:
      elem['author'] = elem['editor']
      del elem['editor']
    if 'author' in elem:
      elem['author'] = self.fix_list(elem['author'])

    def to_val(k, v):
      if type(v) is not list:
        return fix_string(v)
      if k == 'author':
        return v
      return fix_string(u''.join(v))

    # join all other multi values together
    elem = {k: to_val(k, v) for k, v in elem.iteritems()}

    importer.add_node([u'_Set_Node', u'Publication', elem['type'].title(), where, kind], id, elem)

    if 'author' in elem:
      for author in elem['author']:
        aid = author.replace(u' ', u'_')
        importer.add_node([u'_Network_Node', u'Author'], aid, {where.lower() + u'_papers': [id], 'name': author})
        importer.add_edge('AuthoredBy', id, aid, dict(), '_Set_Node')
      self.c += 1
    if self.c % 100 == 0:
      print u'add ' + elem['type'] + u' ' + elem.get('title', 'Unknown')
    pass

  def startElement(self, name, attrs): # flake8: noqa
    if name in self.attrs:
      self.attr = name
    elif name in self.nodes:
      self.last = dict(attrs)
      self.last['type'] = name

  def endElement(self, name): # flake8: noqa
    if name in self.attrs:
      self.attr = None
    elif name in self.nodes:
      self.create_node(self.last)
      self.last = None

  def characters(self, val):
    if self.attr is not None:
      if self.attr in self.last:
        v = self.last[self.attr]
        if type(v) is list:
          v.append(val)
        else:
          self.last[self.attr] = [v, val]
      else:
        self.last[self.attr] = val


def importfile(file):
  with gzip.open(file, 'r') as f:
    parser = xml.sax.make_parser()
    parser.setContentHandler(DBLPImporter())
    parser.parse(f)
    importer.finish()


def import_cited():
  import csv
  with open(args.data_dir + '/cited.csv', 'r') as f:
    for row in csv.reader(f, delimiter=','):
      title = row[0]
      # doi = row[1]
      cited = int(row[2])
      r = importer.graph.cypher.execute('MATCH (n:Publication) WHERE n.title=~"{0}.*" RETURN count(n) as c'.format(title.replace('.', '\\\\.')))
      if r[0].c <= 0:
        print title, cited
  importer.finish()


if __name__ == '__main__':
  # if not os.path.exists(args.data_dir):
  #  os.makedirs(args.data_dir)

  files = [f for f in listdir(args.data_dir) if isfile(join(args.data_dir, f)) and f.endswith('dblp.xml.gz')]

  for f in files:
    importfile(join(args.data_dir, f))
    # import_cited()
