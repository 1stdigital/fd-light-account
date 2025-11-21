// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {Script, console} from "forge-std/Script.sol";
import {MultiOwnerLightAccountFactory} from "../src/MultiOwnerLightAccountFactory.sol";

/// @title CreateMultiOwnerAccount
/// @notice Script to create a multi-owner account from the deployed factory
/// @dev Reads owner private keys from environment variables and derives addresses
contract CreateMultiOwnerAccount is Script {
    function run() external {
        // Load factory address from environment or use default
        address factoryAddress = vm.envOr("MULTI_OWNER_FACTORY_ADDRESS", address(0));
        require(factoryAddress != address(0), "MULTI_OWNER_FACTORY_ADDRESS not set in .env");

        MultiOwnerLightAccountFactory factory = MultiOwnerLightAccountFactory(payable(factoryAddress));

        // Get deployer private key
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        // Build owners array from environment variables
        address[] memory owners = _buildOwnersArray(deployerAddress);

        require(owners.length >= 1 && owners.length <= 100, "Invalid number of owners (1-100)");

        // Get salt for deterministic address
        uint256 salt = vm.envOr("ACCOUNT_SALT", uint256(456));

        console.log("Creating multi-owner account with", owners.length, "owners:");
        for (uint256 i = 0; i < owners.length; i++) {
            console.log("  Owner", i + 1, ":", owners[i]);
        }
        console.log("Salt:", salt);

        // Get counterfactual address before deployment
        address predictedAddress = factory.getAddress(owners, salt);
        console.log("\nPredicted account address:", predictedAddress);

        // Check if account already exists
        if (predictedAddress.code.length > 0) {
            console.log("Account already exists at this address");
            return;
        }

        // Create the account
        vm.startBroadcast(deployerPrivateKey);
        address accountAddress = address(factory.createAccount(owners, salt));
        vm.stopBroadcast();

        console.log("\nAccount created successfully!");
        console.log("Account address:", accountAddress);
        console.log("Owners:", owners.length);
    }

    /// @dev Build sorted owners array from environment variables
    function _buildOwnersArray(address deployerAddress) internal view returns (address[] memory) {
        // Start with deployer as first owner
        address[] memory tempOwners = new address[](100); // Max possible owners
        uint256 count = 0;

        // Add deployer
        tempOwners[count++] = deployerAddress;

        // Try to load additional owner private keys
        string memory secondOwnerPk = vm.envOr("SECOND_OWNER_PRIVATE_KEY", string(""));
        if (bytes(secondOwnerPk).length > 0) {
            uint256 secondPk = vm.parseUint(secondOwnerPk);
            address secondOwner = vm.addr(secondPk);
            if (secondOwner != deployerAddress) {
                tempOwners[count++] = secondOwner;
            }
        }

        string memory thirdOwnerPk = vm.envOr("THIRD_OWNER_PRIVATE_KEY", string(""));
        if (bytes(thirdOwnerPk).length > 0) {
            uint256 thirdPk = vm.parseUint(thirdOwnerPk);
            address thirdOwner = vm.addr(thirdPk);
            if (thirdOwner != deployerAddress && thirdOwner != tempOwners[1]) {
                tempOwners[count++] = thirdOwner;
            }
        }

        // Create final array with actual count
        address[] memory owners = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            owners[i] = tempOwners[i];
        }

        // Sort owners in ascending order (required by MultiOwnerLightAccount)
        _sortAddresses(owners);

        return owners;
    }

    /// @dev Simple bubble sort for addresses (ascending order)
    function _sortAddresses(address[] memory arr) internal pure {
        uint256 length = arr.length;
        for (uint256 i = 0; i < length; i++) {
            for (uint256 j = i + 1; j < length; j++) {
                if (uint160(arr[i]) > uint160(arr[j])) {
                    address temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
    }
}
