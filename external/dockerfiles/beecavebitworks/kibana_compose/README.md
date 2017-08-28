## Kibana/ElasticSearch/Fluentd container setup
An easy, lightweight Kibana/ElasticSearch/Fluentd setup.  Perfect for a developer wanting to view their logs in Kibana. All 3 containers run on Alpine Linux.

```
docker-compose build
docker-compose up
```
Then fire up your application in a container using the built-in fluentd plugin in docker tools.  For example, if you have a Rails application in image 'myrails', running with a command similar to the following.

```
docker run --rm  -p 3000:3000 --log-driver=fluentd  myrails
```

When you first view Kibana in your browser, you will need to create the index, and thus will be shown the settings page.
Ensure that the fields read as follows and click the 'Create' button.
 - (yes) Index contains time based
 - Index name: logstash-*
 - Time field: @timestamp

## Parsing and Custom Fields
To get the most out of Kibana, you can configure data context for your situation:
 - At the source: If your application can log in JSON format, configuration further down the line gets easier.
 - Fluentd : Refer to [Fluentd docs](http://www.fluentd.org/guides/recipes/parse-syslog) on how to parse your data.
 - Elastic : Refer to [Elastic docs](https://www.elastic.co/guide/en/elasticsearch/guide/current/index-templates.html) for defining templates for your data schema.
 
Image sizes:
```
kibanacompose_fluentd              latest                  b2851afaa395        6 hours ago         55.83 MB
kibanacompose_kibana               latest                  a2899c1e9e16        6 hours ago         112.5 MB
kibanacompose_elastic              latest                  5089269c4bf0        5 weeks ago         152.7 MB
```
