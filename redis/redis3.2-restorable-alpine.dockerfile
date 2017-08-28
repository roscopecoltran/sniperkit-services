
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t redis-restorable:3.2-alpine3.6 --no-cache .    		# longer but more accurate
#    $ docker build -t redis-restorable:3.2-alpine3.6 .    					# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 6379:6379 redis:3.2-alpine3.6
#    $ docker run -it -p 6379:6379 -v $(pwd)/shared:/shared --name redis-restorable redis-restorable:3.2-alpine3.6
#                                                              		  
###########################################################################

FROM		redis:3.2-alpine
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"
LABEL		version="2.0.0"

RUN sed -ie '/chown -R redis \./ i \
AOF_FILE="/restore/appendonly.aof"; \
if [ -f "$AOF_FILE" ]; then \
	echo; \
	echo "Restore requested, processing ..."; \
	mv $AOF_FILE /data/appendonly.aof.restore && mv /data/appendonly.aof.restore /data/appendonly.aof && echo "Done" || echo "Failed"; \
	echo; \
	echo "Redis restore process done. Ready for start up."; \
	echo; \
fi;' /usr/local/bin/docker-entrypoint.sh

VOLUME /restore

CMD ["redis-server", "--appendonly", "yes"]