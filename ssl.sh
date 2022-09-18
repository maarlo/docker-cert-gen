#! /bin/bash

if [ "$#" -ne 1 ]
then
  echo "Error: No domain name argument provided"
  echo "Usage: Provide a domain name as an argument"
  exit 1
fi

DOMAIN=$1
[[ -z "${SUBJ_C}" ]] && SUBJ_C='US' || SUBJ_C="${SUBJ_C}"
[[ -z "${SUBJ_ST}" ]] && SUBJ_ST='California' || SUBJ_ST="${SUBJ_ST}"
[[ -z "${SUBJ_L}" ]] && SUBJ_L='San Fransisco' || SUBJ_L="${SUBJ_L}"
[[ -z "${SUBJ_O}" ]] && SUBJ_O='MLopsHub' || SUBJ_O="${SUBJ_O}"
[[ -z "${SUBJ_OU}" ]] && SUBJ_OU='MlopsHub Dev' || SUBJ_OU="${SUBJ_OU}"

if [ ! -d "/certs/${DOMAIN}" ]
then
  mkdir -p /certs/${DOMAIN}
else
  echo "The certificate was previously generated"
  exit 0
fi

# Create root CA & Private key

openssl req -x509 \
            -sha256 -days 365 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=${DOMAIN}/C=${SUBJ_C}/L=${SUBJ_L}" \
            -keyout /certs/${DOMAIN}/rootCA.key -out /certs/${DOMAIN}/rootCA.crt

# Generate Private key

openssl genrsa -out /certs/${DOMAIN}/${DOMAIN}.key 2048

# Create csf conf

cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = ${SUBJ_C}
ST = ${SUBJ_ST}
L = ${SUBJ_L}
O = ${SUBJ_O}
OU = ${SUBJ_OU}
CN = ${DOMAIN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${DOMAIN}
DNS.2 = www.${DOMAIN}

EOF

# create CSR request using private key

openssl req -new -key /certs/${DOMAIN}/${DOMAIN}.key -out /certs/${DOMAIN}/${DOMAIN}.csr -config csr.conf

# Create a external config file for the certificate

cat > cert.conf <<EOF

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}

EOF

# Create SSl with self signed CA

openssl x509 -req \
    -in /certs/${DOMAIN}/${DOMAIN}.csr \
    -CA /certs/${DOMAIN}/rootCA.crt -CAkey /certs/${DOMAIN}/rootCA.key \
    -CAcreateserial -out /certs/${DOMAIN}/${DOMAIN}.crt \
    -days 365 \
    -sha256 -extfile cert.conf

# Cleanup

rm -f cert.conf
rm -f csr.conf
rm -f /certs/${DOMAIN}/rootCA.srl
rm -f /certs/${DOMAIN}/${DOMAIN}.csr