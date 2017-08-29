#!/usr/bin/env bash

export OUT_DIR=$(pwd)/out
export CA_DIR=./../../elasticsearch/security/self-signing-CA/

rm -rf $OUT_DIR
mkdir -p $OUT_DIR

cp $CA_DIR/kibana_ca.crt $OUT_DIR

# Node
# Step 1: Generate a NON-PASSWORD-PROTECTED node private key (kibana does not seem to support it will write bug report)
openssl genrsa -out $OUT_DIR/kibana_pk.pem 2048

# Step 2: Generate the node certificate signing request (csr)
openssl req -batch -new -days 1828 -key $OUT_DIR/kibana_pk.pem -set_serial 05 \
            -subj '/CN=ebms-er-portal-019147.cloudapp.net' -out $OUT_DIR/kibana.csr

## Sign node CSR with our CA
openssl x509 -passin pass:atomic -req -days 1828 -in $OUT_DIR/kibana.csr -CA $CA_DIR/ca.crt \
             -CAkey $CA_DIR/pk.pem -set_serial 05 -out $OUT_DIR/kibana.crt

#more secure way to generate our private key but for now kibana.yml does not seem to support private keys that are password protected
### Step 1: Generate a PASSWORD-PROTECTED node private key with not password protection
##openssl genrsa -passout pass:atomic -des3 -out $OUT_DIR/datavisualization_pk.pem 2048
### Step 2: Generate the node certificate signing request (csr)
##openssl req -passin pass:atomic -batch -new -days 1828 -key $OUT_DIR/datavisualization_pk.pem -set_serial 03 \
##            -subj '/CN=datavisualization.jedi.local' -out $OUT_DIR/datavisualization.csr
