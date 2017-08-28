import sqlite3
import nltk
import pandas as pn
import numpy as np
from nltk.tokenize import word_tokenize
from collections import Counter
import matplotlib.pyplot as plt
from nltk.stem.snowball import SnowballStemmer
from resources.tools.auxiliar_functions import *
from nltk.stem import WordNetLemmatizer
import gensim  # paquete que trae los modelos de representacion de palabras (LSI y LDA)
from sklearn


conn = sqlite3.connect('datos/listverse.db')
stemmer = SnowballStemmer("english")
wnl = WordNetLemmatizer()

"""
CARGA STOPWORDS, HACE UN QUERY DE 10000 articulos y "limpia" los articulos
"""
sw_file = open("resources/stopwords.txt", "r")
sw = sw_file.readlines()
sw_file.close()
sw_all = ' '.join(sw).replace('\n',' ')
c = conn.cursor()
c.execute("""select * from articles ORDER BY RANDOM() limit 10000;""")
results = c.fetchall()
data = pn.DataFrame(results)
data.columns = ['url','date','title','category','author','body']
lda_df = data[['category','body']]
lda_df['clean_body'] = lda_df['body'].map(lambda x: [wnl.lemmatize(word) for word in nltk.regexp_tokenize(x.lower(), r'\w+') if (wnl.lemmatize(word) not in sw_all and not RepresentsInt(word))] )



articles = lda_df.clean_body.tolist()
dictionary = gensim.corpora.Dictionary(articles)

# obtiene la representacion vectorial de las palabras y su frecuencia para cada documento
newVec = [dictionary.doc2bow(art) for art in articles]
# genera el modelo de frecuencias para los articulos
tfidf = gensim.models.TfidfModel(newVec)
# obtiene la matriz de los
corpus_tfidf = tfidf[newVec]
# tenemos 29 categorias en nuestra muestra
lda = gensim.models.LdaModel(corpus_tfidf, num_topics=30, id2word=dictionary)

corpus_lda = lda[corpus_tfidf]

lda_art = [lda[docbow] for docbow in newVec]
matrix = np.transpose(gensim.matutils.corpus2dense(lda_art, num_terms=30 ))


from sklearn.cluster import KMeans
kmeans = KMeans(n_clusters=29, random_state=0).fit(matrix)
klabels = kmeans.labels_

lda_df['labels'] = klabels

from collections import Counter
def categories_set(x):
    x = x.tolist()
    ct = Counter(x)
    return ct.most_common()

results = lda_df.groupby('labels')['category'].agg(['count',categories_set]).reset_index().sort_values(by='count',ascending=False)
