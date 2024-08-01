
// pragma solidity ^0.8.24;

// import {Script} from "forge-std/Script.sol";
// import {stdJson} from "forge-std/StdJson.sol";
// import {console} from "forge-std/console.sol";
// import {AddressStorage} from "../src/AddressStorage.sol";
// import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

// // Merkle tree input file generator script
// contract GenerateInput is Script {
//     uint256 private constant VOTER_TAG = 2024;
//     AddressStorage addresses;
//     string[] types = new string[](2);
//     uint256 count;
//     string[] whitelist = new string[](10);

//     string private constant INPUT_PATH = "/script/target/input.json";

//     function getAddressFromStorage(address store) public {
//         vm.startBroadcast();
//         addresses = AddressStorage(store);
//         vm.stopBroadcast();
//     }

//     function getWhitelistAddress() internal {
//         for(uint i = 0; i < 10; i++){
//             whitelist[i] = vm.toString(addresses.getAddress(i));
//         }
//     }

//     function run() public {
//         types[0] = "address";
//         types[1] = "uint";
//         address store = DevOpsTools.get_most_recent_deployment("AddressStorage", block.chainid);
//         getAddressFromStorage(store);
//         getWhitelistAddress();
//         count = whitelist.length;
//         string memory input = _createJSON();
//         // write to the output file the stringified output json tree dumpus
//         vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

//         console.log("DONE: The output is found at %s", INPUT_PATH);
//     }

//     function _createJSON() internal view returns (string memory) {
//         string memory countString = vm.toString(count); // convert count to string
//         string memory amountString = vm.toString(VOTER_TAG); // convert amount to string
//         string memory json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');
//         for (uint256 i = 0; i < count; i++) {
//             if (i == count - 1) {
//                 json = string.concat(
//                     json,
//                     '"',
//                     vm.toString(i),
//                     '"',
//                     ': { "0":',
//                     '"',
//                     whitelist[i],
//                     '"',
//                     ', "1":',
//                     '"',
//                     amountString,
//                     '"',
//                     " }"
//                 );
//             } else {
//                 json = string.concat(
//                     json,
//                     '"',
//                     vm.toString(i),
//                     '"',
//                     ': { "0":',
//                     '"',
//                     whitelist[i],
//                     '"',
//                     ', "1":',
//                     '"',
//                     amountString,
//                     '"',
//                     " },"
//                 );
//             }
//         }
//         json = string.concat(json, "} }");

//         return json;
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";

// Merkle tree input file generator script
contract GenerateInput is Script {
    uint256 private constant AMOUNT = 25 * 1e18;
    string[] types = new string[](2);
    uint256 count;
    string[] whitelist = new string[](6);
    string private constant INPUT_PATH = "/script/target/input.json";

    function run() public {
        types[0] = "address";
        types[1] = "uint";
        whitelist[0] = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        whitelist[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[2] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        whitelist[3] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";
        whitelist[4] = "0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e";
        whitelist[5] = "0x328809Bc894f92807417D2dAD6b7C998c1aFdac6";
        count = whitelist.length;
        string memory input = _createJSON();
        // write to the output file the stringified output json tree dumpus
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console.log("DONE: The output is found at %s", INPUT_PATH);
    }

    function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count); // convert count to string
        string memory json = string.concat('{ "types": ["address"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    
                    " }"
                );
            } else {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[i],
                    '"',
                    " },"
                );
            }
        }
        json = string.concat(json, "} }");

        return json;
    }
}
