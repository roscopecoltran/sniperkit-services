__author__ = 'eduardomartinez'
import pandas as pd
import numpy as np
from sklearn.externals import joblib
import json

from sklearn.cross_validation import train_test_split
from sklearn.grid_search import GridSearchCV
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC

'''
    Our old friend: *The Magic loop*, Ahora en su presentación de /pipeline/

    1.  Vamos a partir del =iris= /dataset/ y vamos a entrenar varios modelos para predecir la variable del tipo de flor.

    2. Estos modelos *no* pueden entrenar en serie. Cada modelo entrenará  en un =Task=, con parámetros:
      - Nombre del algoritmo
      - Hiperparámetros

    3. La salida de los =Task= debe de ser un archivo =pickle= llamado =nombre_algoritmo/nombre_algoritmo-lista-hiperparámetros.pl=
      y un archivo =json= con la siguiente estructura:

'''

df = pd.read_csv('iris.csv')

# enconde class to number for ML
catenc = pd.factorize(df['class'])
df['class_enc'] = catenc[0]

# Split-out validation dataset
array = df.values
X = array[:,0:4]
Y = array[:,4]
validation_size = 0.20
seed = 12345
X_train, X_validation, Y_train, Y_validation = train_test_split(X, Y, test_size=validation_size, random_state=seed)

# training
models = []
models.append(('LogisticRegression', LogisticRegression(),dict(C=np.logspace(-6, -1, 10))))
models.append(('KNeighborsClassifier', KNeighborsClassifier(),dict(n_neighbors=np.arange(2,10))))
models.append(('DecisionTreeClassifier', DecisionTreeClassifier(), dict(criterion=['gini','entropy'],max_features=['sqrt','log2', None])))
models.append(('SVC', SVC(), dict(C=np.logspace(-6, -1, 10), kernel=['linear', 'poly', 'rbf', 'sigmoid'])))

for name, model, params in models:
    ### GRID SEARCH
    # Computes the score during the fit of an estimator on a parameter grid and chooses the parameters to maximize the cross-validation score
    # By default uses 3 fold cross validation
    print("{}, {}".format(name,params))
    clf = GridSearchCV(estimator=model, param_grid=params,n_jobs=-1)
    clf.fit(X_train, Y_train)
    print("{}, Train score:{}, Val score:{}".format(name,clf.best_score_, clf.score(X_validation, Y_validation)))


    ### SAVE PICKLE
    archivo="{}.pl".format(name)
    joblib.dump(clf.best_estimator_, archivo, compress = 1)

    model_reloaded = joblib.load(archivo)
    print("Pickle: Val score: {}".format(model_reloaded.score(X_validation, Y_validation)))

    ### SAVE JSON
    hiperparams={}
    trueparams = clf.best_estimator_.get_params()
    # se aplica este filtro para solo poner los parametros que especifico el usuario
    for k in params.keys():
        try:
            hiperparams[k]=trueparams.get(k).item()
        except:
            hiperparams[k]=trueparams.get(k)
    archivo_json="{}.json".format(name)
    data=dict(algoritmo=name,hiperparametros=hiperparams,path=archivo)
    print("json/json: {}".format(data))
    with open(archivo_json, 'w', encoding='utf8') as outfile:
        str_ = json.dumps(data,
                          indent=4, sort_keys=True,
                          separators=(',', ': '), ensure_ascii=False)
        outfile.write(str_)
        #json.dump(data, outfile)
