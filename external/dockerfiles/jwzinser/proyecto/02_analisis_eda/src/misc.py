import sqlite3
import nltk
import pandas as pn
from nltk.tokenize import word_tokenize
from collections import Counter
import matplotlib.pyplot as plt
from wordcloud import WordCloud
from nltk.stem.snowball import SnowballStemmer
from resources.tools.auxiliar_functions import *
from nltk.stem import WordNetLemmatizer



conn = sqlite3.connect('/Users/juanzinser/Documents/MCC/gran_escala/dpa_djms/proyecto/listverse.db')
c = conn.cursor()
c.execute("""select distinct date from articles""")
results = c.fetchall()