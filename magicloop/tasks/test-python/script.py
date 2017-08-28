#!/usr/bin/env python


import sys
import os

import numpy as np
import pandas as pd
import click

from sklearn.externals import joblib
import json

from sklearn.cross_validation import train_test_split
from sklearn.grid_search import GridSearchCV
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC

@click.command()
@click.option('--inputfile', type=click.Path())
@click.option('--seed', type=click.INT)
@click.option('--validationsize', type=click.FLOAT)
@click.option('--modelname', type=click.STRING)
@click.option('--inputparams', type=click.Path())
@click.option('--outputpickle', type=click.Path())
@click.option('--outputjson', type=click.Path())
def main(inputfile,seed,validationsize,modelname,inputparams,outputpickle,outputjson):
	#print("{}, {}".format(name,params))
	print("inicia LogisticRegression en docker")
	df = pd.read_csv(inputfile)
	print("archivo {}".format(inputfile))

	X = df[['sepal_length','sepal_width','petal_length','petal_width']]
	Y = df[['class']]
	X_train, X_validation, Y_train, Y_validation = train_test_split(X, Y, test_size=validationsize, random_state=seed)

	print("Separado")
	model = {
	'LogisticRegression':LogisticRegression(),
	'KNeighborsClassifier':KNeighborsClassifier(),
	'DecisionTreeClassifier':DecisionTreeClassifier(),
	'SVC':SVC()}[modelname]

	json1_file = open(inputparams)
	json1_str = json1_file.read()
	modelParams = json.loads(json1_str)
	print("model params: {}".format(modelParams))
	# print(type(modelParams['C']))

	#print("X shape {}".format(X_train.shape))
	#print("Y shape {}".format(Y_train.values().ravel().shape))



	clf = GridSearchCV(estimator=model, param_grid=modelParams,n_jobs=-1)
	clf.fit(X_train, Y_train.ix[:,'class'])
	tstscore=clf.score(X_validation, Y_validation.ix[:,'class'])
	print("{}, Train score:{}, Val score:{}".format(modelname,clf.best_score_,tstscore))


	### SAVE PICKLE
	#archivo="{}.pl".format(modelName)
	joblib.dump(clf.best_estimator_, outputpickle, compress = 1)

	#model_reloaded = joblib.load(archivo)
	#print("Pickle: Val score: {}".format(model_reloaded.score(X_validation, Y_validation)))

	### SAVE JSON
	hiperparams={}
	trueparams = clf.best_estimator_.get_params()
	# se aplica este filtro para solo poner los parametros que especifico el usuario
	for k in modelParams.keys():
		try:
			hiperparams[k]=trueparams.get(k).item()
		except:
			hiperparams[k]=trueparams.get(k)
	#archivo_json="{}.json".format(name)
	data=dict(algoritmo=modelname,hiperparametros=hiperparams,path=outputpickle,test_score=tstscore)
	print("json/json: {}".format(data))
	with open(outputjson, 'w', encoding='utf8') as outfile:
		str_ = json.dumps(data,
						indent=4, sort_keys=True,
						separators=(',', ': '), ensure_ascii=False)
		outfile.write(str_)
		#json.dump(data, outfile)	    



if __name__ == '__main__':
	main()