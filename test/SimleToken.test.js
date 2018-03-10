const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

import { assertEqual, assertTrue, timeController } from './utils';


const SimpleToken = artifacts.require('SimpleToken');
const CrowdSale = artifacts.require('CrowdSale');

let accounts; //our local variables

contract('SimpleToken', (wallets) => {
  const addressICO = wallets[9];
  const addressClient = wallets[1];
  describe('SimpleToken test', () => {

    beforeEach(async function () {
          this.token = await SimpleToken.new(addressICO);
        });

    // it('deploys a contract', () => {
    //   assert.ok(SimpleToken.options.address);
    // });

    it('should be current name', async function() {
      const expectedName = 'SimpleToken';
      const tokenName = await this.token.name();
      assertEqual(expectedName, tokenName);
    });

    it('should be current symbol', async function() {
      const expectedSymbol = 'ST';
      const tokenSymbol = await this.token.symbol();
      assertEqual(expectedSymbol, tokenSymbol);
    });

    it('should be current decimals', async function() {
      const expectedDec = 18;
      const tokenDec = await this.token.decimals();
      assertEqual(expectedDec, tokenDec.toNumber());
    });

    it('should be current supply', async function() {
      const expectedSupply = 10e6 * (10 ** 18);
      const tokenSupply = await this.token.INITIAL_TOTAL_SUPPLY();
      assertEqual(expectedSupply, tokenSupply.toNumber());
    });

    it('should have a balance', async function() {
      const balance = await this.token.balanceOf(addressICO);
      assertEqual(balance.toNumber(), 10e6 * (10 ** 18))

    });

    it('should transfer', async function() {
      await this.token.unpause();
      const amount = 1e6 * (10 ** 18);
      await this.token.transfer(addressClient, amount, {
        from: addressICO
      });
      const balance = await this.token.balanceOf(addressClient);
      assertEqual(balance.toNumber(), amount);
    });

    it('should transfer from ICO', async function() {
      const amount = 1e6 * (10 ** 18);
      await this.token.transferFromICO(addressClient, amount, {
        from: addressICO
      });
      const balance = await this.token.balanceOf(addressClient);
      assertEqual(balance.toNumber(), amount);
    });

    it('should transfer from', async function() {
      await this.token.unpause();
      const addressAllowed = wallets[2];
      const amount = 1e6 * (10 ** 18);
      await this.token.approve(addressAllowed, amount, {
        from: addressICO
      });
      await this.token.transferFrom(addressICO, addressClient, amount, {
        from: addressAllowed
      });
      const balance = await this.token.balanceOf(addressClient);
      assertEqual(balance.toNumber(), amount);
    });

    it('should burn tokens from', async function() {
      const amount = 1e6 * (10 ** 18);
      const balance = await this.token.balanceOf(addressICO);
      const balanceDecreased = balance.sub(amount).toNumber();
      await this.token.burnFrom(addressICO, amount, {
        from: addressICO
      });
      assertEqual(balance.sub(amount).toNumber(), balanceDecreased);
    });

    it('should burn tokens from ICO', async function() {
      await this.token.unpause();
      const amount = 1e6 * (10 ** 18);
      await this.token.burnFromICO({
        from: addressICO
      });
      const balance = await this.token.balanceOf(addressICO);
      assertEqual(balance.toNumber(), 0);
    });



  });
});


contract('CrowdSale', (wallets) => {

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









//
