## 📌 Storage of Structs, Mappings, and Arrays in Solidity

- **Structs** are stored in **contract storage** when they are part of state variables (e.g., inside arrays or mappings declared at the contract level).
- **Arrays** declared as state variables are also stored in **storage** permanently on the blockchain.
- **Mappings** are always stored in **storage** because they represent persistent key-value data tied to the contract state.

Since blockchain storage is permanent, any data saved in these structures remains available between transactions unless explicitly modified.

---

## ⚙️ Behavior When Executed or Called

- When a function **reads** from structs, arrays, or mappings, it fetches the data from storage into memory temporarily for execution.
- When a function **modifies** them, the changes are written back to storage, which costs gas because blockchain state is being updated.
- Arrays allow iteration (loops), while mappings do **not** support iteration directly because they do not store keys — only hashed references.
- Structs act as grouped data containers, making it easier to manage related properties together.

Example behavior:
- Adding a student → updates the storage array
- Updating attendance → modifies a struct stored in storage
- Reading student data → copies data into memory for execution

---

## ❓ Why You Don’t Need to Specify `memory` or `storage` for Mappings

Mappings are **only allowed in storage** in Solidity.

This means:

- You **cannot** create mappings in memory.
- You **cannot** pass mappings as memory variables.
- Solidity automatically treats mappings as storage references.

Because there is no alternative location (like memory or calldata), the compiler does not require you to specify a data location.

Example:

```solidity
mapping(address => uint256) public balances;