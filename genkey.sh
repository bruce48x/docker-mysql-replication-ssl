#!/usr/bin/bash

# 1.
# ca key & cert
openssl req -x509 -newkey rsa:2048 -keyout ca-key.pem -out ca-cert.pem -days 3650 -nodes

# 2.
# mysql_main's key
openssl req -newkey rsa:2048 -keyout main-key.pem -out main-req.pem -nodes

# mysql_main's cert
openssl x509 -req -in main-req.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out main-cert.pem -days 3650 -extensions v3_req -extfile <(echo "[req]\ndistinguished_name=req\n[v3_req]\nsubjectAltName=IP:127.0.0.1,DNS:localhost")

# 3.
# mysql_replica's key
openssl req -newkey rsa:2048 -keyout replica-key.pem -out replica-req.pem -nodes

# mysql_replica's cert
openssl x509 -req -in replica-req.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out replica-cert.pem -days 3650 -extensions v3_req -extfile <(echo "[req]\ndistinguished_name=req\n[v3_req]\nsubjectAltName=IP:127.0.0.1,DNS:localhost")
