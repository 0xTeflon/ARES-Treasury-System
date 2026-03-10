// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseTest.t.sol";

contract AuthorizationTest is BaseTest {

    function testSignerExists() public {

        bool allowed = auth.isSigner(signer);

        assertTrue(allowed);
    }

    function testNonceIncrement() public {

    vm.expectRevert("not signer");

    vm.prank(signer);
    auth.verify(1, hex"1234");
}
}