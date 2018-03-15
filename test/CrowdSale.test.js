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
  const startPreICO = timeController.currentTimestamp().add(3600);
  const endPreICO = timeController.currentTimestamp().add(7200);
  const startICO = timeController.currentTimestamp().add(10800);
  const endICO = timeController.currentTimestamp().add(14400);

  const PreICORate = 20;  //1 Ether = 20 tokens
  const ICORate = 1;  //1 Ether = 1 token
  const minCap = 1e18;
  const founders = wallets[2];
  const operational = wallets[3];
  const withdrawWallet = wallets[8];
  const ownerICO = wallets[0];

  describe('testing on the air...', () => {


    beforeEach(async function () {
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
      const expectedSupply = 33e5 * (10 ** 18);
      const saleSupply = await this.sale.RESERVED_TOKENS_FOUNDERS();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should have 2.000.000 tokens for operational expenses', async function() {
      const expectedSupply = 2e5 * (10 ** 18);
      const saleSupply = await this.sale.RESERVED_TOKENS_OPERATIONAL_EXPENSES();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should have 5.000.000 tokens as hardcap for preICO', async function() {
      const expectedSupply = 2e6 * (10 ** 18);
      const saleSupply = await this.sale.HARDCAP_TOKENS_PRE_ICO();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should have 70.000.000 tokens as hardcap for ICO', async function() {
      const expectedSupply = 6e6 * (10 ** 18);
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

    // it('should sale token', async function() {
    //   await this.list.addWallet(addressClient);
    //   // timeController.addSeconds(3601);
    //   // timeController.mineBlock();
    //   // await this.sale.saleTokenPreICO({
    //   //   from: addressClient,
    //   //   value: 50 * (10 ** 18)
    //   // });
    //   // const balance = await this.token.balanceOf(addressClient);
    //   // assertEqual(balance.toNumber(), 0);
    // });

    // it('test', async function() {
    //   const list = await this.list.owner();
    //   const token = await this.token.owner();
    //   const sale = this.sale.address;
    //   assertEqual(list, ownerICO);
    // });


  });
});


// function saleTokenPreICO() public payable whenNotPaused whenWhiteListed(msg.sender) {
//   require(isPreICO());
//   require(msg.value > 0);
//   uint256 weiAmount = msg.value;
//   weiRaisedPreICO = weiRaisedPreICO.add(weiAmount);
//   addInvestmentPreICO(msg.sender, weiAmount);
//   uint256 tokenAmountByTime = weiAmount.mul(PreICORate).mul(100 + getBonusByTime()).div(100);
//   uint256 tokenAmountByAmount = getBonusByAmount(weiAmount);
//   uint256 tokenAmount = tokenAmountByTime.add(tokenAmountByAmount);
//   TokenSoldPreICO = TokenSoldPreICO.add(tokenAmount);
//   if(TokenSoldPreICO > HARDCAP_TOKENS_PRE_ICO)
//     revert();
//   tokensRemindingICO = tokensRemindingICO.sub(tokenAmount);
//   token.transferFromICO(msg.sender, tokenAmount);
// }



//
