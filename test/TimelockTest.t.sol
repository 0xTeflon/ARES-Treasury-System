// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.t.sol";

contract TimelockTest is BaseTest {

    function testQueueProposal() public {

        uint id = treasury.propose(address(0xBEEF), 0, "");

        vm.warp(block.timestamp + 1 hours);

        treasury.approve(id);

        treasury.queue(id);

        uint executionTime = treasury.executionTime(id);

        assertTrue(executionTime > block.timestamp);
    }

    function testExecuteAfterDelay() public {

    uint id = treasury.propose(address(this), 0, "");

    vm.warp(block.timestamp + 1 hours);

    treasury.approve(id);
    treasury.approve(id);

    treasury.queue(id);

    vm.warp(block.timestamp + 2 days);

    treasury.execute(id);
}


}