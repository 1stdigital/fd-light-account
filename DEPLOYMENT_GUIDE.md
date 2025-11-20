# Deployment Guide - Light Account Factory

This guide covers deploying the Light Account Factory to test and production networks.

## Prerequisites

1. **Fund your deployer address** with native tokens:
   - Base Sepolia: Get ETH from [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)
   - BSC Testnet: Get BNB from [BSC Testnet Faucet](https://testnet.bnbchain.org/faucet-smart)
   - For mainnet: Ensure sufficient funds for gas + staking (0.1 ETH/BNB recommended)

2. **Configure `.env`** file with:
   ```bash
   DEPLOYER_PRIVATE_KEY=0x...
   OWNER=0x...  # Factory owner address
   ENTRYPOINT=0x0000000071727De22E5E9d8BAf0edAc6f37da032  # ERC-4337 v0.7 EntryPoint
   ```

## Deployment Scripts

### 1. Base Sepolia (Testnet)

```bash
# Load environment variables
source .env

# Dry run (simulation)
forge script script/Deploy_LightAccountFactory_Test.s.sol \
  --rpc-url $BASE_SEPOLIA_RPC_URL

# Deploy
forge script script/Deploy_LightAccountFactory_Test.s.sol \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast

# Deploy with verification
forge script script/Deploy_LightAccountFactory_Test.s.sol \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

**Estimated Cost:** ~0.000025 ETH (~$0.09 USD)

### 2. BSC Testnet

```bash
# Load environment variables
source .env

# Dry run (simulation)
forge script script/Deploy_LightAccountFactory_BSC.s.sol \
  --rpc-url $BSC_TESTNET_RPC_URL

# Deploy
forge script script/Deploy_LightAccountFactory_BSC.s.sol \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast

# Deploy with verification
forge script script/Deploy_LightAccountFactory_BSC.s.sol \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $BSCSCAN_API_KEY
```

**Estimated Cost:** ~0.02 BNB

### 3. BSC Mainnet

```bash
# Load environment variables
source .env

# IMPORTANT: Use hardware wallet or secure key management for mainnet!

# Dry run (simulation) - ALWAYS test first!
forge script script/Deploy_LightAccountFactory_BSC.s.sol \
  --rpc-url $BSC_MAINNET_RPC_URL

# Deploy (use --ledger or --trezor for hardware wallet)
forge script script/Deploy_LightAccountFactory_BSC.s.sol \
  --rpc-url $BSC_MAINNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $BSCSCAN_API_KEY

# Or with Ledger hardware wallet:
forge script script/Deploy_LightAccountFactory_BSC.s.sol \
  --rpc-url $BSC_MAINNET_RPC_URL \
  --ledger \
  --sender $OWNER \
  --broadcast \
  --verify \
  --etherscan-api-key $BSCSCAN_API_KEY
```

**Estimated Cost:** ~0.02 BNB (~$12 USD at current prices)

### 4. Base Mainnet

```bash
# Load environment variables
source .env

# Dry run (simulation) - ALWAYS test first!
forge script script/Deploy_LightAccountFactory_Test.s.sol \
  --rpc-url $BASE_MAINNET_RPC_URL

# Deploy with hardware wallet (RECOMMENDED)
forge script script/Deploy_LightAccountFactory_Test.s.sol \
  --rpc-url $BASE_MAINNET_RPC_URL \
  --ledger \
  --sender $OWNER \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

**Estimated Cost:** ~0.000025 ETH (~$0.09 USD)

## Post-Deployment Steps

### 1. Verify Deployment

Check the deployment output for:
- ✅ Factory address
- ✅ Implementation address
- ✅ Transaction hash

### 2. Verify on Block Explorer

Visit the explorer and confirm:
- Base Sepolia: https://sepolia.basescan.org/address/YOUR_FACTORY_ADDRESS
- BSC Testnet: https://testnet.bscscan.com/address/YOUR_FACTORY_ADDRESS
- BSC Mainnet: https://bscscan.com/address/YOUR_FACTORY_ADDRESS

### 3. Test Account Creation

```bash
# Get predicted address
cast call $FACTORY_ADDRESS "getAddress(address,uint256)" $OWNER 0 \
  --rpc-url $RPC_URL

# Create account
cast send $FACTORY_ADDRESS "createAccount(address,uint256)" $OWNER 0 \
  --rpc-url $RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY
```

### 4. Add Stake (Optional - for ERC-4337 bundler requirements)

```bash
# Set factory address
export FACTORY_ADDRESS=0x...

# Add stake
forge script script/Deploy_LightAccountFactory_BSC.s.sol \
  --sig "addStake()" \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast
```

## Network Information

### Supported Networks

| Network       | Chain ID | EntryPoint (v0.7)                          | Native Token |
|---------------|----------|---------------------------------------------|--------------|
| Base Sepolia  | 84532    | 0x0000000071727De22E5E9d8BAf0edAc6f37da032 | ETH          |
| Base Mainnet  | 8453     | 0x0000000071727De22E5E9d8BAf0edAc6f37da032 | ETH          |
| BSC Testnet   | 97       | 0x0000000071727De22E5E9d8BAf0edAc6f37da032 | BNB          |
| BSC Mainnet   | 56       | 0x0000000071727De22E5E9d8BAf0edAc6f37da032 | BNB          |

### RPC Endpoints

Configure in `.env`:

```bash
# Base
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASE_MAINNET_RPC_URL=https://mainnet.base.org

# BSC
BSC_TESTNET_RPC_URL=https://data-seed-prebsc-1-s1.binance.org:8545
BSC_MAINNET_RPC_URL=https://bsc-dataseed1.binance.org
```

## Troubleshooting

### Issue: "Insufficient funds"
**Solution:** Fund your deployer address with native tokens from faucet (testnet) or transfer funds (mainnet)

### Issue: "Init code hash mismatch"
**Solution:** Use the custom deployment scripts (`Deploy_LightAccountFactory_Test.s.sol` or `Deploy_LightAccountFactory_BSC.s.sol`) instead of the deterministic ones

### Issue: "Verification failed"
**Solution:** 
1. Check your API key is valid
2. Wait a few moments and try manual verification:
   ```bash
   forge verify-contract $FACTORY_ADDRESS LightAccountFactory \
     --chain-id 97 \
     --constructor-args $(cast abi-encode "constructor(address,address)" $OWNER $ENTRYPOINT) \
     --etherscan-api-key $BSCSCAN_API_KEY
   ```

### Issue: "Nonce too high/low"
**Solution:** Check your deployer address transactions and ensure nonce is correct

## Security Checklist

Before mainnet deployment:

- [ ] Private keys stored securely (use hardware wallet)
- [ ] `.env` file is in `.gitignore`
- [ ] Dry run completed successfully
- [ ] Factory owner address is correct
- [ ] EntryPoint address verified
- [ ] Sufficient funds for deployment + gas buffer
- [ ] Team review completed
- [ ] Deployment plan documented

## Gas Estimates

| Network       | Deployment | Account Creation | Stake Addition |
|---------------|------------|------------------|----------------|
| Base Sepolia  | 0.000025   | 0.000015         | 0.000010       |
| Base Mainnet  | 0.000025   | 0.000015         | 0.000010       |
| BSC Testnet   | 0.02       | 0.001            | 0.001          |
| BSC Mainnet   | 0.02       | 0.001            | 0.001          |

*Values in native tokens (ETH/BNB)*

## Support

- Documentation: https://accountkit.alchemy.com
- GitHub Issues: https://github.com/alchemyplatform/light-account/issues
- Discord: https://discord.gg/alchemyplatform
