"use strict";

//
function promisedWeb3Send(dict) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.send(dict, (error, result) => {
      if (error) {
        return reject(error);
      }
      return resolve(result);
    });
  });
}

//
// @see {link} https://medium.com/fluidity/standing-the-time-of-test-b906fcc374a9
function takeSnapShot() {
  return promisedWeb3Send({
    jsonrpc: "2.0",
    method: "evm_snapshot",
    id: new Date().getTime(),
  });
}

//
function revertToSnapShot(id) {
  return promisedWeb3Send({
    jsonrpc: "2.0",
    method: "evm_revert",
    params: [id],
    id: new Date().getTime(),
  });
}

module.exports = {
  promisedWeb3Send,
  takeSnapShot,
  revertToSnapShot,
};
