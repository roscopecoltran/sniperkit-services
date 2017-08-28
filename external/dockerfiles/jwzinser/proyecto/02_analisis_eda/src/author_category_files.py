import sqlite3
import nltk
import pandas as pn
from nltk.tokenize import word_tokenize
from collections import Counter
import os
import numpy as np
import sklearn
import sklearn.feature_extraction.text as text




conn = sqlite3.connect('/Users/juanzinser/Documents/MCC/gran_escala/dpa_djms/proyecto/listverse.db')

c = conn.cursor()
c.execute("""select distinct author from articles""")
authors = c.fetchall()



# lograr algunos estadisticos descriptivos para los articulos de cada uno de los diferetes autores
# crear los archivos de entrenamiento para basarnos en el algoritmo de
# https://github.com/devanshdalal/Author-Identification-task

import os

for author in authors:
    author=author[0]
    print author
    # crea folder si no existe
    # folder path
    base_data_path = 'resources/data/authors/training/'
    author_path = base_data_path + author
    if not os.path.exists(author_path):
        os.makedirs(author_path)

    c.execute(u"select * from articles where author='{author}'".format(author=author))
    results = c.fetchall()

    texts = ' '.join([r[5] for r in results])
    text_file = open(u"resources/data/authors/training/{author}/articles.txt".format(author=author), "w")
    text_file.write(texts.encode('utf8'))
    text_file.close()




c.execute("select distinct category from articles")
categories = c.fetchall()
for category in categories:
    category = category[0]
    print category
    c.execute("select * from articles where category='{category}'".format(category=category))
    results = c.fetchall()

    texts = ' '.join([r[5] for r in results])
    # write text into the file
    text_file = open("resources/data/{category}.txt".format(category=category), "w")
    text_file.write(texts.encode('utf8'))
    text_file.close()
