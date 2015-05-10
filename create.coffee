#!/usr/bin/env coffee

lightsaber = require 'lightsaber'
log = lightsaber.log
bitcore = require 'bitcore'
require 'shelljs/global'

privateKey = new bitcore.PrivateKey null, bitcore.Networks.testnet
# log(privateKey)
address = privateKey.toAddress()
# log(address)

if not which 'openssl'
  echo 'Sorry, this script requires openssl'
  exit 1

mkdir '-p', 'tmp/certs'
cd 'tmp/certs'

domainName = "www.mydomain.com"
certSubject = "/C=NO/ST=None/L=Aethers/O=#{address}/CN=#{domainName}"

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

