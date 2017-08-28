# Mesos Marathon in Docker containers

To run Mesos-Marathon with Nginx proxy in order to hide the Marathon UI:

```
docker-compose -f gb-marathon-withproxy.yml up -d
```



To run Mesos-Marathon with default Marathon UI:

```
docker-compose -f gb-marathon-noproxy.yml up -d
```


Mesos UI: http://your-server:5050

Marathon UI: http://your-server:8080


To launch a Marathon app:

```
curl -X POST http://127.0.0.1:8080/v2/apps -d @app-webserver.json -H "Content-type: application/json"
```
