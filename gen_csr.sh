#!/bin/bash

if [ -z $1 ]; then
        echo "Jako parametr dej FQDN!"
        exit 1
fi

fqdn=$1
certdir=certs

openssl genrsa 4096 > $certdir/$fqdn/$fqdn.key
chmod 600 $certdir/$fqdn/$fqdn.key

openssl req -new -sha256 -key $certdir/$fqdn/$fqdn.key -subj "/CN=$fqdn" -config $certdir/$fqdn/$fqdn.cfg > $certdir/$fqdn/$fqdn.csr
chown ${SUDO_USER}. $certdir/$fqdn/$fqdn.csr

