// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import { AddressStorage } from "@solidity-utilities/address-storage/contracts/AddressStorage.sol";

// import {
//     StringStorage
// } from "@solidity-utilities/string-storage/contracts/StringStorage.sol";
import { StringStorage } from "../../contracts/StringStorage.sol";

import { Account } from "./Account.sol";

/// @title Example contract instance to track `Account` references
/// @author S0AndS0
contract Host {
    address payable public owner;
    /// Mitigate abuse by setting a signup fee to refund `accountBan` gas costs
    uint256 public fee;
    /// Interface for `mapping(string => string)` of host information
    StringStorage public data;
    /// Interfaces mapping references of Account to StringStorage(this)
    AddressStorage public registered;
    AddressStorage public removed;

    /* -------------------------------------------------------------------- */

    ///
    constructor(address payable _owner, uint256 _fee) {
        owner = _owner;
        fee = _fee;
        data = ownedStringStorage();
        registered = ownedAddressStorage();
        removed = ownedAddressStorage();
    }

    /* -------------------------------------------------------------------- */

    /// @notice Record registration of accounts
    event AccountRegistered(
        address account_reference,
        address storage_reference
    );

    /// @notice Record removal of accounts
    event AccountRemoved(address account_reference, address storage_reference);

    /* -------------------------------------------------------------------- */

    /// @notice Add initialized `Account` to `registered` data structure
    /// @param _account_reference **{address}** Previously deployed `Account` contract instance
    /// @custom:throws **{Error}** `"Host.accountRegister: insufficient funds provided"`
    /// @custom:throws **{Error}** `"Host.accountRegister: account already registered or removed"`
    /// @custom:throws **{Error}** `"Host.accountRegister: message sender not authorized"`
    function accountRegister(address _account_reference) external payable {
        require(
            msg.value >= fee,
            "Host.accountRegister: insufficient funds provided"
        );
        require(
            !registered.has(_account_reference) &&
                !removed.has(_account_reference),
            "Host.accountRegister: account already registered or removed"
        );
        require(
            msg.sender == _account_reference ||
                msg.sender == Account(_account_reference).owner(),
            "Host.accountRegister: message sender not authorized"
        );
        address _storage_reference = address(ownedStringStorage());
        registered.set(_account_reference, _storage_reference);
        emit AccountRegistered(_account_reference, _storage_reference);
    }

    /// @notice Move `Account` from `registered` to `removed` data structure
    /// @param _account_reference **{address}** Reference of `Account` to move
    /// @return **{address}** Reference to `StringStorage` for given `Account`
    /// @custom:throws **{Error}** `"Host.accountRemove: message sender not authorized"`
    /// @custom:throws **{Error}** `"Host.accountRemove: account not registered"`
    /// @custom:throws **{Error}** `"Host.accountRemove: account was removed"`
    function accountRemove(address _account_reference)
        external
        returns (address)
    {
        require(
            msg.sender == _account_reference ||
                msg.sender == Account(_account_reference).owner() ||
                msg.sender == owner,
            "Host.accountRemove: message sender not authorized"
        );
        removed.setOrError(
            _account_reference,
            registered.removeOrError(
                _account_reference,
                "Host.accountRemove: account not registered"
            ),
            "Host.accountRemove: account was removed"
        );
        owner.transfer(fee);
        address _storage_reference = removed.get(_account_reference);
        emit AccountRemoved(_account_reference, _storage_reference);
        return _storage_reference;
    }

    /// @notice Update fee to execute `Host.accountRegister`
    /// @custom:throws **{Error}** `"Host.setFee: message sender not owner"`
    function setFee(uint256 _fee) external {
        require(
            msg.sender == owner,
            "Host.setFee: message sender not an owner"
        );
        fee = _fee;
    }

    ///
    function ownedStringStorage() internal returns (StringStorage) {
        StringStorage _instance = new StringStorage(address(this));
        _instance.addAuthorized(address(this));
        _instance.changeOwner(owner);
        return _instance;
    }

    ///
    function ownedAddressStorage() internal returns (AddressStorage) {
        AddressStorage _instance = new AddressStorage(address(this));
        _instance.addAuthorized(address(this));
        _instance.changeOwner(owner);
        return _instance;
    }
}
