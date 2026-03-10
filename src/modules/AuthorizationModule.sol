// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../libraries/SignatureVerifier.sol";

contract AuthorizationModule {

    mapping(address => bool) public isSigner;
    mapping(address => uint256) public nonces;

    constructor(address[] memory signers) {
        for(uint i; i < signers.length; i++) {
            isSigner[signers[i]] = true;
        }
    }

    function verify(
        uint256 proposalId,
        bytes memory signature
    ) public returns(address) {

        bytes32 message = keccak256(
            abi.encode(
                proposalId,
                block.chainid,
                address(this),
                nonces[msg.sender]
            )
        );

        address signer = SignatureVerifier.recover(message, signature);

        require(isSigner[signer], "not signer");

        nonces[signer]++;

        return signer;
    }
}