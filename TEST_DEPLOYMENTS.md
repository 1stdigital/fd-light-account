# Deployment Testing Guide

This guide provides step-by-step tests to verify your deployed Light Account Factory contracts.

## Test Environment Setup

```bash
# Load environment variables
source .env

# Set deployed addresses
export FACTORY_BSC_TESTNET=0x12336304c09CB56C48DB6f9bC4cc17e743665B99
export FACTORY_BSC_MAINNET=0x58a0e792F31Cf37E34fd36D2d01312dE4A781567
```

---

## BSC Testnet Tests

### Test 1: Verify Factory Deployment

```bash
# Check factory owner
cast call $FACTORY_BSC_TESTNET "owner()" --rpc-url $BSC_TESTNET_RPC_URL

# Expected: 0x0000000000000000000000005a1448f48f844e4ef8f48ba6cf39a0373683fa5e
```

### Test 2: Verify EntryPoint Configuration

```bash
# Check EntryPoint address
cast call $FACTORY_BSC_TESTNET "ENTRY_POINT()" --rpc-url $BSC_TESTNET_RPC_URL

# Expected: 0x0000000000000000000000000000000071727de22e5e9d8baf0edac6f37da032
```

### Test 3: Verify Implementation Address

```bash
# Check account implementation
cast call $FACTORY_BSC_TESTNET "ACCOUNT_IMPLEMENTATION()" --rpc-url $BSC_TESTNET_RPC_URL

# Expected: 0x0000000000000000000000002b83e9a64e78d4666ab2e8c3193a44dd22d29429
```

### Test 4: Predict Account Address (No Deployment)

```bash
# Predict account address for owner with salt=0
cast call $FACTORY_BSC_TESTNET \
  "getAddress(address,uint256)" \
  $OWNER 0 \
  --rpc-url $BSC_TESTNET_RPC_URL

# Expected: 0xbD486319CF578D36A747f1F0585EB71286dC80D8
```

### Test 5: Create First Account

```bash
# Create account (this will deploy the account contract)
cast send $FACTORY_BSC_TESTNET \
  "createAccount(address,uint256)" \
  $OWNER 0 \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --legacy

# Save transaction hash and verify on BSCScan
```

### Test 6: Verify Account Deployment

```bash
# Get the account address from previous prediction
export TEST_ACCOUNT=0xbD486319CF578D36A747f1F0585EB71286dC80D8

# Verify account exists (should return code size > 0)
cast code $TEST_ACCOUNT --rpc-url $BSC_TESTNET_RPC_URL

# Check account owner
cast call $TEST_ACCOUNT "owner()" --rpc-url $BSC_TESTNET_RPC_URL

# Expected: Your OWNER address
```

### Test 7: Verify Account is ERC-4337 Compatible

```bash
# Check entryPoint on account
cast call $TEST_ACCOUNT "entryPoint()" --rpc-url $BSC_TESTNET_RPC_URL

# Expected: 0x0000000071727De22E5E9d8BAf0edAc6f37da032
```

### Test 8: Test Account Creation Idempotency

```bash
# Try creating the same account again (should return existing address)
cast send $FACTORY_BSC_TESTNET \
  "createAccount(address,uint256)" \
  $OWNER 0 \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --legacy

# Should succeed without deploying new contract (lower gas)
```

### Test 9: Create Account with Different Salt

```bash
# Predict address with salt=1
cast call $FACTORY_BSC_TESTNET \
  "getAddress(address,uint256)" \
  $OWNER 1 \
  --rpc-url $BSC_TESTNET_RPC_URL

# Create account with salt=1
cast send $FACTORY_BSC_TESTNET \
  "createAccount(address,uint256)" \
  $OWNER 1 \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --legacy

# Verify different address than salt=0
```

### Test 10: Fund Account and Test Native Transfer

```bash
# Send some test BNB to the account
cast send $TEST_ACCOUNT \
  --value 0.001ether \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --legacy

# Check account balance
cast balance $TEST_ACCOUNT --rpc-url $BSC_TESTNET_RPC_URL
```

### Test 11: Test Account Execute Function

```bash
# Prepare a simple transfer from the account
# Note: This requires the account owner to sign
cast send $TEST_ACCOUNT \
  "execute(address,uint256,bytes)" \
  $OWNER \
  0.0001ether \
  0x \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --legacy
```

### Test 12: Test ERC-1271 Signature Validation

```bash
# Create a message hash
MESSAGE_HASH=$(cast keccak "Hello World")

# Sign the message (you'll need to do this with your owner key)
# Then call isValidSignature on the account
cast call $TEST_ACCOUNT \
  "isValidSignature(bytes32,bytes)" \
  $MESSAGE_HASH \
  0x<signature> \
  --rpc-url $BSC_TESTNET_RPC_URL
```

---

## BSC Mainnet Tests (Production Verification)

### ⚠️ Warning: Use Small Amounts on Mainnet

```bash
export FACTORY_MAINNET=$FACTORY_BSC_MAINNET
```

### Test 1: Verify Mainnet Factory

```bash
# Check owner
cast call $FACTORY_MAINNET "owner()" --rpc-url https://bsc-dataseed1.binance.org

# Check implementation
cast call $FACTORY_MAINNET "ACCOUNT_IMPLEMENTATION()" --rpc-url https://bsc-dataseed1.binance.org

# Check EntryPoint
cast call $FACTORY_MAINNET "ENTRY_POINT()" --rpc-url https://bsc-dataseed1.binance.org
```

### Test 2: Predict Mainnet Account Address

```bash
# Predict your mainnet account address
cast call $FACTORY_MAINNET \
  "getAddress(address,uint256)" \
  $OWNER 0 \
  --rpc-url https://bsc-dataseed1.binance.org
```

### Test 3: Create Production Account (Optional)

```bash
# Only run if you need the account deployed
cast send $FACTORY_MAINNET \
  "createAccount(address,uint256)" \
  $OWNER 0 \
  --rpc-url https://bsc-dataseed1.binance.org \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --legacy
```

---

## Advanced Tests

### Test: Gas Comparison

```bash
# First account creation (deployment)
# Should use ~2.1M gas

# Second account creation (same params)
# Should use ~50K gas (just return existing address)
```

### Test: Multiple Accounts Per Owner

```bash
# Create 3 accounts for same owner with different salts
for i in {0..2}; do
  echo "Creating account with salt=$i"
  cast send $FACTORY_BSC_TESTNET \
    "createAccount(address,uint256)" \
    $OWNER $i \
    --rpc-url $BSC_TESTNET_RPC_URL \
    --private-key $DEPLOYER_PRIVATE_KEY \
    --legacy
done
```

### Test: Cross-Chain Address Consistency

```bash
# Predict addresses on both chains with same owner and salt
echo "BSC Testnet:"
cast call $FACTORY_BSC_TESTNET \
  "getAddress(address,uint256)" \
  $OWNER 0 \
  --rpc-url $BSC_TESTNET_RPC_URL

echo "BSC Mainnet:"
cast call $FACTORY_BSC_MAINNET \
  "getAddress(address,uint256)" \
  $OWNER 0 \
  --rpc-url https://bsc-dataseed1.binance.org

# Note: Addresses will be DIFFERENT because factories have different addresses
# For deterministic cross-chain addresses, use the original Alchemy deployment script
```

---

## Integration Tests with ERC-4337

### Test: UserOperation Structure

```bash
# This requires setting up with a bundler
# See: https://docs.alchemy.com/docs/account-abstraction-overview

# 1. Create account
# 2. Fund account
# 3. Create UserOperation
# 4. Submit to bundler
# 5. Verify execution
```

---

## Expected Results Summary

| Test               | Expected Result                            | Critical?    |
| ------------------ | ------------------------------------------ | ------------ |
| Factory Owner      | Your OWNER address                         | ✅ Yes       |
| EntryPoint         | 0x0000000071727De22E5E9d8BAf0edAc6f37da032 | ✅ Yes       |
| Implementation     | Non-zero address                           | ✅ Yes       |
| Account Prediction | Consistent address                         | ✅ Yes       |
| Account Creation   | Success, gas ~2.1M                         | ✅ Yes       |
| Account Owner      | Your OWNER address                         | ✅ Yes       |
| Idempotency        | Success, gas ~50K                          | ✅ Yes       |
| Different Salt     | Different address                          | ✅ Yes       |
| Native Transfer    | Success                                    | ⚠️ Important |
| Execute Function   | Success                                    | ⚠️ Important |

---

## Troubleshooting

### Issue: Transaction Reverted

**Possible Causes:**

1. Insufficient gas
2. Wrong parameters
3. Account already initialized

**Solution:**

```bash
# Check account state
cast call $TEST_ACCOUNT "owner()" --rpc-url $BSC_TESTNET_RPC_URL

# Check factory owner
cast call $FACTORY_BSC_TESTNET "owner()" --rpc-url $BSC_TESTNET_RPC_URL
```

### Issue: Address Mismatch

**Cause:** Using different factory addresses or parameters

**Solution:**
Verify you're using the correct:

- Factory address
- Owner address
- Salt value

---

## Success Criteria

✅ All critical tests pass
✅ Account can be created and funded
✅ Factory ownership is correct
✅ EntryPoint is properly configured
✅ Gas costs are reasonable
✅ Idempotency works correctly

---

## Next Steps After Testing

1. **Document Results**: Record all transaction hashes
2. **Verify on Explorer**: Check all contracts on BSCScan
3. **Update Documentation**: Add deployment info to team docs
4. **Set Up Monitoring**: Track factory usage
5. **Integrate with Bundler**: For full ERC-4337 functionality
6. **Security Audit**: Before production use with real funds

---

## Additional Resources

- [Account Abstraction Docs](https://docs.alchemy.com/docs/account-abstraction-overview)
- [ERC-4337 Spec](https://eips.ethereum.org/EIPS/eip-4337)
- [Light Account GitHub](https://github.com/alchemyplatform/light-account)
- [BSCScan Testnet](https://testnet.bscscan.com)
- [BSCScan Mainnet](https://bscscan.com)
