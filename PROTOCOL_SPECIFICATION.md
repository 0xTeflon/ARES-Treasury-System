# PROTOCOL_SPECIFICATION.md

## Protocol Lifecycle Specification

This document explains how the ARES treasury protocol works step by step. The protocol is designed to prevent treasury actions from occurring instantly. Instead, every action must go through a process of proposal, approval, queueing, and execution. This helps protect the treasury from malicious governance actions.

The lifecycle of a treasury action is described below.

---

## 1. Proposal Creation

The first step in the protocol is creating a proposal.

A governance participant calls the `propose()` function in the **ProposalModule**. This function creates a new proposal and stores it in the proposal mapping.

Each proposal contains the following information:

- target contract address
- value (ETH amount)
- calldata (function call data)
- proposal state
- number of approvals

The proposal state is initially set to:

```text
PROPOSED
```

At this stage, the proposal cannot be executed yet. It must first pass through governance approval.

The proposal module also enforces a **delay before committing**. This means that approvals cannot happen immediately after proposal creation. The system requires a short waiting period before approval can start.

This design helps reduce flash-loan governance manipulation.

---

## 2. Proposal Approval

After the commit phase has passed, governance signers can approve the proposal.

The approval is done by calling the `approve()` function. The contract tracks how many approvals the proposal receives.

Each approval increases the proposal approval counter.

When the number of approvals reaches the required threshold, the proposal state changes from:

```text
PROPOSED → APPROVED
```

The authorization module verifies that the signer is allowed to approve proposals. It also uses nonce tracking to prevent signature replay attacks.

Without sufficient approvals, the proposal cannot move forward in the lifecycle.

---

## 3. Proposal Queueing

Once a proposal is approved, it must be placed into the timelock queue.

This is done using the `queue()` function from the **TimelockModule**.

The queue function records the time when the proposal becomes executable.

Example:

```text
executionTime = current time + delay
```

The proposal is now waiting in the queue.

During this stage, the proposal cannot be executed yet. The system must wait until the configured delay period has passed.

This delay provides time for the community to review the proposal and react if the action is malicious.

---

## 4. Proposal Execution

After the timelock delay expires, the proposal becomes executable.

Any user can trigger execution by calling the `execute()` function in the **AresTreasury** contract.

Before executing the transaction, the contract performs several checks:

- The proposal must be approved
- The timelock delay must be finished
- The proposal must not have been executed already
- The transaction must not exceed the treasury drain limit

If all checks pass, the treasury executes the transaction using a low-level call to the target contract.

After execution, the proposal state becomes:

```text
EXECUTED
```

Once executed, the proposal cannot be executed again.

---

## 5. Proposal Cancellation

In some situations, governance may need to cancel a proposal before it is executed. For example, a proposal may be discovered to be malicious or incorrect.

A proposal can be cancelled by governance before execution if it has not yet reached the final execution stage.

When a proposal is cancelled, its state is updated, and the proposal can no longer be executed.

This prevents unsafe or malicious treasury actions from being completed.

---

## Summary

The full lifecycle of a treasury action in the ARES protocol follows this sequence:

```text
proposal created
      ↓
commit phase delay
      ↓
governance approval
      ↓
timelock queue
      ↓
execution delay
      ↓
treasury execution
```

This structured lifecycle ensures that treasury operations cannot happen instantly and must go through multiple verification steps before funds are moved.
