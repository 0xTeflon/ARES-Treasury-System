# ARES Treasury System

## Introduction

This project is a simple treasury system built for the **ARES Protocol task**. The goal of this system is to manage protocol funds in a safer way. The treasury allows governance to create proposals, approve them, delay execution, and finally execute treasury actions.

Many protocols in the past had problems like governance attacks, replay attacks, and unsafe vault designs. Because of that, this system was built with multiple modules and security checks to reduce these risks.

The contracts were written in **Solidity** and tested using **Foundry**.

---

## Project Structure

The project is separated into different folders.

```id="v25bq4"
src/
  core/
  modules/
  libraries/
  interfaces/

script/
test/
```

### Core

This folder contains the main contract.

```id="o2cew4"
AresTreasury.sol
```

This contract executes treasury transactions after all checks are passed.

---

### Modules

The modules folder contains the main logic of the protocol.

```id="gojg0p"
ProposalModule.sol
AuthorizationModule.sol
TimelockModule.sol
RewardDistributor.sol
```

Each module does a specific job.

- ProposalModule → manages treasury proposals
- AuthorizationModule → verifies signatures
- TimelockModule → adds delay before execution
- RewardDistributor → handles contributor rewards

---

### Libraries

The libraries folder contains helper code used by other contracts.

```id="o17q0h"
SignatureVerifier.sol
```

This library helps recover addresses from signatures.

---

### Interfaces

Interfaces define how contracts interact with each other.

```id="tqjcdh"
ITreasury.sol
IRewardDistributor.sol
```

---

## How the System Works

The treasury follows a simple process.

```id="l27w64"
propose → approve → queue → delay → execute
```

1. A user creates a proposal.
2. Governance signers approve the proposal.
3. The proposal is queued in the timelock.
4. The system waits for the delay.
5. The treasury executes the action.

This process prevents proposals from executing immediately.

---

## Reward Distribution

The protocol also distributes rewards to contributors.

Instead of sending tokens to each user manually, the system stores a **Merkle root**. Users submit a proof to claim their reward.

The contract also tracks which users already claimed so they cannot claim twice.

---

## Security Features

The system includes some basic protections.

- Signature replay protection using nonces
- Timelock delay before execution
- Prevention of double reward claims
- Execution checks before treasury calls
- Basic governance protection rules

These protections help reduce common smart contract risks.

---

## Tests

The project includes tests written in Foundry.

The tests check normal functionality like proposal creation and timelock execution. They also simulate attacks like invalid signatures and double reward claims.

To run the tests:

```id="egpmb9"
forge build
forge test -vv
```

---

## Conclusion

This project demonstrates a modular treasury system with basic governance and security controls. The system separates logic into multiple contracts to make it easier to understand and review.
