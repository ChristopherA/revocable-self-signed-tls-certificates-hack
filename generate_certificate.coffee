require 'shelljs/global'

if not which 'openssl'
  echo 'Sorry, this script requires openssl'
  exit 1

mkdir '-p', 'tmp/certs'
cd 'tmp/certs'

domainName = "www.mydomain.com"
certSubject = "/C=NO/ST=None/L=Aethers/O=BTCAddress/CN=#{domainName}"

exec """
openssl req \
    -new \
    -newkey rsa:4096 \
    -nodes \
    -x509 \
    -days 365 \
    -subj #{certSubject} \
    -keyout #{domainName}.key \
    -out #{domainName}.cert
"""
