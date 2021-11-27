var Accessory = artifacts.require("Accessory");
var BotMarket = artifacts.require("BotMarket");
var Robot = artifacts.require("Robot");
var BigNumber = require('bignumber.js');

module.exports = async function(deployer) {
    let _addr = await web3.eth.getAccounts();
    let _clazzes = [1,2,3,4];
    let _amounts = [100,100,100,100];
    await deployer.deploy(Robot, "https://gateway.pinata.cloud/ipfs/QmSQaVkcT5njP3aJEyxLL7qPo6bwCQPCfB3Rbz2di48W6M/api/item/", _addr[0]);
    await deployer.deploy(Accessory, _clazzes, _amounts, "https://gateway.pinata.cloud/ipfs/QmZ4wueuLUFHMZtF65BBepB6Htz2ogqrupDK6XUomXMZx7/api/item/{id}.json");
    await deployer.deploy(BotMarket, _addr[0], Accessory.address);
    let _accessory = await Accessory.deployed();
    await _accessory.safeBatchTransferFrom(_addr[0], BotMarket.address, _clazzes, _amounts, "0x00");
    let _botMarket = await BotMarket.deployed();

    const ACCESSORY_PRICE = new BigNumber(1 * 10**18);

    for (let i = 0; i < 4; i++) {
        await _botMarket.listAccessory(_clazzes[i], ACCESSORY_PRICE, {from:_addr[0]})
    }
}
