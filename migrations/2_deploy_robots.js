var Robot = artifacts.require("Robot");

module.exports = function (deployer) {
    deployer.deploy(Robot, "ipfs://QmdKgp8jkHUn3ZqsvfNaXTfGEUh6RnPfghzmorQ7sK2vCW");
}
