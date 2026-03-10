// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AresTreasury.sol";
import "../src/modules/AuthorizationModule.sol";
import "../src/modules/RewardDistributor.sol";

contract Deploy is Script {

    function run() external {

        vm.startBroadcast();

        address[] memory signers = new address[](1);
        signers[0] = msg.sender;

        AresTreasury treasury = new AresTreasury();

        AuthorizationModule auth = new AuthorizationModule(signers);

        RewardDistributor distributor = new RewardDistributor(address(0));      

        vm.stopBroadcast();

        console.log("Treasury:", address(treasury));
        console.log("Auth:", address(auth));
        console.log("Distributor:", address(distributor));
    }
}
