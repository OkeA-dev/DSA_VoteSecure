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

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract VoteProtocol {
    error VoteProtocol__InvalidAddCandidate();
    error VoteProtocol__InvalidAdmistrator();
    error VoteProtocol__NeedMoreCandidateToRegister();
    error VoteProtocol__InvalidProof();

    enum Status {
        Registration,
        Voting,
        Voting_Ended
    }

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    Status public currentStatus;
    bytes32 private immutable i_merkleRoot;
    uint256 private s_candidateCount;
    address public immutable s_voteAdmistrator;
    mapping(uint256 candidateId => Candidate candidateInformation) public s_candidates;

    event AddCandidate(uint256 candidateCount, string candidateName);

    constructor(bytes32 merkleRoot) {
        s_voteAdmistrator = msg.sender;
        i_merkleRoot = merkleRoot;
        currentStatus = Status.Registration;
    }

    modifier onlyOwner() {
        if (msg.sender != s_voteAdmistrator) {
            revert VoteProtocol__InvalidAdmistrator();
        }
        _;
    }

    function addCandidate(string memory _name) external onlyOwner {
        if (bytes(_name).length == 0) {
            revert VoteProtocol__InvalidAddCandidate();
        }
        s_candidates[s_candidateCount] = Candidate({id: s_candidateCount, name: _name, voteCount: 0});

        s_candidateCount++;

        emit AddCandidate(s_candidateCount, _name);
    }

    function startVote() external onlyOwner {
        if (s_candidateCount > 1) {
            revert VoteProtocol__NeedMoreCandidateToRegister();
        }
        currentStatus = Status.Voting;
        uint256 endVoting = block.timestamp + 30 minutes;

        if (block.timestamp == endVoting) {
            _stopVote();
        }
    }

    function countVote() external {}

    function vote(address account, uint256 candidateId, bytes32[] calldata merkleProof) external {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert VoteProtocol__InvalidProof();
        }
    }

    function _stopVote() internal {
        currentStatus = Status.Voting_Ended;
    }
}
