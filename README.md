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

Deploy contracts.
```
$ truffle migrate --reset
```

#### Robot Contract
This is the ERC721 contract to mint Robot NFTs.  

Instantiate contract in console.
```
$ robot = await Robot.deployed()
```

Mint a Token in Truffle.
```
$ robot.mint(1, {from:accounts[1], value: 100000000000000000, gas: 4712388})
```

Show the ID of the first token minted from above.
```
$ robot.walletOfOwner(accounts[1]).then(function(bn) { thisToken = bn})
$ thisToken[0].words[0]
```

Get TokenURI
```
$ robot.tokenURI(0)
```

#### Accessory Contract
This is the ERC1155 contract to mint Robot accessories as FTs.  

Instantiate contract in console.
```
$ acc = await Robot.deployed()
```

Mint a Token in Truffle.
```
$ acc.mintAccessory(accounts[1], 2, "0x000", {from: accounts[0], gas: 4712388})
```

Get account balance per tokenID
```
$ acc.balanceOf(accounts[1], 2)
```
