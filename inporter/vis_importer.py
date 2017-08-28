import os

import argparse
import itertools

from import_utils import GraphImporter, UnicodeReader

parser = argparse.ArgumentParser(description='DOT Importer')
parser.add_argument('--db', default="http://192.168.56.1:7476/db/data/")
parser.add_argument('--data_dir', '-d', default='/vagrant_data/', help='data directory')
parser.add_argument('--clear', action='store_true', help='clear the graph')
parser.add_argument('--commitEvery', type=int, default=100, help='commit every x steps')

args = parser.parse_args()

importer = GraphImporter(args.db, args.commitEvery)
importer.delete_all()


def import_it():
  with open(os.path.join(args.data_dir, 'IEEE VIS papers 1990-2014 - Main dataset.tsv'), 'r') as f:
    # 0  Conference
    # 1  Year
    # 2  Paper Title
    # 3  Paper DOI
    # 4  Link
    # 5  first age
    # 6  Last age
    # 7  IEEE XPLORE Article Number
    # 8  Panel, Keynote, Captstone, Demo, Poster, ...	P
    # 9  Paper type: C=conference paper, T = TVCG journal paper, M=miscellaneous (capstone, keynote, VAST challenge, panel, poster, ...)
    # 10 Abstract
    # 11 Author Names
    # 12 First Author Affiliation
    # 13 Author IDs
    # 14 IEEE Xplore Number Guessed
    # 15 Deduped author names
    # 16 filename
    # 17 Citations
    paper_types = dict(C='Conference_Paper', T='TVCG_Journal_Paper', M='Miscellaneous')

    def clean_name(name):
      return name.replace(u' ', u'_').replace(u',', u'_').replace(u'.', u'_').replace(u'__', u'_').strip().encode('ascii', 'ignore')

    citations = dict()
    paper_lookup = dict()
    reader = UnicodeReader(f, delimiter='\t')
    reader.next()
    fieldnames = ['conference', 'year', 'title', 'doi', 'link', 'fpage', 'lpage', 'number', 'special', 'type',
                  'abstract',
                  'names', 'aff', 'author_ids', 'author_number', 'authors', 'filename', 'citations']

    for row in reader:
      row = {f: row[i] for i, f in enumerate(fieldnames)}
      authors_ids = []
      for author, id, affiliation in itertools.izip(row['authors'].split(';'), row['author_ids'].split(';'),
                                                    row['aff'].split(';')):
        author_id = clean_name(author)
        authors_ids.append(author_id)
        prop = dict(name=author)
        if id != '':
          prop['author_id'] = id
        if affiliation != '':
          prop['affiliation'] = affiliation
        importer.add_node(['_Set_Node', 'Author'], author_id, prop)

      importer.add_node(
          ['_Network_Node', 'Publication', row['conference'].replace('InfoVIs', 'InfoVis'), paper_types[row['type']]],
          row['filename'],
          dict(year=row['year'],
               doi=row['doi'],
               name=row['title'].replace('"', "'"),
               pages=row['fpage'] + u'-' + row['lpage'],
               ieee=row['number'],
               abstract=row['abstract'].replace('"', "'"),
               authors=authors_ids))
      citations[row['filename']] = row['citations'].replace(',', ';').split(';')
      paper_lookup[row['filename']] = row['filename']
      paper_lookup[row['number']] = row['filename']
      for author_id in authors_ids:
        importer.add_edge('AuthorOf', author_id, row['filename'], dict(), 'Author')
    importer.done_nodes()

  for paper, cit in citations.iteritems():
    if len(paper) > 0:
      for c in cit:
        importer.add_edge('Cites', paper, paper_lookup[c], dict())

  importer.append('MATCH (n:Author) set n.publications = 0, n.cites = 0')
  importer.append('MATCH (n:Publication) set n.cites = 0')
  importer.append('MATCH (a:Publication)-[:Cites]->(b:Publication) set b.cites = b.cites +1')
  importer.append('MATCH (a:Author)-[:AuthorOf]->(b:Publication) set a.publications = a.publications + 1 , a.cites = a.cites + b.cites')
  importer.finish()


if __name__ == '__main__':
  import_it()
