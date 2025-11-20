// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";

import {LightAccountFactory} from "../src/LightAccountFactory.sol";

/// @dev BSC deployment script without deterministic address checks
/// This allows deployment with custom owner addresses for BSC Testnet and Mainnet
contract Deploy_LightAccountFactory_BSC is Script {
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
        console.log("Network:", block.chainid == 97 ? "BSC Testnet" : block.chainid == 56 ? "BSC Mainnet" : "Unknown");
        console.log("Chain ID:", block.chainid);
        console.log("Deployer:", msg.sender);
        console.log("Owner:", owner);
        console.log("Entrypoint:", address(entryPoint));
        console.log();
        console.log("********************************");
        console.log("******** Deploying.... *********");
        console.log("********************************");

        // Deploy without salt for custom deployment
        LightAccountFactory factory = new LightAccountFactory(owner, entryPoint);

        console.log("LightAccountFactory:", address(factory));
        console.log("LightAccount Implementation:", address(factory.ACCOUNT_IMPLEMENTATION()));
        console.log();
        
        // Test account address prediction
        address predictedAccount = factory.getAddress(owner, 0);
        console.log("Sample Account Address (owner=", owner, ", salt=0):");
        console.log("  ", predictedAccount);
        console.log();

        console.log("********************************");
        console.log("Deployment successful!");
        console.log("********************************");
        console.log();
        console.log("Next steps:");
        console.log("1. Verify contract on BSCScan");
        console.log("2. Create test account using createAccount(address,uint256)");
        console.log("3. Fund factory for staking if needed");

        vm.stopBroadcast();
    }

    /// @dev Optional staking function - call separately if needed
    function addStake() public {
        vm.startBroadcast();
        
        address factoryAddr = vm.envAddress("FACTORY_ADDRESS");
        uint32 unstakeDelaySec = uint32(vm.envOr("UNSTAKE_DELAY_SEC", uint32(86400)));
        uint256 requiredStakeAmount = vm.envUint("REQUIRED_STAKE_AMOUNT");
        
        uint256 currentStakedAmount = entryPoint.getDepositInfo(factoryAddr).stake;
        uint256 stakeAmount = requiredStakeAmount - currentStakedAmount;
        
        console.log("******** Adding Stake *********");
        console.log("Factory:", factoryAddr);
        console.log("Stake amount needed:", stakeAmount);
        
        LightAccountFactory(payable(factoryAddr)).addStake{value: stakeAmount}(unstakeDelaySec, stakeAmount);
        
        console.log("******** Stake Verification *********");
        console.log("Current stake:", entryPoint.getDepositInfo(factoryAddr).stake);
        console.log("Unstake delay:", entryPoint.getDepositInfo(factoryAddr).unstakeDelaySec);
        
        vm.stopBroadcast();
    }
}
