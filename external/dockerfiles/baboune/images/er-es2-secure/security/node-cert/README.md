Before you run this script you must ensure that the rta-security/certs 
directory contains a dcp_rta_ca.crt, dcp_rta_pk.pem and truststore.jks 

This script will create a new dcp self-signed certificate for our datastorage
nodes. Right now these certificates cannot be hostname verified i.e. we 
use the same secure cert for each node in the datastorage cluster as 
we do not have a DNS in JEDI this means we cannot trust the hostname
expect this to be fixed in the next release.

This script will run and will create an output directory called 
dcp_rta_datastorage_out. Copy the truststore and keystore java keystore 
files to the certs directory. The keystore is a password protected 
store of our public and private keys for the datastorage nodes and 
check them into git.

    > sh create_node_certificates.sh.sh
    > cp out/*.jks out/*.p12 .
    > git add and commit

The .p12 file can be used to load into as a browser cert or with curl requests if
you want to contact the now secure elasticsearch database.

Useful info: if firefox does not like your certificate and says 
'Your certificate contains the same serial number as another certificate issued by the certificate authority' 

    > cd ~/.mozilla/firefox/{profile-name}.default
    > rm cert8.db    --OR-- $ mv cert8.db cert8.db.bak
    > Restart Firefox


    

