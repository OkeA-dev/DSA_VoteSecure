// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {AddressStorage} from "../src/AddressStorage.sol";

// Merkle tree input file generator script
contract GenerateInput is Script {
    uint256 private constant VOTER_TAG = 2024;
    AddressStorage addresses;
    string[] types = new string[](2);
    uint256 count;

    string private constant  INPUT_PATH = "/script/target/input.json";
    
    
    function run() public {
        types[0] = "address";
        types[1] = "uint";
        addresses = AddressStorage(0x8464135c8F25Da09e49BC8782676a84730C318bC);
        count = addresses.getAddressCount();
        string memory input = _createJSON();
        // write to the output file the stringified output json tree dumpus 
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console.log("DONE: The output is found at %s", INPUT_PATH);
    }

    function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count); // convert count to string
        string memory amountString = vm.toString(VOTER_TAG); // convert amount to string
        string memory json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < count; i++) {
            if (i == count - 1) {
                json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',vm.toString(addresses.getAddress(i)),'"',', "1":', '"',amountString,'"', ' }');
            } else {
            json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',vm.toString(addresses.getAddress(i)),'"',', "1":', '"',amountString,'"', ' },');
            }
        }
        json = string.concat(json, '} }');
        
        return json;
    }
}