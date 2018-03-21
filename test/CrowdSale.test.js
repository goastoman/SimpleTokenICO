const assert = require('assert');
import { BigNumber } from 'bignumber.js';
import { assertEqual, assertTrue, timeController } from './utils';

const CrowdSale = artifacts.require('CrowdSale');
const SimpleToken = artifacts.require('SimpleToken');
const WhiteList = artifacts.require('WhiteList');
let accounts; //our local variables

contract('CrowdSale', (wallets) => {
  const addressICO = wallets[9];
  const addressClient = wallets[1];
  // const startPreICO = timeController.currentTimestamp().add(3600);
  // const endPreICO = timeController.currentTimestamp().add(7200);
  // const startICO = timeController.currentTimestamp().add(10800);
  // const endICO = timeController.currentTimestamp().add(14400);

  const PreICORate = 20;  //1 Ether = 20 tokens
  const ICORate = 1;  //1 Ether = 1 token
  const minCap = 50 * (10 ** 18);
  const founders = wallets[2];
  const operational = wallets[3];
  const withdrawWallet = wallets[8];
  const ownerICO = wallets[0];

  describe('testing on the air...', () => {

  beforeEach(async function () {
          const startPreICO = timeController.currentTimestamp().add(3600);
          const endPreICO = timeController.currentTimestamp().add(86400 * 7);
          const startICO = timeController.currentTimestamp().add(86400  * 7 + 3600);
          const endICO = timeController.currentTimestamp().add(86400 * 14);

          this.sale = await CrowdSale.new(startPreICO, endPreICO, startICO, endICO, PreICORate, ICORate, minCap, founders, operational, withdrawWallet);
          this.token = SimpleToken.at(await this.sale.token());
          this.list = WhiteList.at(await this.sale.whiteList());
          });

    it('ownerCrowdsale should be equal ownerICO', async function() {
      const ownerCrowdSale = await this.sale.owner();
      assertEqual(ownerCrowdSale, ownerICO);
    })

    it('ownerToken should be equal ownerICO', async function() {
      const ownerToken = await this.token.owner();
      assertEqual(ownerToken, ownerICO);
    })

    it('should have right decimals: 18', async function() {
      const expectedValue = 18;
      const saleValue = await this.sale.decimals();
      assertEqual(expectedValue, saleValue.toNumber());
    })

    it('should have 23.000.000 tokens for founders', async function() {
      const expectedSupply = 23e6 * (10 ** 18);
      const saleSupply = await this.sale.RESERVED_TOKENS_FOUNDERS();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should have 2.000.000 tokens for operational expenses', async function() {
      const expectedSupply = 2e6 * (10 ** 18);
      const saleSupply = await this.sale.RESERVED_TOKENS_OPERATIONAL_EXPENSES();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should have 5.000.000 tokens as hardcap for preICO', async function() {
      const expectedSupply = 5e6 * (10 ** 18);
      const saleSupply = await this.sale.HARDCAP_TOKENS_PRE_ICO();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should have 70.000.000 tokens as hardcap for ICO', async function() {
      const expectedSupply = 70e6 * (10 ** 18);
      const saleSupply = await this.sale.HARDCAP_TOKENS_ICO();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should manual transfer', async function() {
      // await this.sale.unpause();
      const amount = 1e6 * (10 ** 18);
      await this.sale.manualTransferToken(addressClient, amount, {
        from: ownerICO
      });
      const balance = await this.token.balanceOf(addressClient);
      assertEqual(amount, balance.toNumber());
    })

    it('testing owner', async function() {
      const list = await this.list.owner();
      const token = await this.token.owner();
      const sale = this.sale.address;
      assertEqual(list, token);
    });

    it('should sell tokens using fallback function', async function() {
        await this.list.addWallet(addressClient, 3);
        timeController.addSeconds(3601);
        timeController.mineBlock();
        const amount = 10 * (10 ** 18);
        await this.sale.sendTransaction({
            from: addressClient,
            value: amount,
        });
        const balance = await this.token.balanceOf(addressClient);
        const tokenAmountWithoutBonuses = amount * PreICORate;
        const bonusByTime = tokenAmountWithoutBonuses * 0.15;
        const bonusByAmount = tokenAmountWithoutBonuses * 0.03;
        const tokenAmount = tokenAmountWithoutBonuses + bonusByTime + bonusByAmount;
        assertEqual(balance.toNumber(), tokenAmount);
    });

    it('should sale token', async function() {
      await this.list.addWallet(addressClient, 3);
      timeController.addSeconds(3601);
      timeController.mineBlock();
      const amount = 10 * (10 ** 18);
      await this.sale.saleTokenPreICO({
        from: addressClient,
        value: amount
      });
      const balance = await this.token.balanceOf(addressClient);
      const tokenAmountWithoutBonuses = amount * PreICORate;
      const bonusByTime = tokenAmountWithoutBonuses * 0.15;
      const bonusByAmount = tokenAmountWithoutBonuses * 0.03;
      const tokenAmount = tokenAmountWithoutBonuses + bonusByTime + bonusByAmount;
      assertEqual(balance.toNumber(), tokenAmount);
    });

    it('should accept a manual refund, if mincap has not been reached', async function() {
          await this.list.addWallet(addressClient, 3);
          timeController.addSeconds(3601);
          timeController.mineBlock();
          const amount = 0.1 * (10 ** 18);
          await this.sale.saleTokenPreICO({
              from: addressClient,
              value: amount
          });
          const tokenBalanceBefore = await this.token.balanceOf(addressClient);
          const ethBalanceBefore = web3.eth.getBalance(addressClient);
          const tokenAmountWithoutBonuses = amount * PreICORate;
          const bonusByTime = tokenAmountWithoutBonuses * 0.15;
          const tokenAmount = tokenAmountWithoutBonuses + bonusByTime;
          assertEqual(tokenBalanceBefore.toNumber(), tokenAmount);


          timeController.addSeconds(86400 * 7 + 1);
          timeController.mineBlock();
          await this.sale.refund({
              from: addressClient
          });

          const tokenBalanceAfter = await this.token.balanceOf(addressClient);
          const ethBalanceAfter = web3.eth.getBalance(addressClient);
          assertEqual(tokenBalanceAfter.toNumber(), 0);
          assertTrue(ethBalanceAfter.toNumber() > ethBalanceBefore.toNumber());
      });

      it('should reject burn tokens if sender is not the owner', async function() {
        const request = this.sale.burnUnsoldTokens({
            from: addressClient
        });
        await request.should.be.rejectedWith("VM Exception while processing transaction: revert");
      });

  });
});






//
