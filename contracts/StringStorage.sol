// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import { LibraryMappingString } from "@solidity-utilities/library-mapping-string/contracts/LibraryMappingString.sol";

/// @title contract for storing and interacting with key/value string pairs
/// @dev Depends on `@solidity-utilities/library-mapping-string`
/// @author S0AndS0
contract StringStorage {
    using LibraryMappingString for mapping(string => string);
    /// Store key/value `string` pairs
    mapping(string => string) public data;
    /// Warning order of indexes **NOT** guaranteed!
    mapping(string => uint256) public indexes;
    /// Warning order of keys **NOT** guaranteed!
    string[] public keys;
    /// Allow mutation from specified `address`
    address public owner;
    /// Allow mutation from specified `address`s
    mapping(address => bool) authorized;

    /* -------------------------------------------------------------------- */

    /// @notice Define instance of `StringStorage`
    /// @param _owner **{address}** Account or contract authorized to mutate stored data
    constructor(address _owner) {
        owner = _owner;
    }

    /* -------------------------------------------------------------------- */

    /// @notice Requires message sender to be an instance owner
    /// @param _caller **{string}** Function name that implements this modifier
    /// @custom:throws **{Error}** `"StringStorage._caller: message sender not an owner"`
    modifier onlyOwner(string memory _caller) {
        string memory _message = string(
            abi.encodePacked(
                "StringStorage.",
                _caller,
                ": message sender not an owner"
            )
        );
        require(msg.sender == owner, _message);
        _;
    }

    /// @notice Requires message sender to be in authorized mapping or contract owner
    /// @param _caller **{string}** Function name that implements this modifier
    /// @custom:throws **{Error}** `"StringStorage._caller: message sender not authorized"`
    modifier onlyAuthorized(string memory _caller) {
        string memory _message = string(
            abi.encodePacked(
                "StringStorage.",
                _caller,
                ": message sender not authorized"
            )
        );
        require(authorized[msg.sender] || msg.sender == owner, _message);
        _;
    }

    /* -------------------------------------------------------------------- */

    /// @notice Insert `address` into `mapping` of `authorized` data structure
    /// @dev Does not check if `address` is already `authorized`
    /// @param _key **{address}** Key to set value of `true`
    /// @custom:throws **{Error}** `"StringStorage.addAuthorized: message sender not an owner"`
    function addAuthorized(address _key) external onlyOwner("addAuthorized") {
        authorized[_key] = true;
    }

    /// @notice Overwrite old `owner` with new owner `address`
    /// @param _new_owner **{address}** New owner address
    /// @custom:throws **{Error}** `"StringStorage.changeOwner: message sender not an owner"`
    function changeOwner(address _new_owner) external onlyOwner("changeOwner") {
        owner = _new_owner;
    }

    /// @notice Delete `mapping` string key/value pairs and remove all `string` from `keys`
    /// @dev **Warning** may fail if storing many `string` pairs
    /// @custom:throws **{Error}** `"StringStorage.clear: message sender not an owner"`
    function clear() external onlyAuthorized("clear") {
        uint256 _index = keys.length;
        while (_index > 0) {
            _index--;
            string memory _key = keys[_index];
            data.remove(_key);
            delete indexes[_key];
            keys.pop();
        }
    }

    /// @notice Remove `address` from `mapping` of `authorized` data structure
    /// @param _key **{address}** Key to set value of `false`
    /// @custom:throws **{Error}** `"StringStorage.deleteAuthorized: message sender not authorized"`
    /// @custom:throws **{Error}** `"StringStorage.deleteAuthorized: cannot remove owner"`
    function deleteAuthorized(address _key)
        external
        onlyAuthorized("deleteAuthorized")
    {
        require(
            msg.sender == owner || msg.sender == _key,
            "AddressStorage.deleteAuthorized: message sender not authorized"
        );
        require(
            _key != owner,
            "AddressStorage.deleteAuthorized: cannot remove owner"
        );
        delete authorized[_key];
    }

    /// @notice Retrieve stored value `string` or throws an error if _undefined_
    /// @dev Passes parameter to `data.getOrError` with default Error `_reason` to throw
    /// @param _key **{string}** Mapping key `string` to lookup corresponding value `string` for
    /// @return **{string}** Value for given key `string`
    /// @custom:throws **{Error}** `"StringStorage.get: value not defined"`
    function get(string calldata _key) public view returns (string memory) {
        return data.getOrError(_key, "StringStorage.get: value not defined");
    }

    /// @notice Retrieve stored value `string` or provided default `string` if _undefined_
    /// @dev Forwards parameters to `data.getOrElse`
    /// @param _key **{string}** Mapping key `string` to lookup corresponding value `string` for
    /// @param _default **{string}** Value to return if key `string` lookup is _undefined_
    /// @return **{string}** Value `string` for given key `string` or `_default` if _undefined_
    function getOrElse(string calldata _key, string calldata _default)
        external
        view
        returns (string memory)
    {
        return data.getOrElse(_key, _default);
    }

    /// @notice Allow for defining custom error reason if value `string` is _undefined_
    /// @dev Forwards parameters to `data.getOrError`
    /// @param _key **{string}** Mapping key `string` to lookup corresponding value `string` for
    /// @param _reason **{string}** Custom error message to throw if value `string` is _undefined_
    /// @return **{string}** Value for given key `string`
    /// @custom:throws **{Error}** `_reason` if value is _undefined_
    function getOrError(string calldata _key, string memory _reason)
        external
        view
        returns (string memory)
    {
        return data.getOrError(_key, _reason);
    }

    /// @notice Check if `string` key has a corresponding value `string` defined
    /// @dev Forwards parameter to `data.has`
    /// @param _key **{string}** Mapping key to check if value `string` is defined
    /// @return **{bool}** `true` if value `string` is defined, or `false` if _undefined_
    function has(string calldata _key) public view returns (bool) {
        return data.has(_key);
    }

    /// @notice Index for `string` key within `keys` array
    /// @dev Passes parameter to `indexOfOrError` with default `_reason`
    /// @param _key **{string}** Key to lookup index for
    /// @return **{uint256}** Current index for given `_key` within `keys` array
    /// @custom:throws **{Error}** `"StringStorage.indexOf: key not defined"`
    function indexOf(string calldata _key) external view returns (uint256) {
        return indexOfOrError(_key, "StringStorage.indexOf: key not defined");
    }

    /// @notice Index for `string` key within `keys` array
    /// @dev Cannot depend on results being valid if mutation is allowed between calls
    /// @param _key **{string}** Key to lookup index for
    /// @param _reason **{string}** Custom error message to throw if value `string` is _undefined_
    /// @return **{uint256}** Current index for given `_key` within `keys` array
    /// @custom:throws **{Error}** `_reason` if value for `_key` is _undefined_
    function indexOfOrError(string calldata _key, string memory _reason)
        public
        view
        returns (uint256)
    {
        require(data.has(_key), _reason);
        return indexes[_key];
    }

    /// @notice Convenience function to read all `mapping` key strings
    /// @dev Cannot depend on results being valid if mutation is allowed between calls
    /// @return **{string[]}** Keys `string` array
    function listKeys() external view returns (string[] memory) {
        return keys;
    }

    /// @notice Delete value `string` for given `_key`
    /// @dev Passes parameter to `removeOrError` with default `_reason`
    /// @param _key **{string}** Mapping key to delete corresponding value `string` for
    /// @return **{string}** Value `string` that was removed from `data` storage
    /// @custom:throws **{Error}** `"StringStorage.remove: message sender not an owner"`
    /// @custom:throws **{Error}** `"StringStorage.remove: value not defined"`
    function remove(string calldata _key)
        public
        onlyAuthorized("remove")
        returns (string memory)
    {
        return removeOrError(_key, "StringStorage.remove: value not defined");
    }

    /// @notice Delete value `string` for given `_key`
    /// @dev **Warning** reorders `keys`, and mutates `indexes`, for efficiency reasons
    /// @param _key **{string}** Mapping key to delete corresponding value `string` for
    /// @param _reason **{string}** Custom error message to throw if value `string` is _undefined_
    /// @return **{string}** Value `string` that was removed from `data` storage
    /// @custom:throws **{Error}** `"StringStorage.removeOrError: message sender not an owner"`
    /// @custom:throws **{Error}** `_reason` if value is _undefined_
    function removeOrError(string calldata _key, string memory _reason)
        public
        onlyAuthorized("removeOrError")
        returns (string memory)
    {
        string memory _value = data.removeOrError(_key, _reason);
        uint256 _last_index = keys.length - 1;
        string memory _last_key = keys[_last_index];
        if (keys.length > 1) {
            uint256 _target_index = indexes[_key];
            keys[_target_index] = keys[_last_index];
            indexes[_last_key] = _target_index;
        }
        delete indexes[_last_key];
        keys.pop();
        return _value;
    }

    /// @notice Call `selfdestruct` with provided `address`
    /// @param _to **{address}** Where to transfer any funds this contract has
    /// @custom:throws **{Error}** `"StringStorage.selfDestruct: message sender not an owner"`
    function selfDestruct(address payable _to)
        external
        onlyOwner("selfDestruct")
    {
        selfdestruct(_to);
    }

    /// @notice Store `_value` under given `_key` while preventing unintentional overwrites
    /// @dev Forwards parameters to `setOrError` with default `_reason`
    /// @param _key **{string}** Mapping key to set corresponding value `string` for
    /// @param _value **{string}** Mapping value to set
    /// @custom:throws **{Error}** `"StringStorage.set: message sender not an owner"`
    /// @custom:throws **{Error}** `"StringStorage.set: value already defined"`
    function set(string calldata _key, string calldata _value)
        external
        onlyAuthorized("set")
    {
        setOrError(_key, _value, "StringStorage.set: value already defined");
    }

    /// @notice Store `_value` under given `_key` while preventing unintentional overwrites
    /// @dev Forwards parameters to `data.setOrError`
    /// @param _key **{string}** Mapping key to set corresponding value `string` for
    /// @param _value **{string}** Mapping value to set
    /// @param _reason **{string}** Custom error message to present if value `string` is defined
    /// @custom:throws **{Error}** `"StringStorage.setOrError: message sender not an owner"`
    /// @custom:throws **{Error}** `_reason` if value is defined
    function setOrError(
        string calldata _key,
        string calldata _value,
        string memory _reason
    ) public onlyAuthorized("setOrError") {
        data.setOrError(_key, _value, _reason);
        indexes[_key] = keys.length;
        keys.push(_key);
    }

    /// @notice Number of key/value `string` pairs stored
    /// @dev Cannot depend on results being valid if mutation is allowed between calls
    /// @return **{uint256}** Length of `keys` array
    function size() external view returns (uint256) {
        return keys.length;
    }
}
