// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/AddressStorage.sol";

contract PopulateAddresses is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy the contract
        AddressStorage addressStorage = new AddressStorage();

        // Read addresses from file
        string memory filePath = "./script/addresses.txt";
        string memory fileContent = vm.readFile(filePath);
        string[] memory lines = splitLines(fileContent);

        for (uint i = 0; i < lines.length; i++) {
            address addr = vm.parseAddress(lines[i]);
            addressStorage.addAddress(addr);
        }
        vm.stopBroadcast();

    }

    function splitLines(string memory _content) internal pure returns (string[] memory) {
        bytes memory contentBytes = bytes(_content);
        uint lineCount = 1;
        for (uint i = 0; i < contentBytes.length; i++) {
            if (contentBytes[i] == 0x0A) {
                lineCount++;
            }
        }
        
        string[] memory lines = new string[](lineCount);
        uint lineIndex = 0;
        uint lastIndex = 0;
        
        for (uint i = 0; i < contentBytes.length; i++) {
            if (contentBytes[i] == 0x0A) {
                bytes memory lineBytes = new bytes(i - lastIndex);
                for (uint j = 0; j < i - lastIndex; j++) {
                    lineBytes[j] = contentBytes[lastIndex + j];
                }
                lines[lineIndex] = string(lineBytes);
                lineIndex++;
                lastIndex = i + 1;
            }
        }
        
        if (lastIndex < contentBytes.length) {
            bytes memory lineBytes = new bytes(contentBytes.length - lastIndex);
            for (uint j = 0; j < contentBytes.length - lastIndex; j++) {
                lineBytes[j] = contentBytes[lastIndex + j];
            }
            lines[lineIndex] = string(lineBytes);
        }
        
        return lines;
    }

}