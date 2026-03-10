// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.t.sol";

contract AttackTests is BaseTest {

    function testPrematureExecutionReverts() public {

    uint id = treasury.propose(address(this), 0, "");

    vm.expectRevert("not approved");

    treasury.execute(id);
}

    function testProposalReplayFails() public {

    uint id = treasury.propose(address(this), 0, "");

    vm.warp(block.timestamp + 1 hours);

    treasury.approve(id);
    treasury.approve(id);

    treasury.queue(id);

    vm.warp(block.timestamp + 2 days);

    treasury.execute(id);

    vm.expectRevert();

    treasury.execute(id);
}

    function testDoubleClaimReverts() public {

        bytes32[] memory proof;

        vm.expectRevert();

        distributor.claim(100, proof);

        vm.expectRevert();

        distributor.claim(100, proof);
    }

    function testInvalidSignature() public {

        vm.expectRevert();

        auth.verify(1, hex"1234");
    }

    function testQueueTwiceReverts() public {

        uint id = treasury.propose(address(0xBEEF), 0, "");

        vm.warp(block.timestamp + 1 hours);

        treasury.approve(id);
        treasury.queue(id);

        vm.expectRevert();

        treasury.queue(id);
    }
}