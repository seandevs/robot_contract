## Robot Smart Contract
This is the smart contract for minting robots on the CELO (and ethereum network). The app uses Pinata for ipfs management <https://app.pinata.cloud/pinmanager>.

### Common Commands in Truffle and Ganache
Start Ganache.
```
$ ganache-cli --port 7545
```

Start Truffle Console.
```
$ truffle console --network development
```

Deploy a contract.
```
$ truffle migrate --reset
```

Instantiate contract in console.
```
$ contract = await Robot.deployed()
```

Mint a Token in Truffle.
```
$ contract.mint(1, {from:accounts[1], value: 100000000000000000, gas: 4712388})
```

Show the ID of the first token minted from above.
```
$ contract.walletOfOwner(accounts[1]).then(function(bn) { thisToken = bn})
$ thisToken[0].words[0]
```

Get TokenURI
```
$ contract.tokenURI(0)
```



