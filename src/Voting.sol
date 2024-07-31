// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Voting{
    event Voted(uint indexed id);
    event CandidateCreated(uint indexed candidateNo,string indexed candidateName);
    event OwnerChange(address indexed oldOwner,address indexed newOwner);

    address private owner;

    constructor() {
       owner = msg.sender;
    }

    //onlyOwner can add candidates
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    //change owner of contract
    function changeOwner(address newOwner) public{
        emit OwnerChange(owner, newOwner);
        owner = newOwner;
    }
    //candidate structure
    struct Candidate{
        uint id;
        string name;
        uint voteCount;
    }
    //has address or voter voted
    mapping (address => bool) public voterLookUp;
    //create a unique id for every candidate
    mapping (uint => Candidate) public candidateLookUp;
    
    //keep track of number of candidates created -- helps in generating unique id
    uint private candidateCount;

    //add candidate
    function addCandidate(string memory name) public onlyOwner{
       candidateLookUp[candidateCount] = Candidate(candidateCount,name,0);
       candidateCount++;
       emit CandidateCreated(candidateCount,name);
    }

    //get a single candidate
    function getCandidate(uint id) external  view returns (string memory name,uint noOfVotes){
        name = candidateLookUp[id].name;
        noOfVotes = candidateLookUp[id].voteCount;

        return (name , noOfVotes);
    }
     
    //get all candidates 
    function getCandidates() external  view returns (string [] memory,uint [] memory){
       string [] memory names = new string [](candidateCount);
       uint [] memory noOfVotes = new uint [](candidateCount);

       for(uint i = 0;i < candidateCount;i++){
        names[i] = candidateLookUp[i].name;
        noOfVotes[i] = candidateLookUp[i].voteCount;
       }

       return (names,noOfVotes);
    }

    //vote function
    function vote(uint id) external {
        require(!voterLookUp[msg.sender],'Address has already voted');
        require(id >= 0 && id <= candidateCount - 1);     
        
        //allows a single vote from each address
        voterLookUp[msg.sender] = true;

        candidateLookUp[id].voteCount++;

        emit Voted(id);
    }

    //declare winner
    function declareWinner() external view returns (string memory winnerName,uint winnerVotes){
        require(msg.sender == owner);
        require(candidateCount > 0,'No candidate available');

        winnerName = candidateLookUp[0].name;
        winnerVotes = candidateLookUp[0].voteCount;

        for(uint i = 1;i < candidateCount;i++){
            if(candidateLookUp[i].voteCount > winnerVotes){
                winnerName = candidateLookUp[i].name;
                winnerVotes = candidateLookUp[i].voteCount;
            }
        }

        return (winnerName,winnerVotes);
    }

    //getter functions
    function getOwner() external view returns (address){
        return owner;
    }

    function getCandidateCount() external view returns (uint){
        return candidateCount;
    }


}