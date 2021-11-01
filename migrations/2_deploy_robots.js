var Robot = artifacts.require("Robot");

module.exports = async function (deployer) {
    let _addr = await web3.eth.getAccounts();
    await deployer.deploy(Robot, "ipfs://QmdKgp8jkHUn3ZqsvfNaXTfGEUh6RnPfghzmorQ7sK2vCW", _addr[0]);
}
