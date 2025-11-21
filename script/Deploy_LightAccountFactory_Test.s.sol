// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";

import {LightAccountFactory} from "../src/LightAccountFactory.sol";

/// @dev Test deployment script without deterministic address checks
/// This allows deployment with custom owner addresses for testing
contract Deploy_LightAccountFactory_Test is Script {
    // Load entrypoint from env
    address public entryPointAddr = vm.envAddress("ENTRYPOINT");
    IEntryPoint public entryPoint = IEntryPoint(payable(entryPointAddr));

    // Load factory owner from env
    address public owner = vm.envAddress("OWNER");

    function run() public {
        vm.startBroadcast();

        console.log("********************************");
        console.log("******** Deploy Inputs *********");
        console.log("********************************");
        console.log("Owner:", owner);
        console.log("Entrypoint:", address(entryPoint));
        console.log();
        console.log("********************************");
        console.log("******** Deploying.... *********");
        console.log("********************************");

        // Deploy without salt for test deployment
        LightAccountFactory factory = new LightAccountFactory(owner, entryPoint);

        // Optional: Add stake if you have enough funds
        // Uncomment the following line if you want to stake
        // _addStakeForFactory(address(factory));

        console.log("LightAccountFactory:", address(factory));
        console.log("LightAccount:", address(factory.ACCOUNT_IMPLEMENTATION()));
        console.log();
        console.log("********************************");
        console.log("Deployment successful!");
        console.log("********************************");

        vm.stopBroadcast();
    }

    function _addStakeForFactory(address factoryAddr) internal {
        uint32 unstakeDelaySec = uint32(vm.envOr("UNSTAKE_DELAY_SEC", uint32(86400)));
        uint256 requiredStakeAmount = vm.envUint("REQUIRED_STAKE_AMOUNT");
        uint256 currentStakedAmount = entryPoint.getDepositInfo(factoryAddr).stake;
        uint256 stakeAmount = requiredStakeAmount - currentStakedAmount;

        console.log("******** Adding Stake *********");
        console.log("Stake amount needed:", stakeAmount);

        LightAccountFactory(payable(factoryAddr)).addStake{value: stakeAmount}(unstakeDelaySec, stakeAmount);

        console.log("******** Add Stake Verify *********");
        console.log("Staked factory: ", factoryAddr);
        console.log("Stake amount: ", entryPoint.getDepositInfo(factoryAddr).stake);
        console.log("Unstake delay: ", entryPoint.getDepositInfo(factoryAddr).unstakeDelaySec);
        console.log("******** Stake Verify Done *********");
    }
}
