docker-es-demo-data
===================

[![CircleCI](https://circleci.com/gh/blacktop/docker-es-demo-data.png?style=shield)](https://circleci.com/gh/blacktop/docker-es-demo-data) [![License](https://img.shields.io/badge/licence-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0) [![Docker Stars](https://img.shields.io/docker/stars/blacktop/es-data.svg)](https://hub.docker.com/r/blacktop/es-data/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacktop/es-data.svg)](https://hub.docker.com/r/blacktop/es-data/) [![Docker Image](https://img.shields.io/badge/docker%20image-24.2MB-blue.svg)](https://hub.docker.com/r/blacktop/es-data/)

> Nginx Demo Data for Elasticsearch

---

### Dependencies

-	[alpine:3.6](https://hub.docker.com/_/alpine/)

### Image Tags

```bash
REPOSITORY          TAG                 SIZE
blacktop/es-data   latest              24.2MB
blacktop/es-data   5.5                 24.2MB
blacktop/es-data   5.0                 21.1MB
```

### Getting Started

Add Nginx Demo Data to Your Elasticsearch cluster

```bash
$ docker run -d --name elastic -p 9200:9200 blacktop/elasticsearch:geoip
$ docker run -d --name kibana --link elastic:elasticsearch -p 5601:5601 blacktop/kibana
$ docker run --rm --link elastic:elasticsearch blacktop/es-data
```

> **NOTE:** To use with an **x-pack** image use the env vars to set the creds like so

```bash
$ docker run -d --name elasticsearch -p 9200:9200 blacktop/elasticsearch:x-pack
$ docker run -d --name kibana --link elasticsearch -p 5601:5601 blacktop/kibana:x-pack
$ docker run --rm --link elasticsearch -e ES_USERNAME=elastic -e ES_PASSWORD=changeme blacktop/es-data
```

![es-data](https://raw.githubusercontent.com/blacktop/docker-es-demo-data/master/add-data-dashboard.png)

To use with a non-docker Elasticsearch node

```bash
$ docker run --rm -e ES_URL=http://localhost:9200 blacktop/es-data
```

### Issues

Find a bug? Want more features? Find something missing in the documentation? Let me know! Please don't hesitate to [file an issue](https://github.com/blacktop/docker-es-demo-data/issues/new)

### Credits

-	https://github.com/elastic/examples/tree/master/ElasticStack_NGINX-json

### CHANGELOG

See [`CHANGELOG.md`](https://github.com/blacktop/docker-es-demo-data/blob/master/CHANGELOG.md)

### Contributing

[See all contributors on GitHub](https://github.com/blacktop/docker-es-demo-data/graphs/contributors).

Please update the [CHANGELOG.md](https://github.com/blacktop/docker-es-demo-data/blob/master/CHANGELOG.md) and submit a [Pull Request on GitHub](https://help.github.com/articles/using-pull-requests/).

### License

Apache License (Version 2.0) Copyright (c) elastic.co
