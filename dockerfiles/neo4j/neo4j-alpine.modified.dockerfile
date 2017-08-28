
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t neo4j:3.3-alpine3.6 --no-cache -f neo4j-alpine.dockerfile .   # longer but more accurate
#    $ docker build -t neo4j:3.3-alpine3.6 -f neo4j-alpine.dockerfile .    		 	 # faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 7474:7474 -p 7473:7473 -p 7687:7687 neo4j:3.3-alpine3.6
#    $ docker run -it -p 7474:7474 -p 7473:7473 -p 7687:7687 -v $(pwd)/shared:/shared --name sphinx neo4j:3.3-alpine3.6
#                                                              		  
###########################################################################

FROM neo4j:3.2
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

