# String Storage
[heading__top]:
  #string-storage
  "&#x2B06; Solidity contract for storing and interacting with key/value string pairs"


Solidity contract for storing and interacting with key/value string pairs


## [![Byte size of String Storage][badge__main__string_storage__source_code]][string_storage__main__source_code] [![Open Issues][badge__issues__string_storage]][issues__string_storage] [![Open Pull Requests][badge__pull_requests__string_storage]][pull_requests__string_storage] [![Latest commits][badge__commits__string_storage__main]][commits__string_storage__main] [![Build Status][badge__github_actions]][activity_log__github_actions]


---


- [:arrow_up: Top of Document][heading__top]

- [:building_construction: Requirements][heading__requirements]

- [:zap: Quick Start][heading__quick_start]

- [&#x1F9F0; Usage][heading__usage]

- [&#x1F523; API][heading__api]
  - [Contract `StringStorage`][heading__contract_stringstorage]
    - [Method `addAuthorized`][heading__method_addauthorized]
    - [Method `changeOwner`][heading__method_changeowner]
    - [Method `changeOwner`][heading__method_changeowner]
    - [Method `clear`][heading__method_clear]
    - [Method `get`][heading__method_get]
    - [Method `getOrElse`][heading__method_getorelse]
    - [Method `getOrError`][heading__method_getorerror]
    - [Method `has`][heading__method_has]
    - [Method `indexOf`][heading__method_indexof]
    - [Method `indexOfOrError`][heading__method_indexoforerror]
    - [Method `listKeys`][heading__method_listkeys]
    - [Method `remove`][heading__method_remove]
    - [Method `removeOrError`][heading__method_removeorerror]
    - [Method `selfDestruct`][heading__method_selfdestruct]
    - [Method `set`][heading__method_set]
    - [Method `setOrError`][heading__method_setorerror]
    - [Method `size`][heading__method_size]

- [&#x1F5D2; Notes][heading__notes]

- [:chart_with_upwards_trend: Contributing][heading__contributing]
  - [:trident: Forking][heading__forking]
  - [:currency_exchange: Sponsor][heading__sponsor]

- [:card_index: Attribution][heading__attribution]

- [:balance_scale: Licensing][heading__license]


---



## Requirements
[heading__requirements]:
  #requirements
  "&#x1F3D7; Prerequisites and/or dependencies that this project needs to function properly"


> Prerequisites and/or dependencies that this project needs to function properly


This project utilizes Truffle for organization of source code and tests, thus
it is recommended to install Truffle _globally_ to your current user account


```Bash
npm install -g truffle
```


______


## Quick Start
[heading__quick_start]:
  #quick-start
  "&#9889; Perhaps as easy as one, 2.0,..."


> Perhaps as easy as one, 2.0,...


NPM and Truffle are recommended for importing and managing dependencies


```Bash
cd your_project

npm install @solidity-utilities/string-storage
```


> Note, source code will be located within the
> `node_modules/@solidity-utilities/string-storage` directory of
> _`your_project`_ root


Solidity contracts may then import code via similar syntax as shown


```Solidity
import {
    StringStorage
} from "@solidity-utilities/string-storage/contracts/StringStorage.sol";
```


> Note, above path is **not** relative (ie. there's no `./` preceding the file
> path) which causes Truffle to search the `node_modules` subs-directories


Review the [Truffle -- Package Management via NPM][truffle__package_management_via_npm] documentation for more details.


______


## Usage
[heading__usage]:
  #usage
  "&#x1F9F0; How to utilize this repository"


> How to utilize this repository


Write a set of contracts that make use of, and extend, `StringStorage` features.


[**`contracts/Account.sol`**][source__test__examples__account_sol]


```Solidity
// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import {
  AddressStorage
} from "@solidity-utilities/address-storage/contracts/AddressStorage.sol";

import {
    StringStorage
} from "@solidity-utilities/string-storage/contracts/StringStorage.sol";

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
```


The above `Account.sol` contract;


- allows for storing `owner` information within `data` contract, such as preferred user-name

- restricts certain mutation actions to owner only

- tracks references to `Host` and related `StringStorage` instances


> Note, in this example the `Host` to `StringStorage` references are configured
> such that `Account().owner` may write host specific information, such as
> avatar URL. However, be aware it is up to each `Host` site if data within
> `Account().data` and/or `Account().registered.get(_ref_)` are used, and how.


[**`contracts/Host.sol`**][source__test__examples__host_sol]


```Solidity
// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import {
  AddressStorage
} from "@solidity-utilities/address-storage/contracts/AddressStorage.sol";

import {
    StringStorage
} from "@solidity-utilities/string-storage/contracts/StringStorage.sol";

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
```


The above `Host.sol` contract;


- allows for storing information within `data` contract, such as site URL

- restricts certain mutation actions to `owner` or individual `Account` owners

- tracks references to `Account` and related `StringStorage` instances


> Note, in this example the `Account` to `StringStorage` references are
> configured such that `Host().owner` may write host specific information,
> such as site permissions.


---


There is much more that can be accomplished by leveraging abstractions provided
by `StringStorage`, check the [API][heading__api] section for full set of
features available. And review the
[`test/test__examples__Account.js`][source__test__test__examples__account_js]
and
[`test/test__examples__Host.js`][source__test__test__examples__host_js]
files for inspiration on how to use these examples within projects.


______


## API
[heading__api]:
  #api
  "Application Programming Interfaces for Solidity smart contracts"


> Application Programming Interfaces for Solidity smart contracts


---


### Contract `StringStorage`
[heading__contract_stringstorage]:
  #contract-stringstorage
  "Solidity contract for storing and interacting with key/value string pairs"


> Solidity contract for storing and interacting with key/value string pairs


**Source** [`contracts/StringStorage.sol`][source__contracts__stringstorage_sol]


**Properties**


- `data` **{mapping(string => string)}** Store key/value `string` pairs

- `indexes` **{mapping(string => uint256)}** Warning order of indexes **NOT** guaranteed!

- `keys` **{string[]}** Warning order of keys **NOT** guaranteed!

- `owner` **{address}** Allow mutation from specified `address`

- `authorized` **{mapping(address => bool)}** Allow mutation from specified `address`s


**Developer note** -> Depends on
[`@solidity-utilities/library-mapping-string`][docs__library_mapping_string]


---

#### Method `addAuthorized`
[heading__method_addauthorized]:
  #method-addauthorized
  "Insert `address` into `mapping` of `authorized` data structure"


> Insert `address` into `mapping` of `authorized` data structure


[**Source**][source__contracts__stringstorage_sol__addauthorized] `addAuthorized(address _key)`


**Parameters**


- `_key` **{address}** Key to set value of `true`


**Throws** -> **{Error}** `"StringStorage.addAuthorized: message sender not an owner"`


**Developer note** -> Does not check if `address` is already `authorized`


---

#### Method `changeOwner`
[heading__method_changeowner]:
  #method-changeowner
  "Overwrite old `owner` with new owner `address`"


> Overwrite old `owner` with new owner `address`


[**Source**][source__contracts__stringstorage_sol__changeowner] `changeOwner(address _new_owner)`


**Parameters**


- `_new_owner` **{address}** New owner address


**Throws** -> **{Error}** `"StringStorage.changeOwner: message sender not an owner"`


---


#### Method `clear`
[heading__method_clear]:
  #method-clear
  "Delete `mapping` string key/value pairs and remove all `string` from `keys`"


> Delete `mapping` string key/value pairs and remove all `string` from `keys`


[**Source**][source__contracts__stringstorage_sol__clear] `clear()`


**Throws** -> **{Error}** `"StringStorage.clar: message sender not an owner"`


**Developer note** -> **Warning** may fail if storing many `string` pairs


---


#### Method `deleteAuthorized`
[heading__method_deleteauthorized]:
  #method-deleteauthorized
  "Remove `address` from `mapping` of `authorized` data structure"


> Remove `address` from `mapping` of `authorized` data structure


[**Source**][source__contracts__stringstorage_sol__deleteauthorized] `deleteAuthorized(address _key)`


**Parameters**


- `_key` **{address}** Key to set value of `false`


**Throws**


- **{Error}** `"StringStorage.deleteAuthorized: message sender not authorized"`

- **{Error}** `"StringStorage.deleteAuthorized: cannot remove owner"`


---



#### Method `get`
[heading__method_get]:
  #method-get
  "Retrieve stored value `string` or throws an error if _undefined_"


> Retrieve stored value `string` or throws an error if _undefined_


[**Source**][source__contracts__stringstorage_sol__get] `get(string _key)`


**Parameters**


- `_key` **{string}** Mapping key `string` to lookup corresponding value `string` for


**Returns** -> **{string}** Value for given key `string`


**Throws** -> **{Error}** `"StringStorage.get: value not defined"`


**Developer note** -> Passes parameter to
[`data.getOrError`][docs__library_mapping_string__method__getorerror] with
default Error `_reason` to throw


---


#### Method `getOrElse`
[heading__method_getorelse]:
  #method-getorelse
  "Retrieve stored value `string` or provided default `string` if _undefined_"


> Retrieve stored value `string` or provided default `string` if _undefined_


[**Source**][source__contracts__stringstorage_sol__getorelse] `getOrElse(string _key, string _default)`


**Parameters**


- `_key` **{string}** Mapping key `string` to lookup corresponding value `string` for

- `_default` **{string}** Value to return if key `string` lookup is _undefined_


**Returns** -> **{string}** Value `string` for given key `string` or `_default` if _undefined_


**Developer note** -> Forwards parameters to
[`data.getOrElse`][docs__library_mapping_string__method__getorelse]


---


#### Method `getOrError`
[heading__method_getorerror]:
  #method-getorerror
  "Allow for defining custom error reason if value `string` is _undefined_"


> Allow for defining custom error reason if value `string` is _undefined_


[**Source**][source__contracts__stringstorage_sol__getorerror] `getOrError(string _key, string _reason)`


**Parameters**


- `_key` **{string}** Mapping key `string` to lookup corresponding value `string` for

- `_reason` **{string}** Custom error message to throw if value `string` is _undefined_


**Returns** -> **{string}** Value for given key `string`


**Throws** -> **{Error}** `_reason` if value is _undefined_


**Developer note** -> Forwards parameters to
[`data.getOrError`][docs__library_mapping_string__method__getorerror]


---


#### Method `has`
[heading__method_has]:
  #method-has
  "Check if `string` key has a corresponding value `string` defined"


> Check if `string` key has a corresponding value `string` defined


[**Source**][source__contracts__stringstorage_sol__has] `has(string _key)`


**Parameters**


- `_key` **{string}** Mapping key to check if value `string` is defined


**Returns** -> **{bool}** `true` if value `string` is defined, or `false` if
_undefined_


**Developer note** -> Forwards parameter to
[`data.has`][docs__library_mapping_string__method__has]


---


#### Method `indexOf`
[heading__method_indexof]:
  #method-indexof
  "Index for `string` key within `keys` array"


> Index for `string` key within `keys` array


[**Source**][source__contracts__stringstorage_sol__indexof] `indexOf(string _key)`


**Parameters**


- `_key` **{string}** Key to lookup index for


**Returns** -> **{uint256}** Current index for given `_key` within `keys` array


**Throws** -> **{Error}** `"StringStorage.indexOf: key not defined"`


**Developer note** -> Passes parameter to
[`indexOfOrError`][heading__method_indexoforerror] with default `_reason`


---


#### Method `indexOfOrError`
[heading__method_indexoforerror]:
  #method-indexoforerror
  "Index for `string` key within `keys` array"


> Index for `string` key within `keys` array


[**Source**][source__contracts__stringstorage_sol__indexoforerror] `indexOfOrError(string _key, string _reason)`


**Parameters**


- `_key` **{string}** Key to lookup index for


**Returns** -> **{uint256}** Current index for given `_key` within `keys` array


**Throws** -> **{Error}** `_reason` if value for `_key` is _undefined_


**Developer note** -> Cannot depend on results being valid if mutation is
allowed between calls


---


#### Method `listKeys`
[heading__method_listkeys]:
  #method-listkeys
  "Convenience function to read all `mapping` key strings"


> Convenience function to read all `mapping` key strings


[**Source**][source__contracts__stringstorage_sol__listkeys] `listKeys()`


**Returns** -> **{string[]}** Keys `string` array


**Developer note** -> Cannot depend on results being valid if mutation is
allowed between calls


---


#### Method `remove`
[heading__method_remove]:
  #method-remove
  "Delete value `string` for given `_key`"


> Delete value `string` for given `_key`


[**Source**][source__contracts__stringstorage_sol__remove] `remove(string _key)`


**Parameters**


- `_key` **{string}** Mapping key to delete corresponding value `string` for


**Returns** -> **{string}** Value `string` that was removed from `data`
storage


**Throws**


- **{Error}** `"StringStorage.remove: message sender not an owner"`

- **{Error}** `"StringStorage.remove: value not defined"`


**Developer note** -> Passes parameter to
[`removeOrError`][heading__method_removeorerror] with default `_reason`


---


#### Method `removeOrError`
[heading__method_removeorerror]:
  #method-removeorerror
  "Delete value `string` for given `_key`"


> Delete value `string` for given `_key`


[**Source**][source__contracts__stringstorage_sol__removeorerror] `removeOrError(string _key, string _reason)`


**Parameters**


- `_key` **{string}** Mapping key to delete corresponding value `string` for

- `_reason` **{string}** Custom error message to throw if value `string` is _undefined_


**Returns** -> **{string}** Value `string` that was removed from `data`
storage


**Throws**


- **{Error}** `"StringStorage.removeOrError: message sender not an owner"`

- **{Error}** `_reason` if value is _undefined_


**Developer note** -> **Warning** reorders `keys`, and mutates `indexes`, for
efficiency reasons


---


#### Method `selfDestruct`
[heading__method_selfdestruct]:
  #method-selfdestruct
  "Call `selfdestruct` with provided `address`"


> Call `selfdestruct` with provided `address`


[**Source**][source__contracts__stringstorage_sol__selfdestruct] `selfDestruct(address payable _to)`


**Parameters**


- `_to` **{address}** Where to transfer any funds this contract has


**Throws** -> **{Error}** `"StringStorage.selfDestruct: message sender not an owner"`


---


#### Method `set`
[heading__method_set]:
  #method-set
  "Store `_value` under given `_key` while preventing unintentional overwrites"


> Store `_value` under given `_key` while preventing unintentional overwrites


[**Source**][source__contracts__stringstorage_sol__set] `set(string _key, string _value)`


**Parameters**


- `_key` **{string}** Mapping key to set corresponding value `string` for

- `_value` **{string}** Mapping value to set


**Throws**


- **{Error}** `"StringStorage.set: message sender not an owner"`

- **{Error}** `"StringStorage.set: value already defined"`


**Developer note** -> Forwards parameters to
[`setOrError`][heading__method_setorerror] with default `_reason`


---


#### Method `setOrError`
[heading__method_setorerror]:
  #method-setorerror
  "Store `_value` under given `_key` while preventing unintentional overwrites"


> Store `_value` under given `_key` while preventing unintentional overwrites


[**Source**][source__contracts__stringstorage_sol__setorerror] `setOrError(string _key, string _value, string _reason)`


**Parameters**


- `_key` **{string}** Mapping key to set corresponding value `string` for

- `_value` **{string}** Mapping value to set

- `_reason` **{string}** Custom error message to present if value `string` is defined


**Throws**


- **{Error}** `"StringStorage.setOrError: message sender not an owner"`

- **{Error}** `_reason` if value is defined


**Developer note** -> Forwards parameters to
[`data.setOrError`][docs__library_mapping_string__method__setorerror]


---


#### Method `size`
[heading__method_size]:
  #method-size
  "Number of key/value `string` pairs currently stored"


> Number of key/value `string` pairs currently stored


[**Source**][source__contracts__stringstorage_sol__size] `size()`


**Returns** -> **{uint256}** Length of `keys` array


**Developer note** -> Cannot depend on results being valid if mutation is
allowed between calls


______


## Notes
[heading__notes]:
  #notes
  "&#x1F5D2; Additional things to keep in mind when developing"


> Additional things to keep in mind when developing


In some cases it may be cheaper for deployment costs to use the
`library-mapping-string` project directly instead, especially if tracking
defined keys is not needed.


---


**Warning** information stored by `StringStorage` instances should be
considered **public**. Or in other words it is a **bad idea** to store
sensitive or private data on the blockchain.


---


This repository may not be feature complete and/or fully functional, Pull
Requests that add features or fix bugs are certainly welcomed.


______


## Contributing
[heading__contributing]:
  #contributing
  "&#x1F4C8; Options for contributing to string-storage and solidity-utilities"


> Options for contributing to string-storage and solidity-utilities


---


### Forking
[heading__forking]:
  #forking
  "&#x1F531; Tips for forking `string-storage`"


> Tips for forking `string-storage`


Make a [Fork][string_storage__fork_it] of this repository to an account that
you have write permissions for.


- Clone fork URL. The URL syntax is _`git@github.com:<NAME>/<REPO>.git`_, then add this repository as a remote...


```Bash
mkdir -p ~/git/hub/solidity-utilities

cd ~/git/hub/solidity-utilities

git clone --origin fork git@github.com:<NAME>/string-storage.git

git remote add origin git@github.com:solidity-utilities/string-storage.git
```


- Install development dependencies


```Bash
cd ~/git/hub/solidity-utilities/string-storage

npm ci
```


> Note, the `ci` option above is recommended instead of `install` to avoid
> mutating the `package.json`, and/or `package-lock.json`, file(s) implicitly


- Commit your changes and push to your fork, eg. to fix an issue...


```Bash
cd ~/git/hub/solidity-utilities/string-storage


git commit -F- <<'EOF'
:bug: Fixes #42 Issue


**Edits**


- `<SCRIPT-NAME>` script, fixes some bug reported in issue
EOF


git push fork main
```


- Then on GitHub submit a Pull Request through the Web-UI, the URL syntax is _`https://github.com/<NAME>/<REPO>/pull/new/<BRANCH>`_


> Note; to decrease the chances of your Pull Request needing modifications
> before being accepted, please check the
> [dot-github](https://github.com/solidity-utilities/.github) repository for
> detailed contributing guidelines.


---


### Sponsor
  [heading__sponsor]:
  #sponsor
  "&#x1F4B1; Methods for financially supporting `solidity-utilities` that maintains `string-storage`"


> Methods for financially supporting `solidity-utilities` that maintains
> `string-storage`


Thanks for even considering it!


Via Liberapay you may
<sub>[![sponsor__shields_io__liberapay]][sponsor__link__liberapay]</sub> on a
repeating basis.


For non-repeating contributions Ethereum is accepted via the following public address;


    0x5F3567160FF38edD5F32235812503CA179eaCbca


Regardless of if you're able to financially support projects such as
`string-storage` that `solidity-utilities` maintains, please consider sharing
projects that are useful with others, because one of the goals of maintaining
Open Source repositories is to provide value to the community.


______


## Attribution
[heading__attribution]:
  #attribution
  "&#x1F4C7; Resources that where helpful in building this project so far."


- [GitHub -- `github-utilities/make-readme`](https://github.com/github-utilities/make-readme)

- [GitHub -- `solidity-utilities/library-mapping-string`](https://github.com/solidity-utilities/library-mapping-string)

- [GitHub -- `actions/setup-node/issues/214`](https://github.com/actions/setup-node/issues/214#issuecomment-810829250)


______


## License
[heading__license]:
  #license
  "&#x2696; Legal side of Open Source"


> Legal side of Open Source


```
Solidity contract for storing and interacting with key/value string pairs
Copyright (C) 2021 S0AndS0

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```


For further details review full length version of
[AGPL-3.0][branch__current__license] License.



[branch__current__license]:
  LICENSE
  "&#x2696; Full length version of AGPL-3.0 License"


[badge__commits__string_storage__main]:
  https://img.shields.io/github/last-commit/solidity-utilities/string-storage/main.svg

[commits__string_storage__main]:
  https://github.com/solidity-utilities/string-storage/commits/main
  "&#x1F4DD; History of changes on this branch"


[string_storage__community]:
  https://github.com/solidity-utilities/string-storage/community
  "&#x1F331; Dedicated to functioning code"


[issues__string_storage]:
  https://github.com/solidity-utilities/string-storage/issues
  "&#x2622; Search for and _bump_ existing issues or open new issues for project maintainer to string."

[string_storage__fork_it]:
  https://github.com/solidity-utilities/string-storage/fork
  "&#x1F531; Fork it!"

[pull_requests__string_storage]:
  https://github.com/solidity-utilities/string-storage/pulls
  "&#x1F3D7; Pull Request friendly, though please check the Community guidelines"

[string_storage__main__source_code]:
  https://github.com/solidity-utilities/string-storage/
  "&#x2328; Project source!"

[badge__issues__string_storage]:
  https://img.shields.io/github/issues/solidity-utilities/string-storage.svg

[badge__pull_requests__string_storage]:
  https://img.shields.io/github/issues-pr/solidity-utilities/string-storage.svg

[badge__main__string_storage__source_code]:
  https://img.shields.io/github/repo-size/solidity-utilities/string-storage


[badge__github_actions]:
  https://github.com/solidity-utilities/string-storage/actions/workflows/test.yaml/badge.svg?branch=main

[activity_log__github_actions]:
  https://github.com/solidity-utilities/string-storage/deployments/activity_log


[truffle__package_management_via_npm]:
  https://www.trufflesuite.com/docs/truffle/getting-started/package-management-via-npm
  "Documentation on how to install, import, and interact with Solidity packages"


[docs__library_mapping_string]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md
  "`solidity-utilities/library-mapping-string` -- Solidity library for mapping strings"

[docs__library_mapping_string__method__get]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-get
  "`solidity-utilities/library-mapping-string` -- Retrieves stored value `string` or throws an error if _undefined_"

[docs__library_mapping_string__method__getorelse]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-getorelse
  "`solidity-utilities/library-mapping-string` -- Retrieves stored value `string` or provided default `string` if _undefined_"

[docs__library_mapping_string__method__getorerror]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-getorerror
  "`solidity-utilities/library-mapping-string` -- Allows for defining custom error reason if value `string` is _undefined_"

[docs__library_mapping_string__method__has]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-has
  "`solidity-utilities/library-mapping-string` -- Check if `string` key has a corresponding value `string` defined"

[docs__library_mapping_string__method__overwrite]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-overwrite
  "`solidity-utilities/library-mapping-string` -- Store `_value` under given `_key` **without** preventing unintentional overwrites"

[docs__library_mapping_string__method__overwriteorError]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-overwriteorerror
  "`solidity-utilities/library-mapping-string` -- Store `_value` under given `_key` **without** preventing unintentional overwrites"

[docs__library_mapping_string__method__remove]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-remove
  "`solidity-utilities/library-mapping-string` -- Delete value `string` for given `_key`"

[docs__library_mapping_string__method__removeorerror]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-removeorerror
  "`solidity-utilities/library-mapping-string` -- Delete value `string` for given `_key`"

[docs__library_mapping_string__method__set]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-set
  "`solidity-utilities/library-mapping-string` -- Store `_value` under given `_key` while preventing unintentional overwrites"

[docs__library_mapping_string__method__setorerror]:
  https://github.com/solidity-utilities/library-mapping-string/blob/main/README.md#method-setorerror
  "`solidity-utilities/library-mapping-string` -- Store `_value` under given `_key` while preventing unintentional overwrites"


[source__test]:
  test
  "CI/CD (Continuous Integration/Deployment) tests and examples"

[source__test__examples__account_sol]:
  test/examples/Account.sol
  "Solidity code for demonstrating test/examples/Account.sol"

[source__test__examples__host_sol]:
  test/examples/Host.sol
  "Solidity code for demonstrating test/examples/host.sol"

[source__test__test__examples__account_js]:
  test/test__examples__Account.js
  "JavaScript code for testing test/examples/Account.sol"

[source__test__test__examples__host_js]:
  test/test__examples__Host.js
  "JavaScript code for testing test/examples/Host.sol"

[source__contracts__stringstorage_sol]:
  contracts/StringStorage.sol
  "Solidity contract for storing and interacting with key/value `string` pairs"

[source__contracts__stringstorage_sol__addauthorized]:
  contracts/StringStorage.sol#L64
  "Insert `address` into `mapping` of `authorized` data structure"

[source__contracts__stringstorage_sol__changeowner]:
  contracts/StringStorage.sol#L72
  "Overwrite old `owner` with new owner `string`"

[source__contracts__stringstorage_sol__clear]:
  contracts/StringStorage.sol#L79
  "Delete `mapping` string key/value pairs and remove all `string` from `keys`"

[source__contracts__stringstorage_sol__deleteauthorized]:
  contracts/StringStorage.sol#L93
  "Remove `address` from `mapping` of `authorized` data structure"

[source__contracts__stringstorage_sol__get]:
  contracts/StringStorage.sol#L112
  "Retrieve stored value `string` or throws an error if _undefined_"

[source__contracts__stringstorage_sol__getorelse]:
  contracts/StringStorage.sol#L121
  "Retrieve stored value `string` or provided default `string` if _undefined_"

[source__contracts__stringstorage_sol__getorerror]:
  contracts/StringStorage.sol#L134
  "Allow for defining custom error reason if value `string` is _undefined_"

[source__contracts__stringstorage_sol__has]:
  contracts/StringStorage.sol#L148
  "Check if `string` key has a corresponding value `string` defined"

[source__contracts__stringstorage_sol__indexof]:
  contracts/StringStorage.sol#L156
  "Index for `string` key within `keys` array"

[source__contracts__stringstorage_sol__indexoforerror]:
  contracts/StringStorage.sol#L165
  "Index for `string` key within `keys` array"

[source__contracts__stringstorage_sol__listkeys]:
  contracts/StringStorage.sol#L180
  "Convenience function to read all `mapping` key strings"

[source__contracts__stringstorage_sol__remove]:
  contracts/StringStorage.sol#L187
  "Delete value `string` for given `_key`"

[source__contracts__stringstorage_sol__removeorerror]:
  contracts/StringStorage.sol#L201
  "Delete value `string` for given `_key`"

[source__contracts__stringstorage_sol__selfdestruct]:
  contracts/StringStorage.sol#L226
  "Call `selfdestruct` with provided `string`"

[source__contracts__stringstorage_sol__set]:
  contracts/StringStorage.sol#L236
  "Store `_value` under given `_key` while preventing unintentional overwrites"

[source__contracts__stringstorage_sol__setorerror]:
  contracts/StringStorage.sol#L249
  "Store `_value` under given `_key` while preventing unintentional overwrites"

[source__contracts__stringstorage_sol__size]:
  contracts/StringStorage.sol#L266
  "Number of key/value `string` pairs currently stored"

