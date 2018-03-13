const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

import { assertEqual, assertTrue, timeController } from './utils';

const CrowdSale = artifacts.require('CrowdSale');
let accounts; //our local variables

contract('testing on the air', (wallets) => {
  const addressICO = wallets[9];
  const addressClient = wallets[1];
  // const startPreICO = timeController.currentTimestamp().add(3600);
  // const endPreICO = timeController.currentTimestamp().add(7200);
  // const startICO = timeController.currentTimestamp().add(10800);
  // const endICO = timeController.currentTimestamp().add(14400);
  const startPreICO = 1520690409;
  const endPreICO = 1520694009;
  const startICO = 1520697609;
  const endICO = 1520701209;

  const PreICORate = 20;  //1 Ether = 20 tokens
  const ICORate = 1;  //1 Ether = 1 token
  const minCap = 1e18;
  const founders = wallets[2];
  const operational = wallets[3];
  const withdrawWallet = wallets[8];
  const ownerICO = wallets[0];

  describe('CrowdSale test', () => {


    beforeEach(async function () {
          this.sale = await CrowdSale.new(startPreICO, endPreICO, startICO, endICO, PreICORate, ICORate, minCap, founders, operational, withdrawWallet);
          this.token = SimpleToken.at(await this.sale.token());
        });

    it('should have 18 dec', async function() {
      const ownerCrowdsale = await this.sale.owner();
      assertEqual(ownerCrowdsale, ownerICO);

      const ownerToken = await this.token.owner();
      assertEqual(ownerToken, ownerICO);
      // const addressICO = await this.token.address;
      // assertEqual(addressICO, this.sale.address);
      // const expectedValue = 18;
      // const tokenValue = await this.sale.decimals();
      // assertEqual(expectedValue, tokenValue.toNumber());
    });



    //
    // it('should have 33e5 * (10 ** DECIMALS) in RESERVED_TOKENS_FOUNDERS', async function() {
    //   const balance = 33e5 * (10 ** 18);
    //   const tokenValue = await this.token.RESERVED_TOKENS_FOUNDERS();
    //   const getBalanceFounders = await this.token.balanceOf(RESERVED_TOKENS_FOUNDERS);
    //   assertEqual(getBalanceFounders.toNumber(), balance);
    // });
    //
    // it('should have 2e5 * (10 ** DECIMALS) in RESERVED_TOKENS_OPERATIONAL_EXPENSES', async function() {
    //   const balance = 2e5 * (10 ** 18);
    //   const tokenValue = await this.token.RESERVED_TOKENS_OPERATIONAL_EXPENSES();
    //   const getBalanceOperational = await this.token.balanceOf(RESERVED_TOKENS_OPERATIONAL_EXPENSES);
    //   assertEqual(getBalanceOperational.toNumber(), balance);
    // });

    // it('should manual transfer', async function() {
    //   await this.token.unpause();
    //   const amount = 1e6 * (10 ** 18);
    //   const balance = await this.token.balanceOf(addressClient);
    //   await this.token.manualTransferToken(addressClient, amount, {
    //     from: ownerICO
    //   })
    //   assertEqual(balance.toNumber(), amount);
    // })



  });
});


//
// function manualTransferToken(address _to, uint256 _amount) onlyOwner external {
//   require(_to != address(0x0));
//   tokensRemindingICO = tokensRemindingICO.sub(_amount);
//   token.transferFromICO(_to, _amount);
// }
