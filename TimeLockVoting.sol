// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeLockedVoting {
    struct Proposal {
        string name;
        uint voteCount;
    }

    address public admin;
    uint public votingStart;
    uint public votingEnd;

    mapping(address => bool) public registeredVoters;
    mapping(address => bool) public hasVoted;

    Proposal[] public proposals;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlyDuringVoting() {
        require(block.timestamp >= votingStart && block.timestamp <= votingEnd, "Voting not active");
        _;
    }

    modifier onlyRegistered() {
        require(registeredVoters[msg.sender], "Not registered to vote");
        _;
    }

    constructor(
        string[] memory proposalNames,
        uint durationMinutes
    ) {
        admin = msg.sender;
        votingStart = block.timestamp;
        votingEnd = votingStart + (durationMinutes * 1 minutes);

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({ name: proposalNames[i], voteCount: 0 }));
        }
    }

    // Admin registers voters before voting
    function registerVoter(address voter) external onlyAdmin {
        registeredVoters[voter] = true;
    }

    function vote(uint proposalIndex) external onlyRegistered onlyDuringVoting {
        require(!hasVoted[msg.sender], "Already voted");
        require(proposalIndex < proposals.length, "Invalid proposal");

        hasVoted[msg.sender] = true;
        proposals[proposalIndex].voteCount++;
    }

    function getProposals() external view returns (Proposal[] memory) {
        return proposals;
    }

    function winningProposal() public view returns (uint winningIndex) {
        uint highestVotes = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > highestVotes) {
                highestVotes = proposals[i].voteCount;
                winningIndex = i;
            }
        }
    }

    function winnerName() public view returns (string memory) {
        return proposals[winningProposal()].name;
    }
}
