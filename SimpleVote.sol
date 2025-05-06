// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleVote {
    struct Proposal {
        string name;
        uint voteCount;
    }

    address public admin;
    mapping(address => bool) public hasVoted;

    Proposal[] public proposals;

    constructor(string[] memory proposalNames) {
        admin = msg.sender;
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function vote(uint proposalIndex) external {
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
