# Changelog

All notable changes to this project will be documented in this file.

This project is a fork of [alchemyplatform/light-account](https://github.com/alchemyplatform/light-account) 
and is licensed under GPL-3.0. See LICENSE-GPL for details.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed - 2025-11-21

#### src/common/BaseLightAccount.sol
- Made `execute(address,uint256,bytes)` function payable (line 55)
- Made `executeBatch(address[],bytes[])` function payable (line 64)
- Made `executeBatch(address[],uint256[],bytes[])` function payable (line 80)
- **Rationale**: Enable receiving native tokens (BNB/ETH) during transaction execution for Coinbase Smart Wallet compatibility

### Added - 2025-11-21

#### Deployment Scripts
- `script/Deploy_MultiOwnerLightAccountFactory.s.sol` - Updated for BSC networks
- `script/CreateMultiOwnerAccount.s.sol` - Script to create multi-owner test accounts

#### Documentation
- `deployments/testnets/bsc-testnet.md` - BSC Testnet deployment details
- `deployments/mainnets/bsc-mainnet.md` - BSC Mainnet deployment details
- `CHANGELOG.md` - This file for GPL-3.0 compliance

#### Deployments
- MultiOwnerLightAccountFactory deployed to BSC Testnet (Chain ID: 97)
  - Factory: `0x2fB513841854dc8D32949b21DDbe1a73fF21f173`
  - Implementation: `0x9f61C0F09d3822CBfff7f6FE4124759C928E736A`
- MultiOwnerLightAccountFactory deployed to BSC Mainnet (Chain ID: 56)
  - Factory: `0x2fB513841854dc8D32949b21DDbe1a73fF21f173`
  - Implementation: `0x9f61C0F09d3822CBfff7f6FE4124759C928E736A`

### Removed - 2025-11-21
- `script/Deploy_LightAccountFactory_BSC.s.sol` - Consolidated into main deployment script

---

## Original Project

This is a fork of [Alchemy's Light Account](https://github.com/alchemyplatform/light-account).

For the original project's changelog and releases, see the upstream repository.
