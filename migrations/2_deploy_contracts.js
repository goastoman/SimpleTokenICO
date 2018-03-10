// var SimpleStorage = artifacts.require("./CrowdSale.sol");
//
// module.exports = function(deployer) {
//   deployer.deploy(CrowdSale);
// };


const SimpleToken = artifacts.require('./SimpleToken.sol');

module.exports = (deployer) => {
  deployer.deploy(SimpleToken, web3.eth.accounts[1]);
};
