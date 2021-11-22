## Robot Smart Contract
This is the smart contract for minting robots on the CELO (and ethereum network). The app uses Pinata for ipfs management <https://app.pinata.cloud/pinmanager>.

### Depoying to Ganache and Alfjores testnet.

#### For Ganache
Start Ganache.
```
$ ganache-cli --port 7545
```

Start Truffle Console.
```
$ truffle console --network development
```

#### For Alfjores

Start Truffle Console.
```
$ truffle console --network alfajores
```

Deploy contracts.
```
$ truffle migrate --reset
```

#### Robot Contract
<https://docs.openzeppelin.com/contracts/4.x/api/token/erc721>  

This is the ERC721 contract to mint Robot NFTs.  

Instantiate contract in console.
```
$ robot = await Robot.deployed()
```

Mint a Token in Truffle.
```
$ robot.mint(1, {from:accounts[0], value: 10000000000000000000, gas: 4712388})
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
<https://docs.openzeppelin.com/contracts/4.x/api/token/erc1155>  

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

Get balance of each token
```
$ acc.getWalletAccessories(accounts[1], [0,1,2,3])
```

#### BotCash Contract
<https://docs.openzeppelin.com/contracts/4.x/api/token/erc20>  

This is the ERC20 contract to mint BotCash tokens.

Instantiate contract in console.
```
bcsh = await BotCash.deployed()
```

Mint 1000 tokens to owner account.
```
$ bcsh.mint(accounts[0], 1000)
```

See total supply.
```
$ bcsh.totalSupply()
```

See balanceOf of owner account.
```
$ bch.balanceOf(accounts[0])
```

### BotMarket Contract
This is the contract for listing ERC1155 accessories to be purchased by users.  


Instantiate contract in the console.
```
$ bm = await BotMarket.deployed()
```

List an accessory for sale.
```
$ bm.listAccessory(1, 1, {from:accounts[0], gas: 4712388})
```

$ Purchase an accessory.
```
$ bm.purchaseAccessory(accounts[1], 1, {from:accounts[1], value: 1, gas: 4712388})
```

$ Set (or change) accessory price.
```
$ bm.setAccessoryPrice(1, 3, {from:accounts[0], gas: 4712388})
```

$ Get get accessory by ID
```
$ bm.accessories(1)
```
