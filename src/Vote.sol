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
    error VoteProtocol__InvalidAddCandidate();
    
    struct Candidate{
        uint256 id;
        string name;
        uint256 voteCount;
    }
    uint256 private candidateCount;
    mapping (uint256 candidateId => Candidate candidateInformation) public s_candidates;

    event AddCandidate(uint256 candidateCount, string candidateName);

    constructor(bytes32 merkleRoot)  {}

    function addCandidate(string memory _name) external {
        if (bytes(_name).length == 0) {
            revert VoteProtocol__InvalidAddCandidate();
        }
        s_candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0
        });
        
        candidateCount++;

        emit AddCandidate(candidateCount, _name);
    }
    function startVote() external {}
    function stopVote () external {}
    function countVote () external {}
    function vote(address account, bytes32[] calldata merkleProof) external {
    
   }
    
}