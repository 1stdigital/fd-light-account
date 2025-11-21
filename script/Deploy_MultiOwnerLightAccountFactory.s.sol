// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";

import {MultiOwnerLightAccountFactory} from "../src/MultiOwnerLightAccountFactory.sol";

contract Deploy_MultiOwnerLightAccountFactory is Script {
    // Load entrypoint from env
    address public entryPointAddr = vm.envAddress("ENTRYPOINT");
    IEntryPoint public entryPoint = IEntryPoint(payable(entryPointAddr));

    // Load factory owner from env
    address public owner = vm.envAddress("OWNER");

    error InitCodeHashMismatch(bytes32 initCodeHash);
    error DeployedAddressMismatch(address deployed);

    function run() public {
        vm.startBroadcast();

        // Finance District custom salt
        bytes32 fdSalt = 0x000000000000000000000000000000000000000046696e616e636544697374; // "FinanceDist" in hex

        console.log("********************************");
        console.log("******** Deploy Inputs *********");
        console.log("********************************");
        console.log("Owner:", owner);
        console.log("Entrypoint:", address(entryPoint));
        console.log("Salt:", vm.toString(fdSalt));
        console.log();

        // Calculate expected address for transparency
        bytes32 initCodeHash =
            keccak256(abi.encodePacked(type(MultiOwnerLightAccountFactory).creationCode, abi.encode(owner, entryPoint)));
        address expectedAddress = vm.computeCreate2Address(fdSalt, initCodeHash);

        console.log("********************************");
        console.log("******** Deploying.... *********");
        console.log("********************************");
        console.log("Expected factory address:", expectedAddress);
        console.log();

        MultiOwnerLightAccountFactory factory = new MultiOwnerLightAccountFactory{
            salt: fdSalt
        }(owner, entryPoint);

        console.log("Actual factory address:", address(factory));
        
        // Verify addresses match
        if (address(factory) != expectedAddress) {
            revert DeployedAddressMismatch(address(factory));
        }

        _addStakeForFactory(address(factory));

        console.log("MultiOwnerLightAccountFactory:", address(factory));
        console.log("MultiOwnerLightAccount:", address(factory.ACCOUNT_IMPLEMENTATION()));
        console.log();

        vm.stopBroadcast();
    }

    function _addStakeForFactory(address factoryAddr) internal {
        uint32 unstakeDelaySec = uint32(vm.envOr("UNSTAKE_DELAY_SEC", uint32(86400)));
        uint256 requiredStakeAmount = vm.envUint("REQUIRED_STAKE_AMOUNT");
        uint256 currentStakedAmount = entryPoint.getDepositInfo(factoryAddr).stake;
        uint256 stakeAmount = requiredStakeAmount - currentStakedAmount;
        MultiOwnerLightAccountFactory(payable(factoryAddr)).addStake{value: stakeAmount}(unstakeDelaySec, stakeAmount);
        console.log("******** Add Stake Verify *********");
        console.log("Staked factory: ", factoryAddr);
        console.log("Stake amount: ", entryPoint.getDepositInfo(factoryAddr).stake);
        console.log("Unstake delay: ", entryPoint.getDepositInfo(factoryAddr).unstakeDelaySec);
        console.log("******** Stake Verify Done *********");
    }
}
