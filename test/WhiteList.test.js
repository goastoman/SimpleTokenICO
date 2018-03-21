const assert = require('assert');
import { BigNumber } from 'bignumber.js';
import { assertEqual, assertTrue, assertFalse, timeController } from './utils';

const CrowdSale = artifacts.require('CrowdSale');
const SimpleToken = artifacts.require('SimpleToken');
const WhiteList = artifacts.require('WhiteList');
let accounts; //our local variables

contract('WhiteList', (wallets) => {
  const addressICO = wallets[9];
  const addressClient = wallets[1];

  describe('testing on the air...', () => {

    beforeEach(async function() {
      this.list = await WhiteList.new();
    });

    // it('should check is wallet added', async function() {
    //   const result = await this.list.isWhiteListed(addressClient);
    //   const tmo = result.toNumber();
    //   assertFalse(tmo > 0);
    // });

    it('should add wallet to map', async function() {
      const walletAdded = await this.list.addWallet(addressClient, 1);
      // const result = await this.list.isWhiteListed(addressClient);
      const result = await this.list.isWhiteListed(addressClient);
      assertTrue(result.toNumber());
    });

    // it('should delete wallet from map', async function() {
    //   const walletAdded = await this.list.addWallet(addressClient);
    //   const walletDeleted = await this.list.deleteWallet(addressClient);
    //   const request = await this.list.isWhiteListed(addressClient);
    //   assertTrue(request, true);
    // });

  });
});


//ethBalanceAfter
//assertTrue(ethBalanceAfter.toNumber() > ethBalanceBefore.toNumber());
