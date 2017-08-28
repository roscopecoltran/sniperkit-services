docker rm -f elk
docker run -d --name elk -ti -p 5601:5601 -p 5044:5044 alpine-elk
docker logs -f elk
