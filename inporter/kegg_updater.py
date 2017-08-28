import os
from os import listdir
from os.path import isfile, join

import argparse
import csv

from import_utils import GraphImporter

parser = argparse.ArgumentParser(description='DBLP Importer')
parser.add_argument('--db', default="http://localhost:7476/db/data/")
parser.add_argument('--data_dir', '-d', default='/vagrant_data', help='data directory')
parser.add_argument('--commitEvery', type=int, default=100, help='commit every x steps')
args = parser.parse_args()

importer = GraphImporter(args.db, args.commitEvery)


def importfile(name):
  with open(name, 'r') as f:
    r = csv.reader(f, delimiter='\t')
    r.next()
    for line in r:
      id = line[0]
      name = line[2]
      if len(name) > 0:
        importer('MATCH (n:_Network_Node) WHERE n.id = "{0}" SET n.name = "{1}"'.format(id, name))
    importer.finish()


if __name__ == '__main__':
  if not os.path.exists(args.data_dir):
    os.makedirs(args.data_dir)

  files = [f for f in listdir(args.data_dir) if isfile(join(args.data_dir, f)) and f.endswith('e2d2s.csv')]

  for f in files:
    importfile(join(args.data_dir, f))
