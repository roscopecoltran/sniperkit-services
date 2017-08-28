__author__ = 'eduardomartinez'
# coding: utf-8
# to run, export PYTHONPATH = 'esta carpeta'
# luigi --module inicio_luigi IrisPipeline --local-scheduler

import luigi
import numpy as np
import json
import os
import subprocess

# import pandas as pd
# from sklearn.cross_validation import train_test_split

from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv())

## Logging
#import magicloop.config_ini

import logging
#logger = logging.getLogger("dpa-template.magicloop")
#logger = logging.getLogger()
logging.basicConfig(filename='magicloop_pers.log',level=logging.ERROR)
logger = logging.getLogger()

import magicloop.pipelines.utils
import magicloop.pipelines.common

class IrisPipeline(luigi.WrapperTask):
    def requires(self):
        logger.info("Requires IrisPipeline")
        return {'lr':LogisticRegressionTask(),
                'knn':KNeighborsClassifierTask(),
                'dt':DecisionTreeClassifierTask(),
                'svc':SVCTask()}

#task
class LogisticRegressionTask(luigi.Task):
    root_path=luigi.Parameter()
    model_name=luigi.Parameter()
    C_logspacestart=luigi.Parameter()
    C_logspacestop=luigi.Parameter()
    C_logspacensamples=luigi.Parameter()
    seed = luigi.Parameter()
    validation_size = luigi.Parameter()

    def requires(self):
        logger.info("Requires LogisticRegression")
        return IrisData()

    def run(self):

        logger.info("Start LogisticRegression")
        # leer archivo
        # transformar en df
        # df = pd.read_csv(self.input().path)
        # logger.info("Input {}".format(self.input().path))
        # logger.info("Output {}".format(self.output()['json'].path))

        array = np.logspace(int(self.C_logspacestart),int(self.C_logspacestop),int(self.C_logspacensamples))

        params={}
        params['C'] = array.tolist()
        # dict(C=np.logspace(int(self.C_logspacestart),int(self.C_logspacestop),int(self.C_logspacensamples)))
        logger.debug(params)

        ## Save params to json
        params_file="/_{}_params.json".format(self.model_name)
        # print("json/json: {}".format(params))
        with open(self.root_path+params_file, 'w', encoding='utf8') as outfile:
            str_ = json.dumps(params,
                              indent=4, sort_keys=True,
                              separators=(',', ': '), ensure_ascii=False)
            outfile.write(str_)

        ## Train model using docker
        # --network magicloop_net
        cmd = '''
              docker run --rm  -v magicloop_store:/magicloop/data magicloop/test-python --inputfile {} --seed {} --validationsize {} --modelname {} --inputparams {} --outputpickle {} --outputjson {}
        '''.format(os.path.join("/magicloop/data", os.path.basename("/iris.csv")),
                   self.seed,
                   self.validation_size,
                   self.model_name,
                   os.path.join("/magicloop/data", os.path.basename(params_file)),
                   os.path.join("/magicloop/data", os.path.basename("/iris_model_{}.pl".format(self.model_name))),
                   os.path.join("/magicloop/data", os.path.basename("/iris_model_{}.json".format(self.model_name))))

        logger.debug(cmd)
        out = subprocess.call(cmd, shell=True)
        logger.debug(out)

    def output(self):
        logger.info("Output LogisticRegression")
        return { 'pl' : luigi.LocalTarget(self.root_path+"/iris_model_{}.pl".format(self.model_name)),
                 'json' : luigi.LocalTarget(self.root_path+"/iris_model_{}.json".format(self.model_name)) }

#task
class KNeighborsClassifierTask(luigi.Task):
    root_path=luigi.Parameter()
    model_name=luigi.Parameter()
    n_neighborsStart=luigi.Parameter()
    n_neighborsStop=luigi.Parameter()
    seed = luigi.Parameter()
    validation_size = luigi.Parameter()

    def requires(self):
        logger.info("Requires KNeighborsClassifier")
        return IrisData()

    def run(self):

        logger.info("Start KNeighborsClassifier")
        # leer archivo
        # transformar en df
        # df = pd.read_csv(self.input().path)
        # logger.info("Input {}".format(self.input().path))
        # logger.info("Output {}".format(self.output()['json'].path))

        array = np.arange(int(self.n_neighborsStart),int(self.n_neighborsStop))

        params={}
        params['n_neighbors'] = array.tolist()
        # dict(C=np.logspace(int(self.C_logspacestart),int(self.C_logspacestop),int(self.C_logspacensamples)))
        logger.debug(params)

        ## Save params to json
        params_file="/_{}_params.json".format(self.model_name)
        # print("json/json: {}".format(params))
        with open(self.root_path+params_file, 'w', encoding='utf8') as outfile:
            str_ = json.dumps(params,
                              indent=4, sort_keys=True,
                              separators=(',', ': '), ensure_ascii=False)
            outfile.write(str_)

        ## Train model using docker
        # --network magicloop_net
        cmd = '''
              docker run --rm  -v magicloop_store:/magicloop/data magicloop/test-python --inputfile {} --seed {} --validationsize {} --modelname {} --inputparams {} --outputpickle {} --outputjson {}
        '''.format(os.path.join("/magicloop/data", os.path.basename("/iris.csv")),
                   self.seed,
                   self.validation_size,
                   self.model_name,
                   os.path.join("/magicloop/data", os.path.basename(params_file)),
                   os.path.join("/magicloop/data", os.path.basename("/iris_model_{}.pl".format(self.model_name))),
                   os.path.join("/magicloop/data", os.path.basename("/iris_model_{}.json".format(self.model_name))))

        logger.debug(cmd)
        out = subprocess.call(cmd, shell=True)
        logger.debug(out)

    def output(self):
        logger.info("Output KNeighborsClassifier")
        return { 'pl' : luigi.LocalTarget(self.root_path+"/iris_model_{}.pl".format(self.model_name)),
                 'json' : luigi.LocalTarget(self.root_path+"/iris_model_{}.json".format(self.model_name)) }

#task
class DecisionTreeClassifierTask(luigi.Task):
    root_path=luigi.Parameter()
    model_name=luigi.Parameter()
    criterion=luigi.Parameter()
    max_features=luigi.Parameter()
    seed = luigi.Parameter()
    validation_size = luigi.Parameter()

    def requires(self):
        logger.info("Requires DecisionTreeClassifier")
        return IrisData()

    def run(self):

        logger.info("Start DecisionTreeClassifier")
        # leer archivo
        # transformar en df
        # df = pd.read_csv(self.input().path)
        # logger.info("Input {}".format(self.input().path))
        # logger.info("Output {}".format(self.output()['json'].path))

        params={}
        params['criterion'] = self.criterion.split(',')
        params['max_features'] = self.max_features.split(',')
        # dict(C=np.logspace(int(self.C_logspacestart),int(self.C_logspacestop),int(self.C_logspacensamples)))
        logger.debug(params)

        ## Save params to json
        params_file="/_{}_params.json".format(self.model_name)
        # print("json/json: {}".format(params))
        with open(self.root_path+params_file, 'w', encoding='utf8') as outfile:
            str_ = json.dumps(params,
                              indent=4, sort_keys=True,
                              separators=(',', ': '), ensure_ascii=False)
            outfile.write(str_)

        ## Train model using docker
        # --network magicloop_net
        cmd = '''
              docker run --rm  -v magicloop_store:/magicloop/data magicloop/test-python --inputfile {} --seed {} --validationsize {} --modelname {} --inputparams {} --outputpickle {} --outputjson {}
        '''.format(os.path.join("/magicloop/data", os.path.basename("/iris.csv")),
                   self.seed,
                   self.validation_size,
                   self.model_name,
                   os.path.join("/magicloop/data", os.path.basename(params_file)),
                   os.path.join("/magicloop/data", os.path.basename("/iris_model_{}.pl".format(self.model_name))),
                   os.path.join("/magicloop/data", os.path.basename("/iris_model_{}.json".format(self.model_name))))

        logger.debug(cmd)
        out = subprocess.call(cmd, shell=True)
        logger.debug(out)

    def output(self):
        logger.info("Output DecisionTreeClassifier")
        return { 'pl' : luigi.LocalTarget(self.root_path+"/iris_model_{}.pl".format(self.model_name)),
                 'json' : luigi.LocalTarget(self.root_path+"/iris_model_{}.json".format(self.model_name)) }

#task
class SVCTask(luigi.Task):
    root_path=luigi.Parameter()
    model_name=luigi.Parameter()
    seed = luigi.Parameter()
    validation_size=luigi.Parameter()
    C_logspacestart=luigi.Parameter()
    C_logspacestop=luigi.Parameter()
    C_logspacensamples=luigi.Parameter()
    kernel=luigi.Parameter()

    def requires(self):
        logger.info("Requires SVC")
        return IrisData()

    def run(self):

        logger.info("Start SVC")
        # leer archivo
        # transformar en df
        # df = pd.read_csv(self.input().path)
        # logger.info("Input {}".format(self.input().path))
        # logger.info("Output {}".format(self.output()['json'].path))

        array = np.logspace(int(self.C_logspacestart),int(self.C_logspacestop),int(self.C_logspacensamples))

        params={}
        params['C'] = array.tolist()
        params['kernel'] = self.kernel.split(',')
        # dict(C=np.logspace(int(self.C_logspacestart),int(self.C_logspacestop),int(self.C_logspacensamples)))
        logger.debug(params)

        ## Save params to json
        params_file="/_{}_params.json".format(self.model_name)
        # print("json/json: {}".format(params))
        with open(self.root_path+params_file, 'w', encoding='utf8') as outfile:
            str_ = json.dumps(params,
                              indent=4, sort_keys=True,
                              separators=(',', ': '), ensure_ascii=False)
            outfile.write(str_)

        ## Train model using docker
        # --network magicloop_net
        cmd = '''
              docker run --rm  -v magicloop_store:/magicloop/data magicloop/test-python --inputfile {} --seed {} --validationsize {} --modelname {} --inputparams {} --outputpickle {} --outputjson {}
        '''.format(os.path.join("/magicloop/data", os.path.basename("/iris.csv")),
                   self.seed,
                   self.validation_size,
                   self.model_name,
                   os.path.join("/magicloop/data", os.path.basename(params_file)),
                   os.path.join("/magicloop/data", os.path.basename("/iris_model_{}.pl".format(self.model_name))),
                   os.path.join("/magicloop/data", os.path.basename("/iris_model_{}.json".format(self.model_name))))

        logger.debug(cmd)
        out = subprocess.call(cmd, shell=True)
        logger.debug(out)

    def output(self):
        logger.info("Output SVC")
        return { 'pl' : luigi.LocalTarget(self.root_path+"/iris_model_{}.pl".format(self.model_name)),
                 'json' : luigi.LocalTarget(self.root_path+"/iris_model_{}.json".format(self.model_name)) }

#external
class IrisData(luigi.ExternalTask):
    root_path = luigi.Parameter()

    def output(self):
        logger.info("Start IrisData")
        output_path = '{}/iris.csv'.format(self.root_path)
        logger.info("file {}".format(output_path))
        return luigi.LocalTarget(output_path)