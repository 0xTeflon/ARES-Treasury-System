// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RewardDistributor {

    IERC20 public token;
    bytes32 public root;

    mapping(address => bool) public claimed;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function setRoot(bytes32 _root) public {
        root = _root;
    }

    function claim(uint256 amount, bytes32[] calldata proof) public {

        require(!claimed[msg.sender], "claimed");

        bytes32 leaf = keccak256(
            abi.encode(msg.sender, amount)
        );

        require(
            MerkleProof.verify(proof, root, leaf),
            "invalid proof"
        );

        claimed[msg.sender] = true;

        token.transfer(msg.sender, amount);
    }
}
