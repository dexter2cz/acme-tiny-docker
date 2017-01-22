#!/bin/bash

# useradd -m -r -s /bin/bash acme

DAYS=60

if [ -z $1 ]; then
	echo "Jako parametr dej FQDN!"
	exit 1
fi

fqdn=$1
certdir=certs
mkdir -p $certdir/$fqdn
mkdir -p /var/www/html/.well-known/acme-challenge

if [ ! -f intermediate.pem ]; then
	echo "INFO: Nemame intermediate certifikat, stahuji ..."
	wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem || exit 1
fi

if [ ! -f $certdir/$fqdn/$fqdn.csr ]; then
	echo "INFO: Chybi vygenerovana zadost pro dane fqdn, generuji config k tomu potrebny ..."
	cat << EOF > $certdir/$fqdn/$fqdn.cfg
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask     = nombstr
prompt          = no
req_extensions      = req_ext

[req_distinguished_name]
countryName     = CZ
organizationName    = Dexcorp
commonName      = $fqdn

[req_ext]
subjectAltName      = @san

[san]
EOF
	pos=0; for dns in $*; do echo "DNS.$pos		= $dns" >> $certdir/$fqdn/$fqdn.cfg; let pos=pos+1; done

	echo "INFO: Jako root generuji privatni klic a zadost ..."
	$PWD/gen_csr.sh $fqdn
fi

if [ ! -f account.key ]; then
	echo "INFO: Chybi account klic pro Let's Encrypt, generuji ..."
	openssl genrsa 4096 > account.key
fi

if [ ! -d acme-tiny ]; then
	echo "ERROR: Acme-tiny skript neni k nalezeni, stahni ho:
git clone https://github.com/diafygi/acme-tiny"
	exit 1
fi

if openssl x509 -checkend $((3600*24*$DAYS)) -noout -in $certdir/$fqdn/$fqdn.crt 2>/dev/null; then
	echo "INFO: Certifikat $fqdn jeste nevyprsi minimalne $DAYS dni, obnova neni potrebna."
else
	echo "INFO: Predavam certifikat k podpisu ..."
	/usr/bin/python ./acme-tiny/acme_tiny.py --account-key account.key --csr $certdir/$fqdn/$fqdn.csr --acme-dir /var/www/html/.well-known/acme-challenge > $certdir/$fqdn/$fqdn.crt.new
	if [ $? -eq 0 ]; then
		echo "INFO: Certifikat podepsan!"
		mv -v $certdir/$fqdn/$fqdn.crt.new $certdir/$fqdn/$fqdn.crt
		cat intermediate.pem >> $certdir/$fqdn/$fqdn.crt
	else
		echo "ERROR: Pri podepisovani certifikatu doslo k chybe, nechavam stary!"
		exit 1
	fi
fi
