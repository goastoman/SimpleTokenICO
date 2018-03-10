export * from './asserts.js';
export { default as timeController } from './timeController.js';
const { BigNumber } = web3;
require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();
