# Getting started with ZXInfo App
This tutorial shows you the steps required to get your own instance of the ZXDB based frontend app `ZXInfo` up and running, using Docker technology.

The frontend is running here: http://sinclair.kolbeck.dk

## Requirements
To get up and running you will need the following:
* Docker for your platform, get it on [docker.com](https://www.docker.com/)
* ZXDB database script, created by Einar Saukas found [here](https://www.dropbox.com/sh/bgtoq6tdwropzzr/AAAuMt4OlA_RicOBgwQLopoMa/ZXDB?dl=0), read about it on [WOS Forum](https://www.worldofspectrum.org/forums/discussion/52951/database-model-zxdb)
* The following github repositories
	* [ZXInfo-DB](https://github.com/thomasheckmann/zxinfo-db) - MariaDB populated with ZXDB database. Only required for building the Elasticsearch instance.
	* [ZXInfo-ES](https://github.com/thomasheckmann/zxinfo-es) - Elasticsearch with searchable documents, uses ZXInfo-DB for creating documents to be indexed.
	* [ZXInfo-Services](https://github.com/thomasheckmann/zxinfo-services) - Backend API for common queries, uses ZXInfo-DB
	* [ZXInfo-App](https://github.com/thomasheckmann/zxinfo-app) - Web Frontend App, uses ZXInfo-Services and ZXInfo-ES

## Architecture

## Step 01 - Getting ZXDB database up and running
To get the ZXDB database up and running, follow the guide for [ZXInfo-DB project](https://github.com/thomasheckmann/zxinfo-db/)

## Step 02 - Generate Elasticsearch instance
First you need an instance of Elasticsearch running, it is recommended to use the instance as defined by [ZXInfo App](https://github.com/thomasheckmann/zxinfo-app). Start Elasticserch with
```
docker-compose run -d --service-ports zxinfo-es
```
or if Alpine version is preferred
```
docker-compose --file docker-compose-alpine.yaml run -d --service-ports zxinfo-es-alpine
```

When Elasticsearch is up and running, continue with the guide for [ZXInfo-ES project](https://github.com/thomasheckmann/zxinfo-es/) to create and index documents.

## Step 03 - Get it all running
Finally follow the guide for [ZXInfo-App](https://github.com/thomasheckmann/zxinfo-app/) to get it all up and running.

test: http://localhost:8200/

## Development

