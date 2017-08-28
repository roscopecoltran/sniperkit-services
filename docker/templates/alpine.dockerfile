{%- block has_snippet %}
###########################################################################
#		  
#  Build the image:                                               		  
#    $ docker build -t {{ container_name }}:{{ container_tag }} --no-cache . 	# longer but more accurate
#    $ docker build -t {{ container_name }}:{{ container_tag }} . 				# faster but increase mistakes
#                                                                 		  
#  Run the container:                                             		  
#    $ docker run -ti --rm --env-file .env -v $(pwd)/data:/data \
#                 -v $(pwd):/home/{{ container_username }} {{ container_name }}:{{ container_tag }}
#
#  Inside the container:                                                        
#    $ pip install --no-cache --no-cache-dir -e .
#    $ pip install --no-cache --no-cache-dir -r requirements.dev.txt
#    $ pip install --no-cache --no-cache-dir -r requirements.alpha.txt
#    $ jq data.json
#                                                              		  
###########################################################################
{% endblock %}

# refs:
#  - 

{% block from -%}
FROM {{ name }}:{{ tag }}
{% endblock %}
LABEL maintainer "{{ maintainer.name }} <{{ maintainer.email }}>"

## #################################################################
## Build - Container user
## #################################################################

ARG DOCKER_USER="{{ username }}"
ARG DOCKER_USER_GID=${DOCKER_USER_GID:-"1000"}
ARG DOCKER_USER_UID=${DOCKER_USER_UID:-"1000"}

{%- block update_and_setup %}

{%- block alpine_base %}

## #################################################################
## Build - APK dependencies
## #################################################################

ARG APK_RUNTIME=${APK_RUNTIME:-"{{ container.alpine.apk.runtime.list }}"}
ARG APK_BUILD=${APK_BUILD:-"{{ container.alpine.apk.build.list }}"}
ARG APK_EXTRA=${APK_EXTRA:-"{{ container.alpine.apk.extra.list }}"}

ARG IMPORT_APK_RUNTIME=${IMPORT_APK_RUNTIME:-{{ container.alpine.apk.runtime.add }}}
ARG IMPORT_APK_BUILD=${IMPORT_APK_BUILD:-{{ container.alpine.apk.build.add }}}
ARG IMPORT_APK_EXTRA=${IMPORT_APK_EXTRA:-{{ container.alpine.apk.extra.add }}}

ARG REMOVE_APK_BUILD=${REMOVE_APK_BUILD:-{{ container.alpine.apk.build.remove }}}
ARG REMOVE_APK_EXTRA=${REMOVE_APK_EXTRA:-{{ container.alpine.apk.extra.remove }}}

{% endblock %}

{%- block is_python %}

## #################################################################
## Build - Py-PIP dependencies
## #################################################################

ARG USE_PIP_CYTHON=${BUILD_CYTHON:-{{ has_pip_cython }}}
ARG USE_PIP_NUMPY=${USE_PIP_NUMPY:-{{ has_pip_numpy }}}
ARG IMPORT_PIP_REQUIREMENTS_FILE=${USE_PIP_REQ:-{{ has_pip_requirements }}}

{% endblock %}

{%- block has_user %}

## #################################################################
## Build - Set env variables (inherit username from build args)
## #################################################################

## Docker - USER
ENV DOCKER_USER_HOME=${DOCKER_USER_HOME:-"/home/$DOCKER_USER"} \
	DOCKER_USER=${DOCKER_USER:-"{{ container_username }}"}

{% endblock %}

## Docker - Runtime env. variables
ENV \
	HOME=${DOCKER_USER_HOME:-"{{ container_home }}"} \
	\
	LANG=C.UTF-8 \
    PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

{% endblock %}

## #################################################################
## Create user + Install runtime dependencies
## #################################################################

ADD ./sniperkit/requirements.txt ${DOCKER_USER_HOME}/requirements.txt

# set -ex \    
RUN \
           echo -e "  ________________________________________________________________________________" \
        && echo -e " |" \
        && echo -e " | *** SniperKit - Python - Core *** " \
        && echo -e " |" \
        && echo -e " |- IMPORT_APK_RUNTIME:             ${IMPORT_APK_RUNTIME} " \
        && echo -e " |- IMPORT_APK_BUILD:               ${IMPORT_APK_BUILD} " \
        && echo -e " |- IMPORT_APK_EXTRA:               ${IMPORT_APK_EXTRA} " \
        && echo -e " |" \
        && echo -e " |- REMOVE_APK_BUILD:               ${REMOVE_APK_BUILD} " \
        && echo -e " |- REMOVE_APK_EXTRA:               ${REMOVE_APK_EXTRA} " \
        && echo -e " |" \
        && echo -e " |- USE_PIP_CYTHON:                 ${USE_PIP_CYTHON} " \
        && echo -e " |- IMPORT_PIP_REQUIREMENTS_FILE:   ${IMPORT_PIP_REQUIREMENTS_FILE} " \
        && echo -e " |" \
        && echo -e " |________________________________________________________________________________" \
    \
    && if [ ${IMPORT_APK_RUNTIME} == TRUE ]; then apk add --no-cache --update --no-progress ${APK_RUNTIME} ; fi \
    && if [ ${IMPORT_APK_BUILD} == TRUE ]; then apk add --no-cache --update --no-progress --virtual .build_dependencies ${APK_BUILD} ; fi \
    && if [ ${IMPORT_APK_EXTRA} == TRUE ]; then apk add --no-cache --update --no-progress ${EXTRA_APK} ; fi \
    \
    && if [ ${USE_PIP_CYTHON} == TRUE ]; then pip install --no-cache-dir --no-cache Cython ; fi \
    && if [ ${USE_PIP_CYTHON} == TRUE ]; then pip install --no-cache-dir --no-cache numpy ; fi \
    \
    && if [ ${IMPORT_PIP_REQUIREMENTS_FILE} == TRUE ]; then pip install --no-cache -r ${DOCKER_USER_HOME}/requirements.txt ; fi \
    \
    && if [ ${REMOVE_APK_BUILD} == TRUE ]; then  apk del --no-cache .build_dependencies ; fi \
	\
    && adduser \
        -h $DOCKER_USER_HOME \
        -u $DOCKER_USER_GID \
        -s /usr/sbin/nologin \
        -D \
        $DOCKER_USER     

{%- block is_copy_root %}
## #################################################################
## Copy sources
## #################################################################

# Copy source code to the container & build it
COPY . ${DOCKER_USER_HOME}
WORKDIR ${DOCKER_USER_HOME}
{% endblock %}

{%- block update_and_setup %}
{% endblock %}

{%- block volumes %}
VOLUME {{ container_volume_data }}
VOLUME {{ container_volume_app }}
VOLUME {{ container_volume_conf }}
{% endblock %}

WORKDIR ${DOCKER_USER_HOME}/build/docker

{%- block workdir %}
WORKDIR /dbuilder/build/
{% endblock -%}

{% macro run_script(name) -%}
ADD {{name}} /dbuilder/bin/{{name}}
ENTRYPOINT /dbuilder/bin/{{name}}
{% endmacro %}

{% macro run_cmd(name) -%}
CMD ["{{name}}"]
{% endmacro %}

{%- block custom %}
{% endblock -%}