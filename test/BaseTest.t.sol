// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol"; 
import "../src/core/AresTreasury.sol";
import "../src/modules/AuthorizationModule.sol";
import "../src/modules/RewardDistributor.sol";

contract BaseTest is Test {
    AresTreasury treasury;
    RewardDistributor distributor;
    AuthorizationModule auth;
    address signer;

    function setUp() public virtual {
        signer = address(0x1234);
        
        // Initialize instances
        treasury = new AresTreasury();
        
        // RewardDistributor needs a token address
        distributor = new RewardDistributor(address(0));
        
        // AuthorizationModule needs an array of signer addresses
        address[] memory signers = new address[](1);
        signers[0] = signer;
        auth = new AuthorizationModule(signers);
    }

    receive() external payable {}
    
    fallback() external payable {}
}
