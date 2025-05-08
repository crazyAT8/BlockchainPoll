// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract TokenBasedVoting {
    struct Proposal {
        string name;
        uint voteCount; // Total weighted votes
    }

    address public admin;
    IERC20 public votingToken;
    Proposal[] public proposals;
    mapping(address => bool) public hasVoted;

    constructor(address tokenAddress, string[] memory proposalNames) {
        admin = msg.sender;
        votingToken = IERC20(tokenAddress);

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({ name: proposalNames[i], voteCount: 0 }));
        }
    }

    function vote(uint proposalIndex) external {
        require(!hasVoted[msg.sender], "Already voted");
        require(proposalIndex < proposals.length, "Invalid proposal");

        uint voterWeight = votingToken.balanceOf(msg.sender);
        require(voterWeight > 0, "No voting tokens held");

        hasVoted[msg.sender] = true;
        proposals[proposalIndex].voteCount += voterWeight;
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
