# coding: utf-8

import os

import subprocess

import luigi
import luigi.s3

## Logging
import rita.config_ini

import logging

logger = logging.getLogger("rita.pipeline")



class DockerTask(luigi.Task):
    """
    Clase genérica para ejecutar Tasks dentro de contenedores de Docker
    """

    def run(self):
        logger.debug(self.cmd)

        out = subprocess.check_output(self.cmd, shell=True)

        logger.debug(out)
