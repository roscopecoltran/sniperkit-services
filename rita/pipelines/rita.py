# coding: utf-8
"""
rita Pipeline 

.. module:: rita

   :synopsis: rita pipeline

.. moduleauthor:: Adolfo De Unánue <nanounanue@gmail.com>
"""

import os

import subprocess

from pathlib import Path

import boto3
import zipfile
import io

import csv
import datetime

import luigi
import luigi.s3

import pandas as pd

import sqlalchemy

from contextlib import closing

import requests

import re

from bs4 import BeautifulSoup

## Variables de ambiente
from dotenv import load_dotenv, find_dotenv
load_dotenv(find_dotenv())

## Obtenemos las llaves de AWS
AWS_ACCESS_KEY_ID =  os.environ.get('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.environ.get('AWS_SECRET_ACCESS_KEY')

## Logging
import rita.config_ini

import logging

logger = logging.getLogger("rita.pipeline")


import rita.pipelines.utils

import rita.pipelines.common
from rita.pipelines.common.tasks import DockerTask

class ritaPipeline(luigi.WrapperTask):
    """
    Task principal para el pipeline 
    """

    def requires(self):
        yield DownloadRITACatalogs()
        yield DownloadRITAData()


class DownloadRITACatalogs(luigi.WrapperTask):
    """
    """

    def requires(self):
        baseurl = "https://www.transtats.bts.gov"
        url = "https://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236"
        page = requests.get(url)

        soup = BeautifulSoup(page.content, "lxml")
        for link in soup.find_all('a', href=re.compile('Download_Lookup')):
            catalog_name = link.get('href').split('=L_')[-1]
            catalog_url = '{}/{}'.format(baseurl, link.get('href'))
            yield DownloadCatalog(catalog_name=catalog_name, catalog_url=catalog_url)

class DownloadCatalog(luigi.Task):
    """
    """

    catalog_url = luigi.Parameter()
    catalog_name = luigi.Parameter()

    root_path =  luigi.Parameter()

    def run(self):
        logger.debug("Guardando en {} el catálogo {}".format(self.output().path, self.catalog_name))

        with closing(requests.get(self.catalog_url, stream= True)) as response, \
             self.output().open('w') as output_file:
            for chunk in response.iter_lines(chunk_size=1024*8):
                if chunk:
                    output_file.write(chunk.decode('utf-8') + '\n')


    def output(self):
        output_path = '{}/catalogs/{}.csv'.format(self.root_path,
                                                  self.catalog_name)
        return luigi.s3.S3Target(path=output_path)


class DownloadRITAData(luigi.WrapperTask):
    """
    """
    start_year=luigi.IntParameter()

    def requires(self):
        today = datetime.date.today() + datetime.timedelta(days=-90)

        max_year = today.year
        max_month = today.month

        years = range(self.start_year, max_year)

        logger.info("Descargando datos de los años {}".format(years))

        for año in years:
            if año != max_year:
                months = range(1,13)
            else:
                month = range(1, max_month+1)
            for mes in months:
                yield DownloadRITAMonthlyData(year=año, month=mes)


class DownloadRITAMonthlyData(DockerTask):
    """
    """
    year = luigi.IntParameter()
    month = luigi.IntParameter()

    root_path = luigi.Parameter()
    raw_path = luigi.Parameter()

    @property
    def cmd(self):
        return '''
               docker run --rm --env AWS_ACCESS_KEY_ID={} --env AWS_SECRET_ACCESS_KEY={} rita/download-rita --year {} --month {} --data_path {}/{} 
        '''.format(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, self.year, self.month, self.root_path, self.raw_path)

    def output(self):
        return luigi.s3.S3Target(path='{}/{}/{}-{}.zip'.format(self.root_path,
                                                               self.raw_path,
                                                               str(self.month).zfill(2),
                                                               self.year))



class ExtractColumns(luigi.Task):
    """
    """

    task_name = "extract-columns"

    year = luigi.IntParameter()
    month = luigi.IntParameter()

    root_path = luigi.Parameter()
    bucket = luigi.Parameter()
    etl_path = luigi.Parameter()

    def requires(self):
        return DownloadRITA(year=self.year, month=self.month)

    def run(self):

        s3 = boto3.resource('s3')

        bucket = s3.Bucket(self.bucket)

        input_path = Path(self.input().path)

        obj = bucket.Object(str(input_path.relative_to('s3://{}'.format(self.bucket))))

        df = None

        with io.BytesIO(obj.get()["Body"].read()) as input_file:
            input_file.seek(0)
            with zipfile.ZipFile(input_file, mode='r') as zip_file:
                for subfile in zip_file.namelist():
                    with zip_file.open(subfile) as file:
                        df = pd.read_csv(file)

        with self.output().open('w') as output_file:
            output_file.write(df.loc[:, 'YEAR':'DIV_AIRPORT_LANDINGS'].to_csv(None,
                                                                              sep="|",
                                                                              header=True,
                                                                              index=False,
                                                                              encoding="utf-8",
                                                                              quoting=csv.QUOTE_ALL))

    def output(self):
        return luigi.s3.S3Target('{}/{}/{}/YEAR={}/{}.psv'.format(self.root_path,
                                                                  self.etl_path,
                                                                  self.task_name,
                                                                  self.year,
                                                                  str(self.month).zfill(2)))


class RTask(luigi.Task):

    root_path = luigi.Parameter()

    def requires(self):
        return RawData()

    def run(self):
        cmd = '''
              docker run --rm -v rita_store:/rita/data  rita/test-r 
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
              docker run --rm -v rita_store:/rita/data  rita/test-python --inputfile {} --outputfile {}
        '''.format(os.path.join("/rita/data", os.path.basename(self.input().path)),
                   os.path.join("/rita/data", os.path.basename(self.output().path)))

        logger.debug(cmd)

        out = subprocess.call(cmd, shell=True)

        logger.debug(out)

    def output(self):
        return luigi.LocalTarget(os.path.join(os.getcwd(), "data", "hola_mundo_desde_python.json"))




