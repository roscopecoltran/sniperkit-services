#!/usr/bin/env bash

export OUT_DIR=$(pwd)/out
export CA_DIR=./../self-signing-CA

rm -rf $OUT_DIR
mkdir -p $OUT_DIR

cp $CA_DIR/truststore.jks $OUT_DIR

# Node
# Generate a node private key
openssl genrsa -passout pass:atomic -des3 -out $OUT_DIR/node_pk.pem 2048

# generate the node certificate signing request (csr)
openssl req -passin pass:atomic -batch -new -days 1828 -key $OUT_DIR/node_pk.pem -set_serial 02 \
            -subj '/CN=ebms-er-portal-019147.cloudapp.net' -out $OUT_DIR/node.csr

## Sign node CSR with our CA
openssl x509 -passin pass:atomic -req -days 1828 -in $OUT_DIR/node.csr -CA $CA_DIR/ca.crt \
             -CAkey $CA_DIR/pk.pem -set_serial 04 -out $OUT_DIR/node.crt

openssl pkcs12 -export -passin pass:atomic -passout pass:atomic -in $OUT_DIR/node.crt \
               -inkey $OUT_DIR/node_pk.pem \
               -out $OUT_DIR/node_pk.p12 -name node_pk_p12 \
               -certfile $CA_DIR/ca.crt

## step two: Convert the pkcs12 file to a java keystore
keytool -importkeystore -deststorepass atomic -destkeypass atomic -destkeystore $OUT_DIR/keystore.jks \
        -srckeystore $OUT_DIR/node_pk.p12 -srcstoretype PKCS12 -srcstorepass atomic  \
        -alias node_pk_p12

## Place the nodes certificate in the keystore
keytool -importcert -noprompt -file $OUT_DIR/node.crt -alias node_node_cert \
        -keystore $OUT_DIR/keystore.jks -storepass atomic