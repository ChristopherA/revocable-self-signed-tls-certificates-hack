#!/usr/bin/env coffee

lightsaber = require('lightsaber')
log = lightsaber.log
require 'shelljs/global'
bitcore = require('bitcore')
Insight = require('bitcore-explorers').Insight

# var privateKey = new bitcore.PrivateKey(null, bitcore.Networks.testnet)
# log(privateKey)
# var address = privateKey.toAddress()
# log(address)
# insight.getUnspentUtxos("mtPzC1nxwaMk4gbXdrzTQPVchYJQoZWzjB", function(){log(arguments)})


checkTruth = (error, info) ->
  if error
    console.error error
  else
    log info
    { balance, totalReceived, totalSent, unconfirmedBalance } = info
    if balance is 0 and unconfirmedBalance > 0
      log "---> awaiting network confirmation"
    else if balance is 0
      log "---> awaiting claim"
    else if balance > 0 and totalSent is 0
      log "---> claim maintained"
    else if balance > 0 and totalSent > 0
      log "---> claim revoked"
    else
      log "---> claim state unknown"

# extract bitcoin address

getAddressFromCert = (cert)->
  certText = exec "openssl x509 -noout -text -in #{cert}", silent: true
  log '---------'
  # Subject: C=NO, ST=None, L=Aethers, O=OrgName, OU=n3kTRVniUF4zSx744JthxGh4qxnNYRnJqi, CN=www.mydomain.com
  m = certText.output.match /\n\s+Subject:.*OU=(\w+), /
  m[1]

address = getAddressFromCert "tmp/certs/www.mydomain.com.cert"

log address
insight = new Insight('https://test-insight.bitpay.com', bitcore.Networks.testnet)
insight.address address, checkTruth

# look at that address' transaction's op return -- see that it matches
