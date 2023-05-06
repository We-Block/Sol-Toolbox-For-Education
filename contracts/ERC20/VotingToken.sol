// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VotingToken is ERC20 {
    using Counters for Counters.Counter;

    // 投票提案映射
    mapping(uint256 => Proposal) private _proposals;

    // 提案计数器
    Counters.Counter private _proposalCounter;

    struct Proposal {
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => bool) hasVoted;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function createProposal(string memory description) public returns (uint256) {
        _proposalCounter.increment();
        uint256 proposalId = _proposalCounter.current();
        _proposals[proposalId] = Proposal(description, 0, 0);
        return proposalId;
    }

    function vote(uint256 proposalId, bool support) public {
        require(_proposals[proposalId].description[0] != 0, "Proposal does not exist");
        require(!_proposals[proposalId].hasVoted[msg.sender], "Already voted on this proposal");

        uint256 weight = balanceOf(msg.sender);
        if (support) {
            _proposals[proposalId].yesVotes += weight;
        } else {
            _proposals[proposalId].noVotes += weight;
        }
        _proposals[proposalId].hasVoted[msg.sender] = true;
    }

    function getProposal(uint256 proposalId) public view returns (string memory description, uint256 yesVotes, uint256 noVotes) {
        require(_proposals[proposalId].description[0] != 0, "Proposal does not exist");
        return (_proposals[proposalId].description, _proposals[proposalId].yesVotes, _proposals[proposalId].noVotes);
    }
}