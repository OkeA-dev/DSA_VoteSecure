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
    address candidate_1;
    address candidate_2;
    VoteProtocol vote;
    uint256 privateKey;

    bytes32 proofOne = 0xd791b4384f11048b2330e9ec924a5c80226526b5e9d7f65537637981af4d404f;
    bytes32 proofTwo = 0xa734766c7655875218b9cf7c55c995a5c996ca326e5f933e3793def3b14d12a1;
    bytes32 proofThree = 0x533789ebb1206c7510cd612eec17e2ebd028bb279ea38f5989853659e7fa464e;
    bytes32[] public PROOF = [proofOne, proofTwo, proofThree];

    modifier candidateOne() {
        vote.addCandidate("Oke Abdulquadri", candidate_1);
        _;
    }

    modifier candidateTwo() {
        vote.addCandidate("Adu Samson", candidate_2);
        _;
    }

    function setUp() public {
        vote = new VoteProtocol(ROOT);
        (voterOne, privateKey) = makeAddrAndKey("user");
        candidate_1 = makeAddr("candidate1");
        candidate_2 = makeAddr("candidate2");
    }

    /////////////////////////////
    //    ADD CANDIDATE       //
    ///////////////////////////

    function testOnlyVoteAdmistratorCanAddCandidate() public {
        vm.prank(voterOne);
        vm.expectRevert(VoteProtocol.VoteProtocol__InvalidAdmistrator.selector);
        vote.addCandidate("Oke Abdulquadri", candidate_1);
    }

    function testAddInvalidCandidate() public {
        vm.expectRevert(VoteProtocol.VoteProtocol__InvalidCandidateNameAndAccount.selector);
        vote.addCandidate("", address(0));
    }

    function testAddCandidate() public candidateOne candidateTwo {
        uint256 count = 2;

        assertEq(vote.getCandidateCount(), count);
    }

    /////////////////////////
    ///      VOTE        ///
    ///////////////////////

    function testVoteBeforeVotingStarted() public candidateOne {
        uint256 candidateId = 0;
        bytes32 digest = vote.getMessage(voterOne, candidateId);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        vm.prank(voterOne);
        vm.expectRevert(VoteProtocol.VoteProtocol__VotingHasNotStarted.selector);
        vote.vote(voterOne, candidateId, PROOF, v, r, s);
    }

    function testCandidateMustBeMoreThanOne() public candidateOne candidateTwo {
        uint256 candidateId = 0;
        bytes32 digest = vote.getMessage(voterOne, candidateId);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        uint256 voteCount = 1;
        vote.startVote();
        vm.prank(voterOne);
        vote.vote(voterOne, candidateId, PROOF, v, r, s);

        assertEq(vote.countVote(candidateId), voteCount);
    }
}
