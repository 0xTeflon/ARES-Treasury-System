// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../modules/ProposalModule.sol";
import "../modules/TimelockModule.sol";

contract AresTreasury is ProposalModule, TimelockModule {

    function queue(uint256 proposalId) public override {
        setQueued(proposalId);
        require(executionTime[proposalId] == 0, "queued");
        executionTime[proposalId] = block.timestamp + delay;
    }

    function execute(uint256 proposalId) public {

        Proposal storage p = proposals[proposalId];

        require(p.state != State.PROPOSED, "not approved");

        require(p.state != State.EXECUTED, "already executed");

        require(ready(proposalId), "not ready");

        uint256 maxDrain = address(this).balance / 10;

        require(p.value <= maxDrain, "too large");

        p.state = State.EXECUTED;

        (bool ok,) = p.target.call{value: p.value}(p.data);

        require(ok, "call failed");
    }

    receive() external payable {}
}
