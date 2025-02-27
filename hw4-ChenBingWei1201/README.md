[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/76QeiOs7)
# 2024-Fall-DeFi-HW4

## Question 1
> Please explain the inner workings of ZK Rollups and Optimistic Rollups and compare the differences between these rollup structures. Additionally, explain the differences between ZK Rollups, Volition, and Validium modes. (5 pt)

- ZK Rollups:
  ZK Rollups bundle multiple transactions into a single proof, known as a validity proof, and submit it to the Ethereum mainnet. Key properties include: validity proofs, immediate finality, and efficient state update. First, ZK Rollups use cryptographic proofs to validate transactions. Second, since validity proofs are verified on-chain, transactions are final once submitted. Last, only updated state and proofs are sent to Ethereum, reducing data and gas usage.

- Optimistic Rollups:
  Optimistic Rollups assume transactions are valid by default. They rely on fraud proofs to identify and challenge invalid transactions. Fraud Proofs: Users can challenge potentially fraudulent transactions during a dispute window (usually 1–2 weeks) and transactions are finalized after the dispute window ends. Additionally, Optimistic Rollups offload computation off-chain but may incur higher gas fees if fraud proofs are triggered.

- Compare
  | Feature	| ZK Rollups	| Optimistic Rollups |
  | :-----: | :------: | :----: |
  | Proof Mechanism |	Validity Proofs	| Fraud Proofs |
  | Finality |	Immediate | Delayed (dispute period) |
  | Cost Efficiency	| Higher initial cost, lower gas | Lower initial cost, higher gas |
  | Throughput	| Higher	| Lower |
  | Use Cases	| Payments, DeFi | General-purpose computation |

- The differences between ZK Rollups, Volition, and Validium modes
  - ZK Rollups: Store transaction data on-chain and use validity proofs.
  - Volition: A hybrid mode allowing users to choose between on-chain and off-chain data storage for their transactions.
  - Validium: Keeps transaction data off-chain, relying entirely on validity proofs for security.

## Question 2
> According to L2 Beat, there are multiple stages for a Layer 2. What are the criteria for each stage, and what is the current status of the Layer 2 solutions in use? (5pt)

- The criteria for each stage:
  - Stage 0 — Full Training Wheels: At this initial stage, the rollup is predominantly operated by its developers or a centralized entity. While the software may be open-source, allowing for state reconstruction from data posted on Layer 1 (L1), the system lacks decentralized governance and relies heavily on centralized control.
  - Stage 1 — Limited Training Wheels: In this intermediate stage, governance transitions to smart contracts, introducing a degree of decentralization. A Security Council may exist to address potential bugs, serving as a safety net. Key characteristics of this stage include:
    - Implementation of a fully functional proof system.
    - Decentralization of fraud proof submission.
    - Provision for user exits without requiring operator coordination.
  
  However, the Security Council's power, while providing safety, also introduces potential risks due to its centralized nature.
  - Stage 2 — No Training Wheels: At this final stage, the rollup operates entirely through smart contracts without centralized oversight. Features of this stage include:
    - A permissionless fraud proof system.
    - Adequate time for users to exit in case of unwanted upgrades.
    - A Security Council whose role is strictly limited to addressing on-chain provable bugs, ensuring users are protected from governance attacks.

- Current status:
  - Arbitrum One: Classified as Stage 1, indicating it has limited training wheels with certain decentralization features in place.
  - OP Mainnet (Optimism): Currently at Stage 0, suggesting it still operates with full training wheels and relies on centralized control.
  - zkSync Era: Also at Stage 0, indicating full training wheels are in place.

## Question 3
> Layer 2 solutions aim to address scaling issues in the Ethereum ecosystem, but they introduce liquidity fragmentation, which leads to interoperability challenges. Cross-chain bridges can help address these issues. Modern cross-chain bridges can be categorized into burn-and-mint, lock-and-mint, and lock-and-unlock mechanisms. Please analyze two cross-chain bridge structures (e.g., LayerZero, Wormhole and more) with distinct underlying mechanisms. (5 pt)

- LayerZero
  - Uses relayers and oracles to transmit messages.
  - Combines off-chain data verification with on-chain proofs.
  - Mechanism:
    - Message is relayed off-chain, verified by an oracle, and processed on the target chain.
    - Benefits: Decentralized and modular; secure with redundancy in verification.

- Wormhole
  - Uses guardians (a federation of nodes) for consensus on cross-chain events.
  - Mechanism:
    - Assets are locked on the source chain and minted as wrapped tokens on the target chain.
    - Guardians sign transactions to validate cross-chain transfers.
    - Benefits: Fast but partially decentralized; vulnerable to guardian compromise.

- Compare
  | Feature	| LayerZero	| Wormhole |
  | :-----: | :------: | :----: |
  | Mechanism	| Messaging with burn-and-mint | Lock-and-mint with guardian consensus |
  | Trust Model	| Decentralized oracles and relayers | 	Guardian-based consensus |
  | Risks	| Oracle/relayer collusion | Guardian collusion |

## Question 4
> Cross-chain bridges have suffered significant losses due to security breaches. For example, in 2021, PolyNetwork experienced a $611 million exploit, BNB Bridge faced a $586 million exploit, and Wormhole was attacked for $326 million. Please analyze the vulnerabilities in a cross-chain bridge structure, providing code examples to illustrate the issues. (5 pt)

1. Centralized Validators
  - Some bridges rely on a set of validators or a single entity to validate and approve transactions across chains. If these validators are compromised or act maliciously, the bridge can be exploited.
  - Example Issue: Validators can incorrectly approve invalid transactions.
  ```solidity
  contract Bridge {
      mapping(uint256 => bool) public processedNonces;

      function transfer(uint256 amount, uint256 nonce, bytes memory signature) public {
          require(!processedNonces[nonce], "Nonce already processed");
          processedNonces[nonce] = true;

          bytes32 message = keccak256(abi.encodePacked(msg.sender, amount, nonce));
          require(verifySignature(message, signature), "Invalid signature");

          // Logic to release tokens on the destination chain
      }

      function verifySignature(bytes32 message, bytes memory signature) internal view returns (bool) {
          address signer = recoverSigner(message, signature);
          return signer == trustedValidator; // Single point of failure
      }
  }
  ```
  Vulnerability: If the private key of `trustedValidator` is compromised, attackers can forge signatures to steal funds.

2. Replay Attacks
  - Reusing transaction data across chains without appropriate validation can lead to replay attacks, where the same transaction is executed multiple times.
  ```solidity
  function transfer(uint256 amount, uint256 nonce) public {
      require(!processedNonces[nonce], "Nonce already processed");
      processedNonces[nonce] = true;

    // Logic to execute transfer
  }
  ```
  Vulnerability: If `processedNonces` is not synchronized across chains or improperly implemented, attackers can replay transactions to double-spend tokens.

3. Smart Contract Bugs
  - Bridges often involve complex smart contracts that interact with multiple chains. Bugs in these contracts can expose vulnerabilities.
  ```solidity
  contract Bridge {
    function deposit(address token, uint256 amount) public {
        require(amount > 0, "Invalid amount");
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Issue a receipt or execute cross-chain logic
    }

    function withdraw(address token, uint256 amount) public {
        require(amount > 0, "Invalid amount");
        require(balance[msg.sender][token] >= amount, "Insufficient balance");
        
        IERC20(token).transfer(msg.sender, amount);
        balance[msg.sender][token] -= amount; // Reentrancy vulnerability
    }
  }
  ```
  Vulnerability: If the token contract used in the bridge allows reentrant calls, an attacker can exploit this to drain funds.

4. Lack of Proper Validation
  - Bridges may fail to validate incoming data properly, such as incorrectly handling proofs or messages.
  ```solidity
  function validateProof(bytes memory proof) public returns (bool) {
      // Simplistic proof validation
      return keccak256(proof) == expectedHash;
  }
  ```
  Vulnerability: If expectedHash is derived insecurely or the proof validation logic is flawed, attackers can forge proofs to manipulate the bridge.

## Question 5
> User experience is key to the mass adoption of blockchain. Currently, intent-based solutions are popular. What is an intent, and how does it differ from a cross-chain bridge? (5 pt)

- Intent:
  - Represents a user's desired action (e.g., swapping tokens, transferring assets) rather than specifying exact execution paths.
  - Managed by off-chain protocols or wallets that translate intents into transactions.

- Differences
  | Aspect | Intent	| Cross-Chain Bridge |
  | :-----: | :------: | :----: |
  | Purpose	| Simplify user actions	| Asset and state transfer |
  | Execution	| Flexible, on-chain or off-chain	| Predetermined,  on-chain |

## Question 6
> The ongoing bull market is marked by an increase in both the number and total losses from phishing scams. Please explain how permit and permit2 work, along with examples of phishing scams related to these operaitons. (5 pt)

- Permit:
  - EIP-2612: Allows token approvals via signatures instead of on-chain transactions.
  - Use Case: Gasless approval for DeFi protocols.
- Permit2:
  - Extension of Permit, enabling batched approvals and shared allowances.
  - Adds flexibility and reduces approval overhead.

- Example:
  1. Attacker creates a fake DApp mimicking a legitimate protocol.
  2. User signs a Permit transaction, unknowingly granting token transfer rights.
  3. Attacker drains tokens using the signed Permit.