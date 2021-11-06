// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import { StringStorage } from "../contracts/StringStorage.sol";

///
contract Test_StringStorage {
    address payable owner_StringStorage = payable(address(this));
    address payable not_owner_StringStorage = payable(address(0x1));
    string _key = "key";
    string _value = "value";
    string _default_value = "default";

    StringStorage data = new StringStorage(owner_StringStorage);

    ///
    function afterEach() public {
        if (data.has(_key)) {
            data.remove(_key);
        }
    }

    ///
    function test_get_error() public {
        try data.get(_key) returns (string memory _result) {
            Assert.equal(_result, _key, "Failed to catch error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "StringStorage.get: value not defined",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_getOrElse() public {
        string memory _got = data.getOrElse(_key, _default_value);
        Assert.equal(_got, _default_value, "Failed to get default value");
    }

    ///
    function test_getOrError() public {
        try
            data.getOrError(
                _key,
                "Test_StringStorage.test_getOrError: value not defined"
            )
        returns (string memory _result) {
            Assert.equal(_result, _key, "Failed to catch error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "Test_StringStorage.test_getOrError: value not defined",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_has() public {
        Assert.isFalse(data.has(_key), "Somehow key/value was defined");
        data.set(_key, _value);
        Assert.isTrue(data.has(_key), "Failed to define key/value pair");
    }

    ///
    function test_remove_error() public {
        try data.remove(_key) returns (string memory _result) {
            Assert.equal(_result, _key, "Failed to catch error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "StringStorage.remove: value not defined",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_removeOrError() public {
        string
            memory _custom_reason = "Test_StringStorage.test_removeOrError: value not defined";
        try data.removeOrError(_key, _custom_reason) returns (
            string memory _result
        ) {
            Assert.equal(_result, _key, "Failed to catch error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                _custom_reason,
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_selfdestruct() public {
        StringStorage _data = new StringStorage(owner_StringStorage);
        _data.selfDestruct(owner_StringStorage);
    }

    ///
    function test_selfdestruct_non_owner() public {
        StringStorage _data = new StringStorage(not_owner_StringStorage);
        try _data.selfDestruct(owner_StringStorage) {
            Assert.isTrue(false, "Failed to catch expected error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "StringStorage.selfDestruct: message sender not an owner",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_set() public {
        data.set(_key, _value);
        string memory _got = data.get(_key);
        Assert.equal(_got, _value, "Failed to get expected value");
    }

    ///
    function test_set_error() public {
        data.set(_key, _value);
        try data.set(_key, _value) {
            Assert.isTrue(false, "Failed to catch expected error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "StringStorage.set: value already defined",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_setOrError() public {
        string
            memory _custom_reason = "Test_StringStorage.test_setOrError: value already defined";
        data.set(_key, _value);
        try data.setOrError(_key, _value, _custom_reason) {
            Assert.isTrue(false, "Failed to catch expected error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                _custom_reason,
                "Caught unexpected error reason"
            );
        }
    }
}
