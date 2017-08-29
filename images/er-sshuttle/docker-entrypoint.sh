#!/bin/sh


if [ "$1" = 'sshuttle' ]; then
  
  "$@"
          
else
    # As argument is not related to elasticsearch,
    # then assume that user wants to run his own process,
    # for example a `bash` shell to explore this image
    exec "$@"
fi

#echo $AUTHORIZED_KEYS > ${SSHUTTLE_HOME}/.ssh/authorized_keys
#chown sshuttle:sshuttle ${SSHUTTLE_HOME}/.ssh/authorized_keys
#chmod 600 ${SSHUTTLE_HOME}/.ssh/authorized_keys

#KEYS=

#for key in /etc/ssh/keys/*key; do
#    chmod -f 400 $key
#    KEYS="$KEYS -h $key"
#done

#exec /usr/sbin/sshd -D $KEYS