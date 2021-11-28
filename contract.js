// This script requires that you have already deployed RobotContract.sol with Truffle
// Go back and do that if you haven't already

// 1. Import web3 and contractkit 
const Web3 = require("web3")
const ContractKit = require('@celo/contractkit')

// 2. Import the getAccount function
const getAccount = require('./getAccount').getAccount

// 3. Init a new kit, connected to the alfajores testnet
const web3 = new Web3('https://alfajores-forno.celo-testnet.org')
const kit = ContractKit.newKitFromWeb3(web3)

// import Robot info
const RobotContract = require("./build/contracts/Robot.json")

// Initialize a new Contract interface
async function initContract(){
  // Check the Celo network ID
  const networkId = await web3.eth.net.getId();
  const deployedNetwork = RobotContract.networks[networkId];
  // Create a new contract instance with the RobotContract contract info
  let instance = new web3.eth.Contract(
    RobotContract.abi,
    deployedNetwork && deployedNetwork.address
  );

  let account = await getAccount()

  console.log(account.address)

  walletOfOwner(instance, account.address)
  // mint(instance, account)
  updateWinnerRecord(instance, account, 2);
}

// Read the 'walletOwner' NFTs stored in the RobotContract.sol contract
async function walletOfOwner(instance, account){
  let walletOfOwner = await instance.methods.walletOfOwner(account).call()
  console.log(walletOfOwner)
}

async function updateWinnerRecord(instance, account, robotID) {
  kit.connection.addAccount(account.privateKey)
  let txObject = await instance.methods.updateRobotWinRecord(robotID)
  let tx = await kit.sendTransactionObject(txObject, { from: account.address })
  let receipt = await tx.waitReceipt()
  console.log(receipt)
}

async function updateLoserRecord(instance, account, robotID) {
  kit.connection.addAccount(account.privateKey)
  let txObject = await instance.methods.updateRobotLossRecord(robotID)
  let tx = await kit.sendTransactionObject(txObject, { from: account.address })
  let receipt = await tx.waitReceipt()
  console.log(receipt)
}

async function updateRobotStrength(instance, account, robotID, value) {
  kit.connection.addAccount(account.privateKey)
  let txObject = await instance.methods.updateRobotStrength(robotID, value)
  let tx = await kit.sendTransactionObject(txObject, { from: account.address })
  let receipt = await tx.waitReceipt()
  console.log(receipt)
}

async function updateRobotAgility(instance, account, robotID, value) {
  kit.connection.addAccount(account.privateKey)
  let txObject = await instance.methods.updateRobotAgility(robotID, value)
  let tx = await kit.sendTransactionObject(txObject, { from: account.address })
  let receipt = await tx.waitReceipt()
  console.log(receipt)
}

async function updateRobotAi(instance, account, robotID, value) {
  kit.connection.addAccount(account.privateKey)
  let txObject = await instance.methods.updateRobotAi(robotID, value)
  let tx = await kit.sendTransactionObject(txObject, { from: account.address })
  let receipt = await tx.waitReceipt()
  console.log(receipt)
}

async function updateRobotDefense(instance, account, robotID, value) {
  kit.connection.addAccount(account.privateKey)
  let txObject = await instance.methods.updateRobotDefense(robotID, value)
  let tx = await kit.sendTransactionObject(txObject, { from: account.address })
  let receipt = await tx.waitReceipt()
  console.log(receipt)
}

// Set the 'name' stored in the RobotContract.sol contract
async function mint(instance, account){

  const robotNFTID = 1

  // Add your account to ContractKit to sign transactions
  // This account must have a CELO balance to pay tx fees, get some https://celo.org/build/faucet
  kit.connection.addAccount(account.privateKey)


  let robotPrice = await instance.methods.ROBOT_PRICE().call()

  // Encode the transaction to RobotContract.sol according to the ABI
  let txObject = await instance.methods.mint(robotNFTID, "Larry")

  // Send the transaction
  let tx = await kit.sendTransactionObject(txObject, { from: account.address, value: robotPrice })

  let receipt = await tx.waitReceipt()
  console.log(receipt)
}

initContract()


