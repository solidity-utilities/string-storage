"use strict";

module.exports = (deployer, network, accounts) => {
  if (network !== "development") {
    return;
  }

  console.log("Notice: detected network of development kind ->", { network });

  const LibraryMappingString = artifacts.require("LibraryMappingString");
  const StringStorage = artifacts.require("StringStorage");

  const LibraryMappingAddress = artifacts.require("LibraryMappingAddress");
  const AddressStorage = artifacts.require("AddressStorage");

  const Account = artifacts.require("Account");
  const Host = artifacts.require("Host");

  const StringStorage__owner = accounts[0];
  const Account__owner = accounts[1];
  const Host__owner = accounts[2];
  const Host__fee = 100;

  // LibraryMappingString.address = "0x0...";
  deployer.deploy(LibraryMappingString, { overwrite: false });
  deployer.link(LibraryMappingString, [StringStorage, Account, Host]);

  // LibraryMappingAddress.address = "0x1...";
  deployer.deploy(LibraryMappingAddress, { overwrite: false });
  deployer.link(LibraryMappingAddress, [AddressStorage, Account, Host]);

  // deployer.deploy(StringStorage, StringStorage__owner);
  deployer.deploy(Account, Account__owner);
  deployer.deploy(Host, Host__owner, Host__fee);
};
