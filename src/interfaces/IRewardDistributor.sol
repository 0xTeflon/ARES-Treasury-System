// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRewardDistributor {

    function setRoot(bytes32 newRoot) external;

    function claim(
        uint256 amount,
        bytes32[] calldata proof
    ) external;

    function root() external view returns (bytes32);

    function claimed(address user) external view returns (bool);
}