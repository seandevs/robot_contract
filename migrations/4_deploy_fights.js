var Fight = artifacts.require("Fight");

module.exports = async function (deployer) {
    let _addr = await web3.eth.getAccounts();
    await deployer.deploy(Fight, _addr[0]);
}
