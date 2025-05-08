// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Snapshot {
    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);
    function snapshot() external returns (uint256);
}

contract SnapshotTokenVoting {
    struct Proposal {
        string name;
        uint voteCount;
    }

    address public admin;
    IERC20Snapshot public token;
    uint public snapshotId;
    bool public votingStarted;

    Proposal[] public proposals;
    mapping(address => bool) public hasVoted;

    constructor(address tokenAddress, string[] memory proposalNames) {
        admin = msg.sender;
        token = IERC20Snapshot(tokenAddress);
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({ name: proposalNames[i], voteCount: 0 }));
        }
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can do this");
        _;
    }

    function startVoting() external onlyAdmin {
        require(!votingStarted, "Already started");
        snapshotId = token.snapshot(); // Record all token balances at this block
        votingStarted = true;
    }

    function vote(uint proposalIndex) external {
        require(votingStarted, "Voting has not started");
        require(!hasVoted[msg.sender], "Already voted");
        require(proposalIndex < proposals.length, "Invalid proposal");

        uint weight = token.balanceOfAt(msg.sender, snapshotId);
        require(weight > 0, "No voting power at snapshot");

        hasVoted[msg.sender] = true;
        proposals[proposalIndex].voteCount += weight;
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
