NOTES  
=====

 * https://www.elastic.co/guide/en/beats/libbeat/current/export-dashboards.html
 * https://github.com/elastic/beats/tree/master/dev-tools
 * https://github.com/elastic/beats-dashboards/blob/master/save/kibana_dump.py

To run with Vagrant

```bash
$ vagrant up --provider virtualbox
$ docker run --rm -e ES_URL=http://192.168.33.10:9200 blacktop/es-data
```

Next data set I want to try

 * https://github.com/elastic/examples/tree/master/ElasticStack_graph_apache
