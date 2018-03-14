const assert = require('assert');
import { BigNumber } from 'bignumber.js';
import { assertEqual, assertTrue, timeController } from './utils';

const CrowdSale = artifacts.require('CrowdSale');
const SimpleToken = artifacts.require('SimpleToken');
let accounts; //our local variables

contract('CrowdSale test', (wallets) => {
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

    it('should have 33.000.000 tokens for founders', async function() {
      const expectedSupply = 33e5 * (10 ** 18);
      const saleSupply = await this.sale.RESERVED_TOKENS_FOUNDERS();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should have 200.000 tokens for operational expenses', async function() {
      const expectedSupply = 2e5 * (10 ** 18);
      const saleSupply = await this.sale.RESERVED_TOKENS_OPERATIONAL_EXPENSES();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should have 2.000.000 tokens as hardcap for preICO', async function() {
      const expectedSupply = 2e6 * (10 ** 18);
      const saleSupply = await this.sale.HARDCAP_TOKENS_PRE_ICO();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should have 6.000.000 tokens as hardcap for ICO', async function() {
      const expectedSupply = 6e6 * (10 ** 18);
      const saleSupply = await this.sale.HARDCAP_TOKENS_ICO();
      assertEqual(expectedSupply, saleSupply.toNumber());
    });

    it('should manual transfer', async function() {
      await this.sale.unpause();
      const amount = 1e6 * (10 ** 18);
      const balance = await this.sale.balanceOf(addressClient);
      await this.sale.manualTransferToken(addressClient, amount, {
        from: ownerICO
      })
      assertEqual(balance.toNumber(), amount);
    })



  });
});


//
// function manualTransferToken(address _to, uint256 _amount) onlyOwner external {
//   require(_to != address(0x0));
//   tokensRemindingICO = tokensRemindingICO.sub(_amount);
//   token.transferFromICO(_to, _amount);
// }
