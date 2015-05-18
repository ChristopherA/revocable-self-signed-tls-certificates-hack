fs = require 'fs'
{ log } = require 'lightsaber'
bitcore = require 'bitcore'

class ClaimData
  domainName:  "www.mydomain.com"
  networkName: 'testnet'

  @load: (filename)->
    certDataString = fs.readFileSync(filename, encoding: 'ascii')
    new ClaimData(JSON.parse(certDataString))

  constructor: (serialized)->
    if serialized?
      @deserialize(serialized)
    else
      @destinationPK = new bitcore.PrivateKey null, @network() # dest addr with OP_RETURN txn
      @tempPK = new bitcore.PrivateKey null, @network() # temporary address for user's initial txn

  destinationAddress: ->
    @destinationPK.toAddress(@network())

  tempAddress: ->
    @tempPK.toAddress(@network())

  serialize: ->
    {
      domainName:        @domainName
      network:           @networkName
      destinationWIF:    @destinationPK.toWIF()
      tempWIF:           @tempPK.toWIF()
      certSignatureHash: @certSignatureHash
    }

  deserialize: (obj)->
    if !obj.destinationWIF || !obj.tempWIF
      log 'Error! Private Keys are not defined in the json.'


    @domainName = obj.domainName
    @networkName = obj.network
    @destinationPK = new bitcore.PrivateKey(obj.destinationWIF, @network())
    @tempPK = new bitcore.PrivateKey(obj.tempWIF, @network())
    @certSignatureHash = obj.certSignatureHash

  network: ->
    if @networkName == 'testnet'
      bitcore.Networks.testnet

  save: (filename)->
    dataObj = @serialize()
    fs.writeFile filename, JSON.stringify(dataObj), null, (err)->
      console.error err if err


module.exports = ClaimData
