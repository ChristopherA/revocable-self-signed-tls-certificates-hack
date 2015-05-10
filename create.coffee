#!/usr/bin/env coffee

lightsaber = require 'lightsaber'
log = lightsaber.log
bitcore = require 'bitcore'
require 'shelljs/global'

generateCert = (domainName, btcAddress)->
  mkdir '-p', 'tmp/certs'
  cd 'tmp/certs'

  certSubject = "/C=NO/ST=None/L=Aethers/O=OrgName/OU=#{btcAddress}/CN=#{domainName}"

  exec """
  openssl req \
      -new \
      -newkey rsa:2048 \
      -nodes \
      -x509 \
      -days 365 \
      -subj #{certSubject} \
      -keyout #{domainName}.key \
      -out #{domainName}.cert
  """

privateKey = new bitcore.PrivateKey null, bitcore.Networks.testnet
# log(privateKey)
address = privateKey.toAddress()

if not which 'openssl'
  echo 'Sorry, this script requires openssl'
  exit 1

generateCert("www.mydomain.com", address)

log "New bitcoin address: " + address
