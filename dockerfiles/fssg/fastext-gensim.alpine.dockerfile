
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t fssg --no-cache . 									# longer but more accurate
#    $ docker build -t fssg . 												# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -it --rm -p 5000:5000 -v $(pwd)/shared:/shared fssg
#    $ docker run -d --name fssg -p 5000:5000 -v $(pwd)/shared:/shared fssg
#                                                              		  
###########################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

ARG FSSG_BLAS_VERSION=${FSSG_BLAS_VERSION:-"3.6.0"}
ARG FSSG_LAPACK_VERSION=${FSSG_LAPACK_VERSION:-"3.6.1"}

WORKDIR /fssg

COPY ./src/app.py .

RUN apk add --no-cache --update wget py-pip python-dev musl-dev linux-headers g++ make gfortran ca-certificates \
	&& wget https://s3-us-west-1.amazonaws.com/fasttext-vectors/wiki.en.zip \
	&& ln -s /usr/include/locale.h /usr/include/xlocale.h \
	&& mkdir -p /tmp/build \
	&& cd /tmp/build \
	&& wget http://www.netlib.org/blas/blas-${FSSG_BLAS_VERSION}.tgz \
	&& wget http://www.netlib.org/lapack/lapack-${FSSG_LAPACK_VERSION}.tgz \
	&& tar xzf blas-${FSSG_BLAS_VERSION}.tgz \
	&& tar xzf lapack-${FSSG_LAPACK_VERSION}.tgz \
	&& cd /tmp/build/BLAS-${FSSG_BLAS_VERSION}/ \
	&& gfortran -O3 -std=legacy -m64 -fno-second-underscore -fPIC -c *.f \
	&& ar r libfblas.a *.o \
	&& ranlib libfblas.a \
	&& mv libfblas.a /tmp/build/. \
	&& cd /tmp/build/lapack-${FSSG_LAPACK_VERSION}/ \
	&& sed -e "s/frecursive/fPIC/g" -e "s/ \.\.\// /g" -e "s/^CBLASLIB/\#CBLASLIB/g" make.inc.example > make.inc \
	&& make lapacklib \
	&& make clean \
	&& mv liblapack.a /tmp/build/. \
	&& cd /fssg \
	&& export BLAS=/tmp/build/libfblas.a \
	&& export LAPACK=/tmp/build/liblapack.a \
	&& pip --no-cache-dir install --upgrade pip cython \
	&& pip --no-cache-dir install --upgrade flask gensim fasttext spacy \
	&& rm -rf /tmp/build

EXPOSE 5000

CMD ["python", "/app/fssg.py", "-p", "5000", "-l", "en", "-m", "wiki.en.bin"]