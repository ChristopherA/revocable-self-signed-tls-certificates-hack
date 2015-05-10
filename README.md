Revocable, Self-Signed TLS Certificates
=======================================

Christopher Allen & SSL/TLS
---------------------------

In 1995 I became involved with SSL (the S in HTTPS), which had been initially deployed by Netscape in SSL 2.0 for the first internet commerce servers, but was acknowledged to have a number of security flaws. My company ended up leading the developer community that created SSL 3.0 -- we wrote the reference implementation, we published the commercial toolkit, we hosted the developer discussion list and FAQ.

Ultimately I became the co-author of the final specification and co-editor of the IETF TLS 1.0 standard, which is now the most widely adopted security standard in the world that is at the heart of the internet. Not only is it used for internet commerce, but also privacy: Google reports that it is now used for 50% of all incoming email and 60% of all outgoing email.

I have not been active in the cryptographic security lately, instead I have been focused on software for mobile industry. However, every time there is an attack related against TLS reported I get a call asking about it. My recently, I combined my background in both fields to help establish standards for mobile phone security, privacy and transparency at Blackphone. There the topic of weaknesses in TLS have emerged again.

TLS & Certificates
------------------

TLS itself offers a number of powerful capabilities: at the lowest level it offers integrity of the communication, then it builds on that to add confidentiality, and ultimately can offer some advanced features like perfect forward secrecy.

However, one thing that TLS can not offer by itself is a defense against man-in-the-middle attacks. This is where someone creates a fake server that fools the client into thinking they are talking confidentially with the true server. TLS relies on an older standard, X.509 Public-Key Identity Certificates, to certify first the identity of the server, and optionally the identity of client.

X.509 is old and overly complex, and in the last 16 years since the release of the TLS standard most of the security issues I’ve seen in TLS have to do with implementation issue and/or how it handles certificates, not against the the TLS protocol itself. It is clear that X.509 has not scaled well to the ever larger growth of the internet.

The Revocation Problem
----------------------

In the traditional X.509 Public Key Infrastructure (PKI), Identity Certificates are used to demonstrate ownership of a public key, and are signed by a Certificate Authority (CA) who asserts that the authority has verified that the information in the Identity Certificate is correct. This CA Certificate is, in turn, signed by another Certificate Authority that asserts that the CA Certificate itself is valid. Ultimately this certificate "chain" leads to the "root" certificate with a well known public key that is considered to be strong and uncompromised.

This is the real power of PKI over other identity protocols —- Identity Certificates are “self-authenticating” and you don't need any network operations to validate a certificate chain.

A challenge is that Identity Certificates are typically intended to persist for a long period of time, and thus are valid until their expiration date, or until they are terminated through “revocation”.

Unfortunately, Identity Certificates may become compromised before they expire. This may happen due to a compromise by exposure of the the user's private key, but can also happen due to bugs in software or other exploits. In addition, Certificate Authority’s keys may also be compromised through exposure of private keys and/or bugs. Finally, the "root" key itself may become compromised.

Theoretically, each time an Identity Certificate is presented, not only is the signature checked on that key and of all the Certificate Authorities above it, each key is to be checked to see if the Certificate Authority has issued an early “revocation” of that certificate in a Certificate Revocation List (CRL). Unfortunately, this part of the Public Key Infrastructure has never really worked. In order to validate an Identity Certificate you would need to connect to the CA to get the list of CRLs, which may be themselves be compromised or be subject to denial-of-service attacks. Thus requiring CRL validation of Identity Certificates removes many of the advantages of “self-authentication” of certificates, so few use them.

Instead most applications using PKI implement some form of CA Certificate “pinning”. In a somewhat simplified explanation, when an Identity or CA Certificate (or sometimes the public key or hash of the key) is first seen, that Certificate is “pinned” to the host in a “pinset”. The presumption is that this initial validation is correct, and any subsequent changes may be an attack that require additional validation. Often these “pinsets” are hard-coded into software, requiring an update to the software itself if there is a compromise in one of the keys.

Another solution could include implementing Webs-of-Trust, PGP-style, but this approach has not seen much activity.

Finally, another approach is to replace CRLs with some type of service that are more distributed and less subject to a denial-of-service attack. The Online Certificate Status Protocol (OCSP) protocol has been used and does help with revocation of CA Certificates, but is not very effective in compromised server private keys. In addition it has privacy issues (CAs can learn your browsing habits), and it also has scaling and performance issues.

In 2013 Mozilla reported that of 1774 CRL servers, ~1/2 did not respond to requests, and for that those that did report offered over 2.66 million revoked certificates taking up ~98MB. For OCSP Mozilla reported 1,292 servers with a response time of ~200ms per certificate, and every certificate in the chain needs to be checked! Now in 2015, due to Snowden revelations and Google “HTTPS Everywhere” SEO changes we are being asked to use TLS for every server on the internet, so the scaling challenges today are even greater!

There are some possible solutions on the horizon, CRLsets & OCSP stapling (basically certificate pinning approaches applied to OCSP), and a new Certificate Transparency proposal from Google. Unfortunately these approaches are unproven, are not decentralized, and may also have other undiscovered issues.

Using the Bitcoin Blockchain for Revocation
-------------------------------------------

The underlying technology of Bitcoin that is known as the blockchain has some interesting properties when thinking about the revocation problem.

Fundamentally the blockchain is a decentralized, consensus-based, time-stamped ledger. It is used in Bitcoin for financial transactions — in a sense a double-entry bookkeeping system where virtual coins are moved off one account and moved onto another, in such a way that no one can double-spend those coins.

The beauty of this system is that there are hundreds of thousands of copies of these ledgers, all of which are updated within 10 minutes of each other. The blockchain is also very good for something called “proof-of-existence” at a particular time. This is because of how important it is to have all transactions properly in order to prevent double-spending.

A lot of thought has been put into making this system reliable, safe against attack, and fast. There is no “root” in the blockchain, instead it functions as a decentralized authority with no center. The system is very heterogeneous, meaning that there are many redundant versions of the code, APIs, and services making denial-of service and other technical compromises more difficult.

The blockchain is not an identity system. Each account (a Bitcoin address) has a private key associated with it that only exists until that account is spent (has a zero balance), and then that key is thrown away. This is very unlike X.509 PKI use of keys which may be kept for years.

I would like to take advantage of these throw-away keys. I propose that one possible solution to the Revocation Problem is to consider using blockchain technology as a solution.

The Bitcoin Blockchain is the most mature blockchain currently, so what I'm proposing here is a possible proof-of-concept that a blockchain-based solution to the Revocation Problem might be viable. It is a hack, but it may be a useful hack.

TLS Self-Signed Certificates
----------------------------

The least secure method of using X.509 Certificates are what is known as `self-signed certificates`. Basically these are identity certificates that are signed by the same entity whose identity it certifies. In technical terms a self-signed certificate is one signed with its own private key. They are very easy to create, and are typically used by developers for testing servers, or within a corporate intranet.

If you have some out-of-band reason to trust these certificates, they can help secure TLS against man-in-the-middle attacks. However, these certificates also suffer from the fact that they can not be revoked -- only CAs can offer CRLs or other revocation services. If the issuer later decides that the keys are compromised, they have no way to notify their partners that this certificate should no longer be considered valid.

As a proof-of-concept, we will show how easy it is to revoke a self-signed certificate. This will also demonstrate how we may be able to use similar approaches for more advanced capabilities that current X.509 infrastructure do not.

Creating the Self-Signed Certificate
------------------------------------

First we create a brand new bitcoin address (for instance 1DG4Nd7ZBWoQz76g2jSa64e7Q9QWWem5Cd), which means that we now have a private key, an associated public key, a bitcoin address (the hash of that public key). If we did everything correctly, the bitcoin blockchain should report that there have never been any transactions associated with that new bitcoin address since the creation of the blockchain. https://blockchain.info/address/1DG4Nd7ZBWoQz76g2jSa64e7Q9QWWem5Cd

We now create the self-signed certificate with standard tools. In the case of OpenSSL we are not going to make any changes to its signing code, so for this hack we are going to use the often unused `Organizational Unit Name` attribute and place our new bitcoin address in that field. Signing the certificate results in: 

```
$ openssl -x509 -sha256 -newkey rsa:2048 -req -days 365 -in server.csr -signkey server.key -out server.crt
Signature ok
subject=/C=US/ST=California/L=Menlo Park/O=Hackathon, Inc. AG/OU=1DG4Nd7ZBWoQz76g2jSa64e7Q9QWWem5Cd/CN=test.hackathon.cnet/Email=ChristopherA@hackathon.net
Getting Private key
$
```

We now get the signature of this key and create a SHA256 hash of it.

```
openssl x509 -noout -text -in server.crt
!!!(we’ll need an easy way to hash the hex signature output from this to a form that bitcore.js uses)
```

From another bitcoin address, we send .0047 bitcoin to our new address in a bitcoin distributing transaction, with .0043 (about US$1.00) going to our new bitcoin address, an OP_RETURN of the hash of our certificate’s signature a3d885357963e6c9142304cf5d0dd35c3f964cb9f16dcafcfa49c49aa2114e55, and the remaining .0004 bitcoin being offered as a transaction fee.

So at this point we only have a few truths.

* We have a certificate that was self-signed.
* This certificate has a valid bitcoin address in it (bitcoin addresses have self-check bytes in them) and that this address was signed with the rest of the certificate.
* By looking up the bitcoin address, we can know that that no one has spent the $1 assigned to it — it also has exactly one incoming transaction and no outgoing.
* Looking up the transaction id of the incoming transaction, we know that the claim was received sometime near the time that the certificate claims the time was when the claim was made (the transaction received time was 2015-05-02 07:37:41, the claim says "2015/05/01 07:24:08", only a 13 minute difference.)
* By looking up the OP_RETURN value and confirming it matches the hash of the certificates signature, we have a proof of existence that the entire self-signed certificate existed within a reasonable amount of time around 2015-05-02 07:37:41.
* We know that someone has locked up $1 in value for some period of time.

Validating and Revoking the Certificate
---------------------------------------

For as long as the bitcoin address has no transactions that are outputs (it can continue to receive multiple inputs), by convention we say that the issuer of the certificate continues to believe it to be valid.

As soon as any portion of the bitcoin address is spent, by convention we consider that the issuer of the certificate wishes to revoke the certificate.

We now have additional truths:

* Looking at the outgoing transaction, we know the date that the certificate was revoked.
* As the outgoing transaction demonstrated the use of the private key that was used to create the address, we can confirm that the issuer used the same private key that was used in the past.
* We can prove that the private key of the bitcoin address existed from the time of the first incoming transaction to the time of the first outgoing transaction.
* We know the first bitcoin address that the bitcoin (all or some of the $1) was transferred to.

This makes self-signed certificates substantially more powerful. When presented with a self-signed certificate you can not only confirm its signature, you can prove when it was created by the issuer, and if it was revoked, prove when it was revoked.

As the blockchain is designed to prevent double-spending, and is decentralized and heterogeneous, with this technique we can more easily avoid a number of the denial-of-service and other attacks against CRLs and OCSPs. Confirmations of unspent bitcoin addresses are designed to be efficient -- we can use local copies of the blockchain, or out-of-band techniques such as cell phones to confirm validity of the self-signed certificates.

In addition, Bitcoin offers something called paper wallets, so the keys to revoke a certificate do not even have reside physically on a server. You can simply point any iPhone or Android bitcoin client to the QR-Code of the paper wallet stored away in a safe-deposit box to spend the money to revoke the self-signed signature.

Advanced Revocation
-------------------

The above is a minimum-viable product, but there are many more things you can do with blockchain technology. 

* When we revoke the self-signed certificate by spending the money on the address, we can optionally place an OP_RETURN value to explain the reason why the self-signed certificate was revoked, for instance: key compromise, change of affiliation, superseded, cease of operation, or unspecified.

* With multisig, it is possible to use self-signed certificates with bitcoin addresses in them as bonds. Of instance, a bitcoin address with $1000 in it could be set it up such that if 3 of 5 multisig holders agree, they can not only revoke the certificate by spending it, they can also spend the bitcoins that it holds. The multisig holders can also prove that they have the ability to revoke a certificate by signing requests to confirm their ability to. Multisig makes for some very interesting other advanced possibilities.

* If we not only include the bitcoin address, but also sign it with the bitcoin address’ private key, we can now link bitcoin transactions to self-signed certificates. In this case, by convention if there is an OP_RETURN value that is the same certificate, or a new certificate, the new bitcoin address should be used for certificate status in the future. Using this technique repeatedly, using new bitcoin addresses that confirm or change certificates, you create a chain with strong proof-of-existence over time. Though each is only as strong as the previous certificate, there is value to the continuity over time of multiple claims -- if you trusted it six months ago you likely can trust it now (which is what happens with certificate pinning). Each certificate can be looked up by using the bitcoin address as an ID, validated against the ledger by the transaction ledger, and connected to future and past certificates by signature. You now have a fairly powerful validity system that may be more powerful than today.

* With the transaction chains above, you could create conventions where someone must confirm daily that the certificate is valid. If the money is unspent without a link to the next bitcoin address for more than a day, it could be considered possibly compromised, and if for a week it could be considered invalid. 

* We could add to the revocation status list `certificate hold`. This means that the certificate is not valid until a future point of time. As blockchains offer strong proof of time, this technique offers a number of interesting advanced architectures.

* One holy grail of PKI was “attribution certificates”. An attribute certificate is a message that is digitally signed, the contents of which convey certain properties or “claims” about a given subject. Validity of the signature demonstrates that those claims were considered to be valid by the issuer at the time of issuance. Like self-signed certificates, the problem with attribute certificates were that they could not be changed or revoked. Using these techniques you can now make attribution certificates without those weaknesses.

* With attribution certificates, it is also possible to combine claims with claims. I could include Jon Callas' signed claim inside my own, and say that I believe it to be true. I could even include his PGP public key and sign it with my own PGP public key, and add it to a claim, attaching our mutual PGP web of trust with our new Attribute Certificates to bootstrap a new web of trust. This may allow us to create non-X.509 identity systems using the blockchain.

Why Hasn’t Anyone Else Done This?
---------------------------------

This technique is very elegant and simple, so why has it not been proposed before?

I believe part of the reason is that PKI historically keeps private keys around for a long time, whereas bitcoin throws them away with every outgoing transaction. Rather than considering that a problem, we are using it as an advantage.

Also, largely the Blockchain community and PKI Community don’t talk together. Blockchain developers are creating new protocols, and typically have radical ideas to replace X.509 PKI entirely rather than transitioning the old to something new. On the other hand, the PKI community is very concerned about reliability and security, and thus take a very conservative approach to changes — which is not the hallmark of the blockchain.

There are likely some problems with the proof-of-concept that we have not thought of. The round-trip time to confirm an unspent bitcoin address may, in fact, be slower than the latest OCSP or Certificate Transparency infrastructure. Having every browser in the world requesting confirmations on the bitcoin blockchain may overwhelm bitcoin server volume unsustainably. This technique requires integration of the validity check into the code of mission critical code bases like OpenSSL, whose maintainers are legitimately very concerned about changes that may introduce new attack vectors for hackers. And portions of the bitcoin protocols also rely on TLS.

However, I believe that the general approach offers some strong ideas for the future and is worthy of further investigation.

Demo
----

These are the details for the demo of this capability for Blockchain University’s Demo Night on Monday May 18th: http://www.meetup.com/blockchainU/events/221953311/

We are using the bitcore.js library for node and browser-based bitcoin transactions, with some code from other open source libraries offline paper wallet, and javascript-based TLS and certificates.

The certificate issuer downloads our code from github and runs the client from the browser. A random seed is created from user and browser activity to create a unique bitcoin address. The address is added to a self-signed certificate, the hash of which is added as an OP_RETURN to a $1.10 transaction on the blockchain. The transaction results and the paper wallet are printed for offline storage and future revocation.

The validity of the unspent bitcoin and the hash of the certificate can be verified by many services.

We install the self-signed certificate in a node TLS web server. We then demonstrate a node client using a modified javascript-based TLS client that connects to that server and confirms that the certificate and the unspent bitcoin address is valid. We then spend the paper wallet using an iPhone, and have the same server say it is invalid.

Example Usage
-------------

    npm install

    ./create.coffee


Go [put 500000 Satoshis](https://accounts.blockcypher.com/testnet-faucet) on the returned BTC address

    ./verify.coffee

Should be pending, for a while, then true, once the trancaction clears.

