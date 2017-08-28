# coding: utf-8
"""
magicloop Pipeline 

.. module:: magicloop

   :synopsis: magicloop pipeline

.. moduleauthor:: Adolfo De Unánue <nanounanue@gmail.com>
"""

import os

import subprocess

import pandas as pd

import csv

import datetime

import luigi
import luigi.s3

import sqlalchemy

## Variables de ambiente
from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv())


## Logging
import magicloop.config_ini

import logging

logger = logging.getLogger("dpa-template.magicloop")


import magicloop.pipelines.utils
import magicloop.pipelines.common



class magicloopPipeline(luigi.WrapperTask):
    """
    Task principal para el pipeline 
    """

    def requires(self):
        yield PySparkTask()

class RTask(luigi.Task):

    root_path = luigi.Parameter()

    def requires(self):
        return RawData()

    def run(self):
        cmd = '''
              docker run --rm --network magicloop_net -v magicloop_store:/magicloop/data  magicloop/test-r 
        '''

        logger.debug(cmd)

        out = subprocess.check_output(cmd, shell=True)

        logger.debug(out)

    def output(self):
        return luigi.LocalTarget(os.path.join(os.getcwd(), "data", "hola_mundo_desde_R.psv"))


class PythonTask(luigi.Task):

    def requires(self):
        return RTask()

    def run(self):
        cmd = '''
              docker run --rm --network magicloop_net  -v magicloop_store:/magicloop/data  magicloop/test-python --inputfile {} --outputfile {}
        '''.format(os.path.join("/magicloop/data", os.path.basename(self.input().path)),
                   os.path.join("/magicloop/data", os.path.basename(self.output().path)))

        logger.debug(cmd)

        out = subprocess.call(cmd, shell=True)

        logger.debug(out)

    def output(self):
        return luigi.LocalTarget(os.path.join(os.getcwd(), "data", "hola_mundo_desde_python.json"))


class PySparkTask(luigi.Task):
    def requires(self):
        return PythonTask()

    def run(self):
        cmd = '''
              docker run --rm --network magicloop_net -v magicloop_store:/magicloop/data magicloop/test-pyspark --master {} --input {} --output {}
        '''.format("spark://master:7077",
                   os.path.join("/magicloop/data", os.path.basename(self.input().path)),
                   os.path.join("/magicloop/data", os.path.basename(self.output().path)))

        logger.debug(cmd)

        out = subprocess.call(cmd, shell=True)

        logger.debug(out)

    def output(self):
        return luigi.LocalTarget(os.path.join(os.getcwd(), "data", "hola_mundo_desde_pyspark"))

class SqoopTask(luigi.Task):
    def requires(self):
        return HadoopTask()

    def run(self):
        cmd = '''
                docker run --rm --network magicloop_net -v magicloop_store:/magicloop/data magicloop/test-pyspark --master {} --input {} --output {}
        '''

        logger.debug(cmd)

        out = subprocess.call(cmd, shell=True)

        logger.debug(out)

    def output(self):
        return luigi.LocalTarget("hola_mundo_desde_sqoop.txt")

class HadoopTask(luigi.Task):
    def requires(self):
        return PySparkTask()

    def run(self):
        cmd = '''
                docker run --rm --network magicloop_net -v magicloop_store:/magicloop/data magicloop/test-pyspark --master {} --input {} --output {}
        '''

        logger.debug(cmd)

        out = subprocess.call(cmd, shell=True)

        logger.debug(out)


    def output(self):
        return luigi.LocalTarget("hola_mundo_desde_hadoop.txt")

class RawData(luigi.ExternalTask):
    def output(self):
        return luigi.LocalTarget("./data/raw_data.txt")


