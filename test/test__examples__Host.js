"use strict";

const Host = artifacts.require("Host");
const Account = artifacts.require("Account");
const AddressStorage = artifacts.require("AddressStorage");
const StringStorage = artifacts.require("StringStorage");

const {
  revertToSnapShot,
  takeSnapShot,
} = require("./lib/web3-ganache-helpers.js");

//
contract("test/examples/Host.sol", (accounts) => {
  const Account__owner = accounts[1];
  const Account__new_owner = accounts[9];
  const Account__data__key = "name";
  const Account__data__value = "Jain";

  const Host__owner = accounts[2];
  const Host__fee = 100;

  let snapshot_id;

  //
  beforeEach(async () => {
    snapshot_id = (await takeSnapShot()).result;
  });

  //
  afterEach(async () => {
    await revertToSnapShot(snapshot_id);
  });

  //
  it("Host.accountRegister disallowed from non-account owner", async () => {
    const host = await Host.deployed();
    const account = await Account.deployed();
    try {
      await host.accountRegister(account.address, {
        value: Host__fee,
        from: Host__owner,
      });
    } catch (error) {
      if (
        error.reason === "Host.accountRegister: message sender not authorized"
      ) {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  //
  it("Host.accountRemove: allowed by host owner", async () => {
    const host = await Host.deployed();
    const account = await Account.deployed();
    await host.accountRegister(account.address, {
      value: Host__fee,
      from: Account__owner,
    });
    await host.accountRemove(account.address, { from: Host__owner });
    const host__registered = await AddressStorage.at(await host.registered());
    const host__removed = await AddressStorage.at(await host.removed());
    assert.isFalse(
      await host__registered.has(account.address),
      "Failed to remove account from `host.registered`"
    );
    return assert.isTrue(
      await host__removed.has(account.address),
      "Failed to set account to `host.removed`"
    );
  });

  //
  it("Host.accountRemove disallowed from non-account owner", async () => {
    const host = await Host.deployed();
    const account = await Account.deployed();
    await host.accountRegister(account.address, {
      value: Host__fee,
      from: Account__owner,
    });
    try {
      await host.accountRemove(account.address, {
        from: Account__new_owner,
      });
    } catch (error) {
      if (
        error.reason === "Host.accountRemove: message sender not authorized"
      ) {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });
});
