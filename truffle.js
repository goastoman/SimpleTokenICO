require('babel-polyfill');
require('babel-register');

module.exports = {
  networks: {
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
  },
};
