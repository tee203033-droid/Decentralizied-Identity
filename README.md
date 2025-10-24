# Decentralized Identity Management on Stacks

## Project Overview
This project implements a decentralized identity (DID) management system on the Stacks blockchain using Clarinet. It enables users to:
- Register and manage their decentralized identities (DID-like documents).
- Issue and revoke verifiable credentials (e.g., "over_18").
- Verify specific attributes without revealing sensitive data, using existence checks for privacy (simulating basic zero-knowledge proof functionality).
- Leverage Stacks' Bitcoin anchoring for secure, immutable identity records.

The system includes a Clarity smart contract, a comprehensive test suite, and a web-based UI for interacting with the contract via a Stacks wallet (e.g., Hiro Wallet). Users maintain control over their data, issuers manage credentials, and verifiers check attributes securely.

## Features
- **Identity Registration**: Users register DID documents with a public key and authentication method.
- **Credential Management**: Issuers can issue and revoke credentials (e.g., proving age or eligibility).
- **Attribute Verification**: Verifiers can confirm credential validity without accessing full data.
- **Privacy**: Basic privacy is achieved via existence checks (full ZKP would require off-chain computation).
- **UI**: A web interface to connect to the contract, perform actions, and view results.

## Project Structure