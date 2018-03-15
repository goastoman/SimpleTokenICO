const CrowdSale = artifacts.require("./CrowdSale.sol");

module.exports = (deployer) => {
  deployer.deploy(CrowdSale);
};


const SimpleToken = artifacts.require('./SimpleToken.sol');

module.exports = (deployer) => {
  deployer.deploy(SimpleToken, web3.eth.accounts[1]);
};


const WhiteList = artifacts.require('./WhiteList.sol')

module.exports = (deployer) => {
  deployer.deploy(WhiteList);
}
