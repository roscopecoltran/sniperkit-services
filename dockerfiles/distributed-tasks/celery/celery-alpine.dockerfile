
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t celery --no-cache . 									# longer but more accurate
#    $ docker build -t celery . 											# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -v $(pwd)/shared:/data -p 9002:9002 celery
#    $ docker run -d --name celery -p 9002:9002 -v $(pwd)/shared:/data celery
#                                                              		  
###########################################################################

FROM python:3.6-alpine3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

