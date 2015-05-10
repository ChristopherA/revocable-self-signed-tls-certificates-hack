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
    { balance, totalReceived, totalSent } = info
    if balance > 0 and totalSent is 0
      log "---> claim maintained"
    else
      log "---> claim revoked"

address = 'mtPzC1nxwaMk4gbXdrzTQPVchYJQoZWzjB'
# insight = new Insight('https://test-insight.bitpay.com', bitcore.Networks.testnet)
# insight.address address, checkTruth


# extract bitcoin address

getAddressFromCert = (cert)->
  certText = exec "openssl x509 -noout -text -in #{cert}"
  log '---------'
  # Subject: C=NO, ST=None, L=Aethers, O=OrgName, OU=n3kTRVniUF4zSx744JthxGh4qxnNYRnJqi, CN=www.mydomain.com
  m = certText.output.match /\n\s+Subject:.*OU=(\w+), /
  m[1]

address = getAddressFromCert "tmp/certs/www.mydomain.com.cert"

log address


# look at that address' transaction's op return -- see that it matches
