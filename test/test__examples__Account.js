"use strict";

const Account = artifacts.require("Account");
const Host = artifacts.require("Host");
const AddressStorage = artifacts.require("AddressStorage");
const StringStorage = artifacts.require("StringStorage");

const {
  revertToSnapShot,
  takeSnapShot,
} = require("./lib/web3-ganache-helpers.js");

//
contract("test/examples/Account.sol", (accounts) => {
  const Account__owner = accounts[1];
  const Account__new_owner = accounts[9];
  const Account__data__key = "name";
  const Account__data__value = "Jain";

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
  it("Account.changeOwner allowed by owner", async () => {
    const account = await Account.deployed();
    await account.changeOwner(Account__new_owner, {
      from: Account__owner,
    });
    return assert.equal(
      Account__new_owner,
      await account.owner(),
      "Failed to change Account owner"
    );
  });

  //
  it("Account.changeOwner disallowed from non-owner", async () => {
    const account = await Account.deployed();
    try {
      await account.changeOwner(Account__new_owner, {
        from: Account__new_owner,
      });
    } catch (error) {
      if (error.reason === "Account.changeOwner: message sender not an owner") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  //
  it("Account.hostRegister allowed by owner", async () => {
    const account = await Account.deployed();
    const host = await Host.deployed();
    await account.hostRegister(host.address, {
      value: Host__fee,
      from: Account__owner,
    });
    const account__registered = await AddressStorage.at(
      await account.registered()
    );
    assert.isTrue(
      await account__registered.has(host.address),
      "Failed to register host to account"
    );
    const host__registered = await AddressStorage.at(await host.registered());
    assert.isTrue(
      await host__registered.has(account.address),
      "Faled to register account to host"
    );
  });

  //
  it("Account.hostRegister disallowed from non-owner", async () => {
    const account = await Account.deployed();
    const host = await Host.deployed();
    try {
      await account.hostRegister(host.address, {
        from: Account__new_owner,
      });
    } catch (error) {
      if (error.reason === "Account.hostRegister: message sender not an owner") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  //
  it("Account.hostRemove allowed by owner", async () => {
    const account = await Account.deployed();
    const host = await Host.deployed();
    await account.hostRegister(host.address, {
      value: Host__fee,
      from: Account__owner,
    });
    await account.hostRemove(host.address, {
      from: Account__owner,
    });
    const account__registered = await AddressStorage.at(
      await account.registered()
    );
    const account__removed = await AddressStorage.at(await account.removed());
    assert.isFalse(
      await account__registered.has(host.address),
      "Failed to remove host from `accout.registered`"
    );
    return assert.isTrue(
      await account__removed.has(host.address),
      "Failed to set host to `accout.removed`"
    );
  });

  //
  it("Account.hostRemove disallowed from non-owner", async () => {
    const account = await Account.deployed();
    const host = await Host.deployed();
    try {
      await account.hostRemove(host.address, {
        from: Account__new_owner,
      });
    } catch (error) {
      if (error.reason === "Account.hostRemove: message sender not an owner") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  /**
   * @note The `.call` bit is required to get `value` instead of `tx` Object
   */
  it("Account.data().remove allowed by owner", async () => {
    const account = await Account.deployed();
    const account__data = await StringStorage.at(await account.data());
    await account__data.set(Account__data__key, Account__data__value, {
      from: Account__owner,
    });
    const got_value = await account__data.remove.call(Account__data__key, {
      from: Account__owner,
    });
    return assert.equal(
      got_value,
      Account__data__value,
      "Failed to remove expected value"
    );
  });
});
