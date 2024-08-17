//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VoteProtocol} from "../src/Vote.sol";

contract DeployVoteProtocol is Script {
    bytes32 private constant ROOT = 0x826accc591adbdbb3f180343727b312a11c7c5c571e0e0924df1513cbb4c512e;

    function deployVoteprotocol() public returns (VoteProtocol) {
        vm.startBroadcast();
        VoteProtocol vote = new VoteProtocol(ROOT);
        vm.stopBroadcast();
        return vote;
    }

    function run() external returns (VoteProtocol) {
        return deployVoteprotocol();
    }
}
