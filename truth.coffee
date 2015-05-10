lightsaber = require('lightsaber')
log = lightsaber.log
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
    { balance, totalReceived, totalSent } = info
    if balance is totalReceived and totalSent is 0
      log "claim maintained"
    else
      log "claim revoked"

address = 'mtPzC1nxwaMk4gbXdrzTQPVchYJQoZWzjB'
insight = new Insight('https://test-insight.bitpay.com', bitcore.Networks.testnet)
insight.address address, checkTruth

