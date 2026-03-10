// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimelockModule {

    uint256 public delay = 2 days;

    mapping(uint256 => uint256) public executionTime;

    function queue(uint256 proposalId) public virtual {

        require(executionTime[proposalId] == 0, "queued");

        executionTime[proposalId] =
            block.timestamp + delay;
    }

    function ready(uint256 proposalId) public view returns(bool) {

        return block.timestamp >= executionTime[proposalId];
    }
}
