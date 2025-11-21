# BSC Mainnet

Chain ID: 56

## LightAccountFactory

| Version | Address                                      | Explorer                                                                          | Salt | Run                                                                  |
| ------- | -------------------------------------------- | --------------------------------------------------------------------------------- | ---- | -------------------------------------------------------------------- |
| Custom  | `0x58a0e792F31Cf37E34fd36D2d01312dE4A781567` | [explorer](https://bscscan.com/address/0x58a0e792F31Cf37E34fd36D2d01312dE4A781567) | N/A  | [tx](https://bscscan.com/tx/0x9f18d96065dec0b4482da8f6924f9647a7a417310bb2bae95371b921dac8a095) |

## LightAccount

| Version | Address                                      | Explorer                                                                          | Run                                                                  |
| ------- | -------------------------------------------- | --------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Custom  | `0x7a741b766C4bD708bB010212643b75658f185c28` | [explorer](https://bscscan.com/address/0x7a741b766C4bD708bB010212643b75658f185c28) | [tx](https://bscscan.com/tx/0x9f18d96065dec0b4482da8f6924f9647a7a417310bb2bae95371b921dac8a095) |

## Sample Account (salt=0)

| Owner                                        | Address                                      | Explorer                                                                          | Run |
| -------------------------------------------- | -------------------------------------------- | --------------------------------------------------------------------------------- | --- |
| `0x5A1448F48F844e4eF8F48Ba6cF39A0373683fA5e` | `0x0F6ea3361F010FEcf515FA9F161AB23e9b08E889` | [explorer](https://bscscan.com/address/0x0F6ea3361F010FEcf515FA9F161AB23e9b08E889) | Not yet created |

## Deployment Details

- **Deployer**: `0x5A1448F48F844e4eF8F48Ba6cF39A0373683fA5e`
- **Block Number**: 68,850,670
- **Timestamp**: November 20, 2025
- **EntryPoint**: `0x0000000071727De22E5E9d8BAf0edAc6f37da032` (ERC-4337 v0.7)
- **Gas Used**: 2,686,123 gas
- **Gas Price**: 0.05 gwei

## Notes

⚠️ **Custom Deployment**: This deployment uses a custom owner address (`0x5A1448F48F844e4eF8F48Ba6cF39A0373683fA5e`) and therefore does not match the canonical cross-chain factory addresses used in official Alchemy deployments. The factory address is unique to BSC Mainnet.

For deterministic cross-chain addresses matching other networks, use the official Alchemy deployment with owner address `0x...` (TBD).

⚠️ **Production Warning**: This deployment is on BSC Mainnet with real BNB. Ensure thorough testing before use in production applications.

## MultiOwnerLightAccountFactory

Not yet deployed on BSC Mainnet.

## MultiOwnerLightAccount

Not yet deployed on BSC Mainnet.
