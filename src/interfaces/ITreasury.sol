// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITreasury {

    function propose(
        address target,
        uint256 value,
        bytes calldata data
    ) external returns (uint256);

    function queue(uint256 proposalId) external;

    function execute(uint256 proposalId) external;

    function proposalCount() external view returns (uint256);

    function executionTime(uint256 proposalId) external view returns (uint256);
}