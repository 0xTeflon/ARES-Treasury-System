# Ares Treasury Architecture

This is how the treasury system works. We built it to move money safely and not get hacked like other protocols. We try to stop things like flash loan attacks or people stealing the governance.

Instead of one giant file, we broke it into smaller pieces (modules). This makes the code easier to read and hopefully less bugs.

### Folder Structure

Our code is organized like this in the `src` folder:

- **interfaces/** - simple definitions
- **libraries/** - helper code
- **modules/** - the main logic parts
- - **script/** - deployment script
- **core/** - the heart of the treasury

## How the System Works

The main contract is `AresTreasury.sol`. It does the actual sending of money but it doesn't do it alone. It inherits from `ProposalModule` and `TimelockModule` to make sure everything is checked first.

**The basic flow for a transaction:**

1. Someone creates a "proposal" in the proposal module.
2. It waits in a "commit" phase (no skipping this!).
3. The people in charge (signers) sign off on it.
4. It goes into a Timelock queue to wait some more.
5. Finally, the treasury contract executes the move.

This way, nothing happens instantly and people have time to look at it.

---

## The Modules

### ProposalModule

This handles the life of a proposal. It saves where the money is going and how much. We added a "commit phase" so nobody can just spam an approval and take money in one block. It also counts how many signatures we got.

### AuthorizationModule

This checks if the signatures are real. We use a "nonce" for every signer so they cant reuse the same signature twice (replay attack). We also check the Chain ID so a signature on a testnet doesnt work on mainnet.

### TimelockModule

This is just a big timer. After a proposal is approved, it has to sit here for a few days. If someone tries to do something bad, the community can see it coming and react before the timer ends. Without this, a hacked goverance could drain everything in 1 second.

### RewardDistributor

We use a Merkle Root for rewards. Instead of the contract sending tokens to 1000 people (which is too expensive for gas), we just put a root on-chain. Users come and "claim" their own tokens by showing a proof. It's much cheaper.

### SignatureVerifier Library

Just a small helper to find who signed a message. Kept it seperate to keep things clean.

## Security stuff

Each part has its own job. The proposal module checks the "what", the auth module checks the "who", and the timelock checks the "when". The main `AresTreasury` contract is the final boss—it checks everything one last time before it actually sends any crypto out.

## Things we assume (Trust)

- We assume the signers keep their private keys safe.
- We assume the Merkle root we upload is actually correct.
- We assume the timelock is long enough for people to complain if something looks fishy.

We tried to keep it simple so it's easy to audit.
