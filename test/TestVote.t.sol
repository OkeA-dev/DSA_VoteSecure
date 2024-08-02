//SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)\
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {VoteProtocol} from "../src/Vote.sol";

contract TestVote is Test {
    bytes32 private constant ROOT = 0x826accc591adbdbb3f180343727b312a11c7c5c571e0e0924df1513cbb4c512e;
    address voterOne;
    VoteProtocol vote;

    bytes32 proofOne = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32 proofTwo = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32[] public PROOF = [proofTwo, proofOne];

    function setUp() public {
        vote = new VoteProtocol(ROOT);
        voterOne = makeAddr("user");
    }

    function testVoteInvalidCandidate() public {
        vm.prank(voterOne);
        vm.expectRevert();
        vote.vote(voterOne, 2, PROOF );
    }
}