#!/usr/bin/env bash

export OUT_DIR=$(pwd)/ca_out

rm -rf $OUT_DIR
mkdir -p $OUT_DIR

# Root CA
# Generate private key "dcp_rta_pk.pem"
openssl genrsa -passout pass:atomic -des3 -out $OUT_DIR/pk.pem 2048

# Generate new x509 certificate using the "pk.pem" private key
# -X509: self signed certificate which can be used as a self signed root CA
openssl req -passin pass:atomic -batch -new -x509 -days 1828  \
      -key $OUT_DIR/pk.pem -set_serial 01             \
      -out $OUT_DIR/ca.crt

# Place the CA Certificate Authority in the nodes truststore
keytool -importcert -noprompt -file $OUT_DIR/ca.crt -alias ca_cert \
        -keystore $OUT_DIR/truststore.jks -storepass atomic

# not necessary to store the private key for CA in the keystore (even if we are hacked) they will not get this