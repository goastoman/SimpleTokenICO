const assert = require('assert');
import { BigNumber } from 'bignumber.js';
import { assertEqual, assertTrue, timeController } from './utils';

const SimpleToken = artifacts.require('SimpleToken');
let accounts; //our local variables

contract('SimpleToken', (wallets) => {
  const addressICO = wallets[9];
  const addressClient = wallets[1];
  describe('testing on the air', () => {

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

    it('should transfer from ICO', async function() {
      const amount = 1e6 * (10 ** 18);
      await this.token.transferFromICO(addressClient, amount, {
        from: addressICO
      });
      const balance = await this.token.balanceOf(addressClient);
      assertEqual(balance.toNumber(), amount);
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

    it('should burn tokens from', async function() {
      const amount = 1e6 * (10 ** 18);
      const balance = await this.token.balanceOf(addressICO);
      const balanceDecreased = balance.sub(amount).toNumber();
      await this.token.burnFrom(addressICO, amount, {
        from: addressICO
      });
      assertEqual(balance.sub(amount).toNumber(), balanceDecreased);
    });

  });
});






//
