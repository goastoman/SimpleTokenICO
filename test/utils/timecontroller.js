export default (() => {
  const addSeconds = seconds => (
    new Promise((resolve, reject) =>
      web3.currentProvider.sendAsync({
        jsonrpc: '2.0',
        method: 'evm_increaseTime',
        params: [seconds],
        id: new Date().getTime(),
      }, (error, result) => (error ? reject(error) : resolve(result.result))))
  );

  const addDays = days => addSeconds(days * 24 * 60 * 60);

  const currentTimestamp = () =>
    new web3.BigNumber(web3.eth.getBlock(web3.eth.blockNumber).timestamp);

  const mineBlock = () => (
    new Promise((resolve, reject) =>
      web3.currentProvider.sendAsync({
        jsonrpc: '2.0',
        method: 'evm_mine',
        id: new Date().getTime(),
      }, (error, result) => (error ? reject(error) : resolve(result.result))))
  );

  return {
    addSeconds,
    addDays,
    currentTimestamp,
    mineBlock
  };
})();
