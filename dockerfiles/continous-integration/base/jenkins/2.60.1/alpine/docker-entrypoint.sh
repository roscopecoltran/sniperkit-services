#! /bin/bash

install-plugins.sh $JENKINS_INSTALL_PLUGINS

curl -ksS https://afonsof.com/jenkins-material-theme/dist/material-$JENKINS_THEME_MATERIAL_COLOR.css >> $JENKINS_HOME/war/css/style.css;

/bin/tini -- /usr/local/bin/jenkins.sh