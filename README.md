# Token Sale Smart Contract

## Introduction

This is a Solidity smart contract for conducting a token sale in two phases: a presale and a public sale. It enables contributors to exchange Ether for project tokens. The smart contract includes features such as contribution limits, token distribution, and refund functionality based on the minimum cap.

## Design Choices

## Security Consideration

## Features

### Presale:

- Users can contribute Ether to the presale and receive project tokens.
- Maximum cap on total Ether raised.
- Minimum and maximum contribution limits per participant.
- Immediate token distribution upon contribution.

### Public Sale:

- Public sale begins after the presale ends.
- Users can contribute Ether to the public sale and receive project tokens.
- Maximum cap on total Ether raised.
- Minimum and maximum contribution limits per participant.
- Immediate token distribution upon contribution.

### Token Distribution:

- Owner-exclusive function to distribute project tokens to a specified address.

### Refund:

- Contributors can claim refunds if the minimum cap for the presale or public sale is not reached.

## Requirements

To use and deploy this smart contract, make sure to meet the following requirements:

- Implement the smart contract in Solidity.
- Use the ERC-20 standard for the project token.
- Incorporate proper error handling and event logging.
- Ensure the smart contract adheres to security best practices.
