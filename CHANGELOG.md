# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Updated `Deploy_MultiOwnerLightAccountFactory.s.sol` to use Finance District custom salt instead of Alchemy's hardcoded salt
- Removed hardcoded address checks to enable flexible deployment across networks
- Added dynamic address calculation and improved deployment logging

---

## [2.0.0] - Fork from Alchemy Light Account

### Added
- Forked from [alchemyplatform/light-account](https://github.com/alchemyplatform/light-account)
- Initial Finance District customizations for agentic payments use case

### Notes
- This is a fork maintained by Finance District (1stdigital)
- Upstream repository: https://github.com/alchemyplatform/light-account
- All changes from this point forward are tracked in this changelog

---

## Upstream Changes (from Alchemy)

For changes prior to the fork, see the original repository:
https://github.com/alchemyplatform/light-account

---

[Unreleased]: https://github.com/1stdigital/fd-light-account/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/1stdigital/fd-light-account/releases/tag/v2.0.0
