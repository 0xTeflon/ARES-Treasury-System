// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.t.sol";

contract RewardTest is BaseTest {

    function testRootUpdate() public {

        bytes32 root = keccak256("rewards");

        distributor.setRoot(root);

        assertEq(distributor.root(), root);
    }
}