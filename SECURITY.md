# SECURITY.md

## Security Analysis – ARES Treasury Protocol

The ARES treasury protocol is designed to securely manage large protocol funds while minimizing the risk of common smart contract attacks. The system separates responsibilities into multiple modules including the proposal system, authorization module, timelock engine, and reward distribution module. This modular architecture helps isolate critical logic and reduces the likelihood that a single bug could compromise the entire treasury.

This document explains the major attack surfaces of the protocol, how the design mitigates these risks, and the remaining risks that governance must monitor.

---

# 1. Reentrancy

## Attack Surface

Reentrancy occurs when a contract makes an external call and the receiving contract calls back into the original contract before execution is finished.

For example, a malicious contract could try to repeatedly trigger treasury execution during a transfer.

Example of a dangerous pattern:

```
target.call{value: amount}(data);
state = EXECUTED;
```

In this scenario the external call happens before updating the contract state, allowing the attacker to reenter the function and execute it multiple times.

## Mitigation

The ARES treasury follows the **checks → effects → interactions** pattern.

State changes occur before any external call.

```
p.state = State.EXECUTED;

(bool ok,) = p.target.call{value: p.value}(p.data);
require(ok);
```

Because the proposal state is updated before the external call, any reentrant attempt will fail the state validation check.

## Remaining Risk

If future modules introduce new external calls without updating state first, reentrancy vulnerabilities could appear. All future upgrades should maintain the same interaction order.

---

# 2. Signature Replay

## Attack Surface

Signature replay attacks occur when a valid cryptographic signature is reused to authorize multiple actions.

For example, a signer might approve proposal #5, but an attacker reuses the same signature to approve another proposal.

Example vulnerable design:

```
verify(signature)
execute(proposal)
```

Without replay protection the signature could be reused indefinitely.

## Mitigation

The ARES protocol uses **nonces** for each signer.

```
mapping(address => uint256) public nonces;
```

Every time a signature is used, the nonce increments.

```
nonces[signer]++;
```

The message that signers approve includes:

```
keccak256(
  abi.encode(
    proposalId,
    block.chainid,
    address(this),
    nonce
  )
)
```

This prevents:

- signature replay
- cross-chain replay
- domain collision

Because the nonce changes after each use, the same signature cannot be reused.

## Remaining Risk

If the nonce is not included in future message formats or if signature verification logic changes, replay protection could break. Governance should carefully review any modifications to the authorization module.

---

# 3. Double Claim

## Attack Surface

The reward distribution system allows contributors to claim tokens using a Merkle proof. Without proper tracking, a user could submit multiple claims for the same reward.

Example attack:

```
claim(100 tokens)
claim(100 tokens again)
```

If the system does not track claims, the attacker could drain the reward pool.

## Mitigation

The protocol stores a record of which addresses have claimed rewards.

```
mapping(address => bool) public claimed;
```

Before transferring tokens, the contract checks:

```
require(!claimed[msg.sender], "claimed");
```

Once a claim is processed, the address is marked as claimed.

```
claimed[msg.sender] = true;
```

This ensures that each address can claim rewards only once per distribution root.

## Remaining Risk

If the protocol upgrades the reward system or resets claim mappings incorrectly during root updates, users might gain the ability to claim multiple times. Proper migration procedures must be used during root changes.

---

# 4. Unauthorized Execution

## Attack Surface

An attacker might attempt to execute a treasury proposal without proper approval.

Example attack:

```
execute(proposalId)
```

Even though governance never approved the action.

Without verification checks this could allow unauthorized treasury transfers.

## Mitigation

The ARES treasury verifies proposal state before execution.

```
require(p.state == State.APPROVED, "not approved");
require(ready(proposalId), "not ready");
```

Execution requires two conditions:

1. The proposal must be approved by governance
2. The timelock delay must have passed

If either condition fails the transaction reverts.

## Remaining Risk

If governance modules are upgraded incorrectly or proposal states are modified outside expected flows, execution checks could be bypassed. Strict state transitions must be maintained.

---

# 5. Timelock Bypass

## Attack Surface

Timelocks prevent governance actions from executing immediately. Attackers may attempt to bypass the delay by executing proposals before the waiting period finishes.

Example attack:

```
propose
approve
execute immediately
```

Without delay enforcement the treasury could be drained instantly.

## Mitigation

ARES uses a queue-based execution system.

When a proposal is queued the execution time is recorded.

```
executionTime[proposalId] = block.timestamp + delay;
```

Execution is only allowed after the delay passes.

```
require(block.timestamp >= executionTime[proposalId]);
```

This delay gives the community time to review governance actions before they are executed.

## Remaining Risk

Timestamp manipulation by miners is theoretically possible but limited to a small range. Because the delay is measured in hours or days, small timestamp variations do not meaningfully affect the system.

---

# 6. Governance Griefing

## Attack Surface

Governance griefing occurs when attackers abuse governance mechanics to disrupt protocol operations.

Examples include:

- flash-loan governance manipulation
- treasury draining proposals
- proposal spam attacks

These attacks do not always steal funds directly but can destabilize governance.

## Mitigation

ARES implements two defensive mechanisms.

### Commit Phase Delay

Proposals cannot be approved immediately after creation.

```
require(block.timestamp >= p.createdAt + 1 hours);
```

This delay prevents flash-loan attackers from proposing and approving malicious actions within a single transaction.

### Treasury Drain Limiter

The treasury restricts how much value can be transferred in a single proposal.

```
uint256 maxDrain = address(this).balance / 10;
require(p.value <= maxDrain);
```

This ensures that no single governance proposal can drain the entire treasury.

## Remaining Risk

Attackers may still attempt governance spam by submitting many proposals. Rate-limiting or proposal deposits could be introduced in future upgrades to further reduce this risk.

---

# Conclusion

The ARES treasury architecture combines multiple security layers including signature verification, nonce management, timelock enforcement, Merkle proof validation, and treasury withdrawal limits. These mechanisms significantly reduce the risk of common governance and smart contract attacks.

However, smart contract security is an ongoing process. Future upgrades and governance decisions must continue to follow secure design principles to maintain the safety of the protocol treasury.
