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
    error VoteProtocol__InvalidCandidateNameAndAccount();
    error VoteProtocol__InvalidAdmistrator();
    error VoteProtocol__NeedMoreCandidateToRegister();
    error VoteProtocol__InvalidProof();
    error VoteProtocol__AlreadyVoted();
    error VoteProtocol__RegistrationHasEnded();
    error VoteProtocol__HasAlreadyRegistered();

    enum Status {
        Registration,
        Voting,
        Voting_Ended
    }

    struct Candidate {
        uint256 id;
        string name;
        address account;
        uint256 voteCount;
    }

    Status public currentStatus;
    bytes32 private immutable i_merkleRoot;
    uint256 private s_candidateCount;
    address public immutable s_voteAdmistrator;
    Candidate[] public s_candidates;
    mapping(address voter => bool confirmVote) public s_hasVoted;

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
    /**
     *
     * @param _name : the name of the candidate to add.
     * @notice this function allow only the vote Adminstrator to add the new candidate before the voting start.
     */

    function addCandidate(string memory _name, address account) external onlyOwner {
        if (bytes(_name).length == 0 && account == address(0)) {
            revert VoteProtocol__InvalidCandidateNameAndAccount();
        }
        if (currentStatus != Status.Registration) {
            revert VoteProtocol__RegistrationHasEnded();
        }
        if (_confirmIfCandidateHasRegistered(account)) {
            revert VoteProtocol__HasAlreadyRegistered();
        }
        uint256 count = 0;
        s_candidates.push(Candidate({id: count, name: _name, account: account, voteCount: 0}));

        count++;

        emit AddCandidate(s_candidateCount, _name);
    }

    function startVote() external onlyOwner {
        if (s_candidateCount <= 1) {
            revert VoteProtocol__NeedMoreCandidateToRegister();
        }
        currentStatus = Status.Voting;
    }

    function countVote() external {}

    /**
     * 
     * @param account the account of the voter 
     * @param candidateId the unique id for the candidate to vote for
     * @param merkleProof the proof to confirm that you registered for the vote.
     * @notice this function confirm the authentication of the voter and initial a unchangable vote.
     */

    function vote(address account, uint256 candidateId, bytes32[] calldata merkleProof) external {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account))));
        if (s_hasVoted[account]) {
            revert VoteProtocol__AlreadyVoted();
        }
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert VoteProtocol__InvalidProof();
        }
        s_candidates[candidateId].voteCount += 1;
    }

    function _stopVote() internal {
        currentStatus = Status.Voting_Ended;
    }

    function _confirmIfCandidateHasRegistered(address account) internal view returns (bool checked) {
        for (uint256 i = 0; i < s_candidates.length; i++) {
            if (s_candidates[i].account == account) {
                checked = true;
            }
        }
        checked = false;
    }

    function getCandidateCount() public view returns (uint256 count) {
        count = s_candidates.length;
    }
}
