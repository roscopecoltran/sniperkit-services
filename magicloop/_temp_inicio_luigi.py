__author__ = 'eduardomartinez'
# Ejercicio de clase DPA, Algun dia de Abril 2017
# coding: utf-8
# to run, export PYTHONPATH = 'esta carpeta'
# luigi --module inicio_luigi IrisPipeline --local-scheduler

import luigi
import pandas as pd

class IrisPipeline(luigi.WrapperTask):
    def requires(self):
        return CsvToJson()

#task
class CsvToJson(luigi.Task):
    root_path = luigi.Parameter()

    def requires(self):
        return IrisData()

    def run(self):
        #with self.input().path.open('r') as input_file:

        #leer archivo
        # transformar en df
        df = pd.read_csv(self.input().path)
        # df to json
        df.to_json(self.output().path)

    def output(self):
        output_path = '{}/iris.json'.format(self.root_path)
        return luigi.LocalTarget(output_path)

#external
class IrisData(luigi.ExternalTask):
    root_path = luigi.Parameter()

    def output(self):
        output_path = '{}/iris.psv'.format(self.root_path)
        return luigi.LocalTarget(output_path)


#if __name__ == "__main__":
#    luigi.run(main_task_cls=IrisPipeline)