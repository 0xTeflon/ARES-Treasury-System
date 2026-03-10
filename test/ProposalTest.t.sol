// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.t.sol";

contract ProposalTest is BaseTest {

    function testProposalCreation() public {

        uint id = treasury.propose(address(0), 0, "");

        assertEq(id, 1);
    }

    function testProposalApproval() public {

        uint id = treasury.propose(address(0), 0, "");

        vm.warp(block.timestamp + 1 hours);

        treasury.approve(id);

        (,, , uint approvals,,) = treasury.proposals(id);

        assertEq(approvals, 1);
    }
}