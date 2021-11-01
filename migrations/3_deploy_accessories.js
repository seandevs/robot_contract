var Accessory = artifacts.require("Accessory");
var BotMarket = artifacts.require("BotMarket");

// module.exports = function (deployer) {
//     deployer.deploy(Accessory);
// }

module.exports = async function(deployer) {
    let _addr = await web3.eth.getAccounts();
    let _clazzes = [1,2,3,4];
    let _amounts = [100,100,100,100];
    await deployer.deploy(Accessory, _clazzes, _amounts);
    await deployer.deploy(BotMarket, _addr[0], Accessory.address);
    let _accessory = await Accessory.deployed();
    await _accessory.safeBatchTransferFrom(_addr[0], BotMarket.address, _clazzes, _amounts, "0x00");
}
