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

contract VoteProtocol {

    constructor(bytes32 merkleRoot) Ownable(msg.sender) {
        
    }
    function addCandidate() external {}
    function startVote() external {}
    function stopVote () external {}
    function countVote () external {}
    function vote(address account, bytes32[] calldata merkleProof) external {
    
   }
    
}