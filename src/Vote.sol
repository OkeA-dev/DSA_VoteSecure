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
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract VoteProtocol is EIP712 {
    error VoteProtocol__InvalidCandidateNameAndAccount();
    error VoteProtocol__InvalidAdmistrator();
    error VoteProtocol__NeedMoreCandidateToRegister();
    error VoteProtocol__InvalidProof();
    error VoteProtocol__AlreadyVoted();
    error VoteProtocol__RegistrationHasEnded();
    error VoteProtocol__HasAlreadyRegistered();
    error VoteProtocol__VotingHasNotStarted();
    error VoteProtocol__InvalidSignature();

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

    struct Vote {
        address voter;
        uint256 candidateId;
    }

    bytes32 constant MESSAGE_TYPEHASH = keccak256("Vote(address voter, uint256 candidateId)");


    Status public currentStatus;
    bytes32 private immutable i_merkleRoot;
    uint256 private s_candidateCount;
    address public immutable s_voteAdmistrator;
    Candidate[] public s_candidates;
    mapping(address voter => bool confirmVote) public s_hasVoted;

    event AddCandidate(uint256 candidateCount, string candidateName);
    event Vote_(bytes32 hashVoterAccount, uint256 candidateId, bool checkVote);

    constructor(bytes32 merkleRoot) EIP712("VoteProtocol", "1") {
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
        if (currentStatus != Status.Registration) {
            revert VoteProtocol__RegistrationHasEnded();
        }
        if (bytes(_name).length == 0 && account == address(0)) {
            revert VoteProtocol__InvalidCandidateNameAndAccount();
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
        if (s_candidates.length <= 1) {
            revert VoteProtocol__NeedMoreCandidateToRegister();
        }
        currentStatus = Status.Voting;
    }

    function countVote(uint256 candidateId) external view returns (uint256) {
        return s_candidates[candidateId].voteCount;
    }

    /**
     *
     * @param account the account of the voter
     * @param candidateId the unique id for the candidate to vote for
     * @param merkleProof the proof to confirm that you registered for the vote.
     * @notice this function confirm the authentication of the voter and initial a unchangable vote.
     */
    function vote(address account, uint256 candidateId, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account))));

        if (currentStatus != Status.Voting) {
            revert VoteProtocol__VotingHasNotStarted();
        }

        if (!_getValidSignature(account, getMessage(account, candidateId), v, r,s)) {
            revert VoteProtocol__InvalidSignature();
        }
        
        if (s_hasVoted[account]) {
            revert VoteProtocol__AlreadyVoted();
        }
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert VoteProtocol__InvalidProof();
        }

        bytes32 hashVoterAccount = keccak256(abi.encode(account));
        bool checkVote = true;

        s_candidates[candidateId].voteCount += 1;

        emit Vote_(hashVoterAccount, candidateId, checkVote);
    }

    function _stopVote() internal {
        currentStatus = Status.Voting_Ended;
    }

    /**
     * @param account an address of a voter  
     * @notice this internal function check if a voter has registered for the voter
     */

    function _confirmIfCandidateHasRegistered(address account) internal view returns (bool checked) {
        for (uint256 i = 0; i < s_candidates.length; i++) {
            if (s_candidates[i].account == account) {
                checked = true;
            }
        }
        checked = false;
    }

    /**
     * @notice this function get the actual count of candidate that register for ballot 
     */

    function getCandidateCount() public view returns (uint256 count) {
        count = s_candidates.length;
    }

    /**
     * 
     * @param voter the address of the voter
     * @param candidateId the actual candidate ID the voter voted for 
     * @notice this function combine the voter address and the candidate ID and hash them together.
     */

    function getMessage(address voter, uint256 candidateId) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, Vote({voter: voter, candidateId: candidateId})))
        );
    }
    /**
     * @param voter address that sign that sign the message
     * @notice this function helps in validating that signer == voter using the v, r, s signature attributes.
     */
    function _getValidSignature(address voter, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool) {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return (actualSigner == voter);
    }
}
