const StringStorage = artifacts.require("StringStorage");
const LibraryMappingString = artifacts.require("LibraryMappingString");

module.exports = (deployer, _network, accounts) => {
  const owner_StringStorage = accounts[0];

  deployer.deploy(LibraryMappingString, { overwrite: false });
  deployer.link(LibraryMappingString, StringStorage);
  deployer.deploy(StringStorage, owner_StringStorage);
};
