#!/bin/bash

if [ -z ${NOAPACHE+x} ]; then /usr/sbin/apache2ctl -DBACKGROUND; fi

bash -x get_cert.sh $NAMES

tail /var/log/apache2/*


