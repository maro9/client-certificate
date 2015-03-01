#!/bin/sh


if [ $# -ne 2 ]; then
	echo "usage: issueCerts.sh <CERTCSV> <CAPASS>" >&2
	exit 0
fi

CERTCSV=$1
CAPASS=$2

if [ -f $CERTCSV ]; then

	while read LINE; do
		if [ ${#LINE} -gt 1 ]; then
			C=`echo ${LINE} | cut -d ',' -f 1`
			ST=`echo ${LINE} | cut -d ',' -f 2`
			L=`echo ${LINE} | cut -d ',' -f 3`
			O=`echo ${LINE} | cut -d ',' -f 4`
			OU=`echo ${LINE} | cut -d ',' -f 5`
			CN=`echo ${LINE} | cut -d ',' -f 6`
			CERTPASS=`echo ${LINE} | cut -d ',' -f 7`
			EXPOPASS=`echo ${LINE} | cut -d ',' -f 8`

			/usr/bin/openssl req -config ./openssl.cnf -new -keyout newkey.pem -out newreq.pem \
			                                           -days 1825 -passout pass:${CERTPASS} \
			                                           -subj "/C=${C:-JP}/ST=${ST:-}/L=${L:-}/O=${O:-}/OU=${OU:-}/CN=${CN:-EMPTY}" || exit1

			/usr/bin/openssl ca -batch -key ${CAPASS} -config ./openssl.cnf -policy policy_anything \
			                                          -out newcert.pem -infiles newreq.pem || exit 1
			/bin/cp newcert.pem ./certs/${CN}.pem

			/bin/cat newkey.pem newcert.pem | /usr/bin/openssl pkcs12 -passin pass:${CERTPASS} -passout pass:${EXPOPASS} \
	                                                                  -export -out newcert.p12 || exit 1

			/bin/cp newcert.p12 ./pkcs/${CN}.p12

		fi
	done < $CERTCSV

else
	echo "Set certificate csv list on first argument"
	
fi

