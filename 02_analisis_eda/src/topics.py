import os

import sqlite3
import numpy as np
import sklearn
import sklearn.feature_extraction.text as text




CORPUS_PATH = os.path.join('resources', 'data')
filenames = sorted([os.path.join(CORPUS_PATH, fn) for fn in os.listdir(CORPUS_PATH)])


vectorizer = text.CountVectorizer(input='filename', stop_words='english', min_df=20)

dtm = vectorizer.fit_transform(filenames).toarray()
vocab = np.array(vectorizer.get_feature_names())
from sklearn import decomposition
num_topics = 20

num_top_words = 20

clf = decomposition.NMF(n_components=num_topics, random_state=1)

# this next step may take some time
doctopic = clf.fit_transform(dtm)
# print words associated with topics
topic_words = []

for topic in clf.components_:
    word_idx = np.argsort(topic)[::-1][0:num_top_words]
    topic_words.append([vocab[i] for i in word_idx])

doctopic = doctopic / np.sum(doctopic, axis=1, keepdims=True)

novel_names = []

for fn in filenames:
    basename = os.path.basename(fn)
    name, ext = os.path.splitext(basename)
    novel_names.append(name)

# turn this into an array so we can use NumPy functions
novel_names = np.asarray(novel_names)

doctopic_orig = doctopic.copy()

# use method described in preprocessing section
num_groups = len(set(novel_names))

doctopic_grouped = np.zeros((num_groups, num_topics))

for i, name in enumerate(sorted(set(novel_names))):
    doctopic_grouped[i, :] = np.mean(doctopic[novel_names == name, :], axis=0)

doctopic = doctopic_grouped

novels = sorted(set(novel_names))

print("Top NMF topics in...")

for i in range(len(doctopic)):
    top_topics = np.argsort(doctopic[i,:])[::-1][0:3]
    top_topics_str = ' '.join(str(t) for t in top_topics)
    print("{}: {}".format(novels[i], top_topics_str))

for t in range(len(topic_words)):
    print("Topic {}: {}".format(t, ' '.join(topic_words[t][:15])))



enterteinment_indices, history_indices = [], []

for index, fn in enumerate(sorted(set(novel_names))):
    print fn
    if "Entertainment" in fn:
        enterteinment_indices.append(index)
    elif "History" in fn:
        history_indices.append(index)

entreteinment_avg = np.mean(doctopic[enterteinment_indices, :], axis=0)

history_avg = np.mean(doctopic[history_indices, :], axis=0)

keyness = np.abs(entreteinment_avg - history_avg)

ranking = np.argsort(keyness)[::-1]  # from highest to lowest; [::-1] reverses order in Python sequences

# distinctive topics:
print ranking[:10]
