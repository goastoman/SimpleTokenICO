const assert = require('assert');
import { BigNumber } from 'bignumber.js';
import { assertEqual, assertTrue, timeController } from './utils';

const SimpleToken = artifacts.require('SimpleToken');
let accounts; //our local variables

contract('SimpleToken', function(wallets) {
  const addressICO = wallets[9];
  const addressClient = wallets[1];
  describe('testing on the air...', () => {

    beforeEach(async function () {
      this.token = await SimpleToken.new(addressICO);
    });

    // it('deploys a contract', () => {
    //   assert.ok(SimpleToken.options.address);
    // });

    it('should have right name: SimpleToken', async function() {
      const expectedName = 'SimpleToken';
      const tokenName = await this.token.name();
      assert.equal(expectedName, tokenName);
    });

    it('should have right symbol: ST', async function() {
      const expectedSymbol = 'ST';
      const tokenSymbol = await this.token.symbol();
      assert.equal(expectedSymbol, tokenSymbol);
    });

    it('should have right decimals: 18', async function() {
      const expectedDec = 18;
      const tokenDec = await this.token.decimals();
      assert.equal(expectedDec, tokenDec.toNumber());
    });

    it('should have 100.000.000 tokens', async function() {
      const expectedSupply = 100e6 * (10 ** 18);
      const tokenSupply = await this.token.INITIAL_TOTAL_SUPPLY();
      assert.equal(expectedSupply, tokenSupply.toNumber());
    });

    it('should have some balance', async function() {
      const balance = await this.token.balanceOf(addressICO);
      assert.equal(balance.toNumber(), 100e6 * (10 ** 18))

    });

    it('should transfer', async function() {
      await this.token.unpause();
      const amount = 1e6 * (10 ** 18);
      await this.token.transfer(addressClient, amount, {
        from: addressICO
      });
      const balance = await this.token.balanceOf(addressClient);
      assert.equal(balance.toNumber(), amount);
    });

    it('should be reverted', async function() {
      await this.token.unpause();
      const amount = 1e10 * (10 ** 18);
      const transfer = this.token.transfer(addressClient, amount, {
        from: addressICO
      });
      await transfer.should.be.rejectedWith('VM Exception while processing transaction: revert');
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
      assert.equal(balance.toNumber(), amount);
    });

    it('should transfer from ICO', async function() {
      const amount = 1e6 * (10 ** 18);
      await this.token.transferFromICO(addressClient, amount, {
        from: addressICO
      });
      const balance = await this.token.balanceOf(addressClient);
      assert.equal(balance.toNumber(), amount);
    });

    it('should burn tokens from ICO', async function() {
      await this.token.unpause();
      const amount = 1e6 * (10 ** 18);
      await this.token.burnFromICO({
        from: addressICO
      });
      const balance = await this.token.balanceOf(addressICO);
      assert.equal(balance.toNumber(), 0);
    });

    it('should burn tokens from wallet', async function() {
      const amount = 1e6 * (10 ** 18);
      const balance = await this.token.balanceOf(addressICO);
      const balanceDecreased = balance.sub(amount).toNumber();
      await this.token.burnFrom(addressICO, amount, {
        from: addressICO
      });
      assert.equal(balance.sub(amount).toNumber(), balanceDecreased);
    });

  });
});






//
