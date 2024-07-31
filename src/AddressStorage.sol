// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AddressStorage {
    address[] public addresses;

    function addAddress(address _address) public {
        addresses.push(_address);
    }

    function getAddressCount() public view returns (uint256) {
        return addresses.length;
    }

    function getAddress(uint256 index) public view returns (address) {
        require(index < addresses.length, "Index out of bounds");
        return addresses[index];
    }
}