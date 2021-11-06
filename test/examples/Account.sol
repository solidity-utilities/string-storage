// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import { AddressStorage } from "@solidity-utilities/address-storage/contracts/AddressStorage.sol";

// import {
//     StringStorage
// } from "@solidity-utilities/string-storage/contracts/StringStorage.sol";
import { StringStorage } from "../../contracts/StringStorage.sol";

import { Host } from "./Host.sol";

/// @title Example contract instance to track `Host` references
/// @author S0AndS0
contract Account {
    address payable public owner;
    /// Interface for `mapping(string => string)`
    StringStorage public data;
    /// Interfaces mapping references of Host to StringStorage(this)
    AddressStorage public registered;
    AddressStorage public removed;

    /* -------------------------------------------------------------------- */

    ///
    constructor(address payable _owner) {
        owner = _owner;
        data = ownedStringStorage();
        registered = ownedAddressStorage();
        removed = ownedAddressStorage();
    }

    /* -------------------------------------------------------------------- */

    /// @notice Require message sender to be an instance owner
    /// @param _caller {string} Function name that implements this modifier
    modifier onlyOwner(string memory _caller) {
        string memory _message = string(
            abi.encodePacked(
                "Account.",
                _caller,
                ": message sender not an owner"
            )
        );
        require(msg.sender == owner, _message);
        _;
    }

    /* -------------------------------------------------------------------- */

    /// @notice Record registration of hosts
    event HostRegistered(address host_reference, address storage_reference);

    /// @notice Record removal of hosts
    event HostRemoved(address host_reference, address storage_reference);

    /* -------------------------------------------------------------------- */

    /// @notice Update `Account.owner`
    /// @dev Changing ownership for `data` and `registered` elements may be a good idea
    /// @param _new_owner **{address}** Address to assign to `Account.owner`
    /// @custom:throws **{Error}** `"Account.changeOwner: message sender not an owner"`
    function changeOwner(address payable _new_owner)
        external
        onlyOwner("changeOwner")
    {
        owner = _new_owner;
    }

    /// @notice Add `Host` reference to `registered` data structure
    /// @dev Likely a better idea to pre-check if has `registered` and `removed`
    /// @param _host_reference **{address}** Reference to `Host` to registered to
    /// @custom:throws **{Error}** `"Account.hostRegister: message sender not an owner"`
    /// @custom:throws **{Error}** `"Account.hostRegister: host already registered"`
    function hostRegister(address _host_reference)
        external
        payable
        onlyOwner("hostRegister")
    {
        require(
            !removed.has(_host_reference),
            "Account.hostRegister: host is removed"
        );
        Host(_host_reference).accountRegister{ value: msg.value }(
            address(this)
        );
        StringStorage _storage_instance = ownedStringStorage();
        registered.setOrError(
            _host_reference,
            address(_storage_instance),
            "Account.hostRegister: host already registered"
        );
        emit HostRegistered(_host_reference, address(_storage_instance));
    }

    /// @notice Move `Host` from `registered` to `removed` data structure
    /// @param _host_reference **{address}** Reference to `Host` to move
    /// @return **{address}** Reference to `StringStorage` for given `Host`
    /// @custom:throws **{Error}** `"Account.hostRemove: message sender not an owner"`
    /// @custom:throws **{Error}** `"Account.hostRemove: host not registered"`
    /// @custom:throws **{Error}** `"Account.hostRemove: host was removed"`
    function hostRemove(address _host_reference)
        external
        onlyOwner("hostRemove")
        returns (address)
    {
        removed.setOrError(
            _host_reference,
            registered.removeOrError(
                _host_reference,
                "Account.hostRemove: host not registered"
            ),
            "Account.hostRemove: host was removed"
        );
        address _storage_reference = removed.get(_host_reference);
        emit HostRemoved(_host_reference, _storage_reference);
        Host _host_instance = Host(_host_reference);
        if (_host_instance.registered().has(address(this))) {
            _host_instance.accountRemove(address(this));
        }
        return _storage_reference;
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
