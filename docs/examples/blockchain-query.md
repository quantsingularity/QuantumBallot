# Example: Blockchain Query Operations

This example demonstrates how to query and explore the QuantumBallot blockchain.

---

## Overview

This example shows:

1. Querying blockchain data
2. Exploring blocks and transactions
3. Verifying blockchain integrity
4. Analyzing election results
5. Building a simple blockchain explorer

**Technologies**: Backend API, command-line curl, TypeScript

---

## Prerequisites

- Backend running at `http://localhost:3000`
- Active election with some votes cast
- curl or HTTPie installed

---

## Query 1: Get Complete Blockchain

### Using curl

```bash
curl http://localhost:3000/api/blockchain/chain | jq
```

### Using TypeScript

```typescript
import axios from "axios";

async function getBlockchain() {
  const response = await axios.get(
    "http://localhost:3000/api/blockchain/chain",
  );
  return response.data.data;
}

// Usage
const blockchain = await getBlockchain();
console.log(`Blockchain has ${blockchain.chain.length} blocks`);
```

### Response Structure

```json
{
  "success": true,
  "data": {
    "chain": [
      {
        "blockIndex": 0,
        "blockHeader": {
          "timestamp": 1640000000,
          "previousBlockHash": "0",
          "blockHash": "genesis_block_hash",
          "nonce": 0
        },
        "transactions": []
      },
      {
        "blockIndex": 1,
        "blockHeader": {
          "timestamp": 1640001234,
          "previousBlockHash": "genesis_block_hash",
          "blockHash": "block1_hash",
          "nonce": 12345
        },
        "transactions": [...]
      }
    ]
  }
}
```

---

## Query 2: Get All Blocks (Summary)

Get a simplified list of all blocks.

### Using curl

```bash
curl http://localhost:3000/api/blockchain/blocks | jq
```

### TypeScript Implementation

```typescript
interface BlockSummary {
  blockIndex: number;
  timestamp: number;
  hash: string;
  previousHash: string;
  transactionCount: number;
}

async function getBlocks(): Promise<BlockSummary[]> {
  const response = await axios.get(
    "http://localhost:3000/api/blockchain/blocks",
  );
  return response.data.data;
}

// Usage
const blocks = await getBlocks();
blocks.forEach((block) => {
  console.log(`Block ${block.blockIndex}: ${block.transactionCount} votes`);
});
```

---

## Query 3: Get Specific Block Details

Retrieve detailed information about a specific block by its hash.

### Using curl

```bash
BLOCK_HASH="0a1b2c3d4e5f6789..."
curl "http://localhost:3000/api/blockchain/block-detail/$BLOCK_HASH" | jq
```

### TypeScript Implementation

```typescript
interface Block {
  blockIndex: number;
  blockHeader: {
    timestamp: number;
    previousBlockHash: string;
    blockHash: string;
    nonce: number;
  };
  transactions: Transaction[];
}

async function getBlockDetails(blockHash: string): Promise<Block> {
  const response = await axios.get(
    `http://localhost:3000/api/blockchain/block-detail/${blockHash}`,
  );
  return response.data.data;
}

// Usage
const blockHash = "0a1b2c3d...";
const block = await getBlockDetails(blockHash);

console.log(`Block ${block.blockIndex}`);
console.log(`Timestamp: ${new Date(block.blockHeader.timestamp * 1000)}`);
console.log(`Nonce: ${block.blockHeader.nonce}`);
console.log(`Transactions: ${block.transactions.length}`);
```

---

## Query 4: Get All Transactions

Get all confirmed transactions (votes) from the blockchain.

### Using curl

```bash
curl http://localhost:3000/api/blockchain/transactions | jq
```

### TypeScript Implementation

```typescript
interface Transaction {
  transactionId: string;
  blockIndex: number;
  timestamp: number;
  data: {
    identifier: string; // Encrypted
    vote: string; // Encrypted
    timestamp: number;
  };
}

async function getAllTransactions(): Promise<Transaction[]> {
  const response = await axios.get(
    "http://localhost:3000/api/blockchain/transactions",
  );
  return response.data.data;
}

// Usage - Count votes per block
const transactions = await getAllTransactions();
const votesByBlock = transactions.reduce(
  (acc, tx) => {
    acc[tx.blockIndex] = (acc[tx.blockIndex] || 0) + 1;
    return acc;
  },
  {} as Record<number, number>,
);

console.log("Votes per block:", votesByBlock);
```

---

## Query 5: Get Pending Transactions

Get transactions that haven't been mined into a block yet.

### Using curl

```bash
curl http://localhost:3000/api/blockchain/pending-transactions | jq
```

### TypeScript Implementation

```typescript
async function getPendingTransactions() {
  const response = await axios.get(
    "http://localhost:3000/api/blockchain/pending-transactions",
  );
  return response.data.data;
}

// Usage
const pending = await getPendingTransactions();
console.log(`${pending.length} votes waiting to be mined`);
```

---

## Query 6: Get Election Results

Get computed election results with vote counts and percentages.

### Using curl

```bash
# Requires authentication
curl http://localhost:3000/api/blockchain/get-results-computed | jq
```

### TypeScript Implementation

```typescript
interface CandidateResult {
  candidateCode: number;
  candidateName: string;
  votes: number;
  percentage: number;
}

interface ElectionResults {
  totalVotes: number;
  results: CandidateResult[];
}

async function getElectionResults(): Promise<ElectionResults> {
  const response = await axios.get(
    "http://localhost:3000/api/blockchain/get-results-computed",
  );
  return response.data.data;
}

// Usage
const results = await getElectionResults();
console.log(`Total votes: ${results.totalVotes}`);
console.log("\nResults:");
results.results
  .sort((a, b) => b.votes - a.votes)
  .forEach((r, index) => {
    console.log(
      `${index + 1}. ${r.candidateName}: ${r.votes} (${r.percentage}%)`,
    );
  });
```

---

## Advanced Queries

### Query 7: Verify Blockchain Integrity

Verify that the blockchain is valid and hasn't been tampered with.

```typescript
import * as CryptoJS from "crypto-js";
import sha256 from "crypto-js/sha256";

async function verifyBlockchainIntegrity(): Promise<boolean> {
  const blockchain = await getBlockchain();
  const { chain } = blockchain;

  for (let i = 1; i < chain.length; i++) {
    const currentBlock = chain[i];
    const previousBlock = chain[i - 1];

    // 1. Verify previous hash link
    if (
      currentBlock.blockHeader.previousBlockHash !==
      previousBlock.blockHeader.blockHash
    ) {
      console.error(`Block ${i}: Previous hash mismatch`);
      return false;
    }

    // 2. Verify block hash
    const computedHash = calculateBlockHash(currentBlock);
    if (currentBlock.blockHeader.blockHash !== computedHash) {
      console.error(`Block ${i}: Hash mismatch`);
      return false;
    }

    // 3. Verify proof of work
    if (!currentBlock.blockHeader.blockHash.startsWith("0000")) {
      console.error(`Block ${i}: Invalid proof of work`);
      return false;
    }
  }

  console.log("✓ Blockchain integrity verified");
  return true;
}

function calculateBlockHash(block: Block): string {
  const data = JSON.stringify({
    blockIndex: block.blockIndex,
    timestamp: block.blockHeader.timestamp,
    previousBlockHash: block.blockHeader.previousBlockHash,
    transactions: block.transactions,
    nonce: block.blockHeader.nonce,
  });
  return sha256(data).toString();
}

// Usage
const isValid = await verifyBlockchainIntegrity();
```

### Query 8: Analyze Voting Patterns

Analyze voting patterns over time.

```typescript
async function analyzeVotingPatterns() {
  const transactions = await getAllTransactions();

  // Votes per hour
  const votesByHour = transactions.reduce(
    (acc, tx) => {
      const hour = new Date(tx.timestamp * 1000).getHours();
      acc[hour] = (acc[hour] || 0) + 1;
      return acc;
    },
    {} as Record<number, number>,
  );

  // Votes per day
  const votesByDay = transactions.reduce(
    (acc, tx) => {
      const day = new Date(tx.timestamp * 1000).toDateString();
      acc[day] = (acc[day] || 0) + 1;
      return acc;
    },
    {} as Record<string, number>,
  );

  // Average votes per block
  const blocks = await getBlocks();
  const avgVotesPerBlock = transactions.length / blocks.length;

  return {
    votesByHour,
    votesByDay,
    avgVotesPerBlock,
    totalVotes: transactions.length,
    totalBlocks: blocks.length,
  };
}

// Usage
const analysis = await analyzeVotingPatterns();
console.log("Voting Pattern Analysis:");
console.log(`Total votes: ${analysis.totalVotes}`);
console.log(`Total blocks: ${analysis.totalBlocks}`);
console.log(`Avg votes/block: ${analysis.avgVotesPerBlock.toFixed(2)}`);
console.log("\nVotes by hour:", analysis.votesByHour);
```

### Query 9: Search for Specific Vote

Search for a specific vote by transaction ID.

```typescript
async function findVoteByTransactionId(txId: string) {
  const transactions = await getAllTransactions();
  return transactions.find((tx) => tx.transactionId === txId);
}

// Usage
const txId = "tx_abc123...";
const vote = await findVoteByTransactionId(txId);

if (vote) {
  console.log(`Vote found in block ${vote.blockIndex}`);
  console.log(`Timestamp: ${new Date(vote.timestamp * 1000)}`);
} else {
  console.log("Vote not found");
}
```

---

## Building a Simple Blockchain Explorer

Complete example of a blockchain explorer CLI tool.

```typescript
#!/usr/bin/env node
// scripts/blockchain-explorer.ts

import axios from "axios";
import { Command } from "commander";

const API_URL = "http://localhost:3000/api";
const program = new Command();

program
  .name("blockchain-explorer")
  .description("QuantumBallot Blockchain Explorer CLI")
  .version("1.0.0");

// Command: List all blocks
program
  .command("blocks")
  .description("List all blocks")
  .action(async () => {
    const response = await axios.get(`${API_URL}/blockchain/blocks`);
    const blocks = response.data.data;

    console.log(`Total blocks: ${blocks.length}\n`);
    blocks.forEach((block: any) => {
      console.log(`Block ${block.blockIndex}`);
      console.log(`  Hash: ${block.hash.substring(0, 16)}...`);
      console.log(`  Transactions: ${block.transactionCount}`);
      console.log(
        `  Timestamp: ${new Date(block.timestamp * 1000).toLocaleString()}`,
      );
      console.log("");
    });
  });

// Command: Get block details
program
  .command("block <hash>")
  .description("Get detailed information about a block")
  .action(async (hash: string) => {
    const response = await axios.get(
      `${API_URL}/blockchain/block-detail/${hash}`,
    );
    const block = response.data.data;

    console.log(`Block ${block.blockIndex}`);
    console.log(`Hash: ${block.blockHeader.blockHash}`);
    console.log(`Previous: ${block.blockHeader.previousBlockHash}`);
    console.log(`Nonce: ${block.blockHeader.nonce}`);
    console.log(
      `Timestamp: ${new Date(block.blockHeader.timestamp * 1000).toLocaleString()}`,
    );
    console.log(`\nTransactions: ${block.transactions.length}`);
  });

// Command: Get results
program
  .command("results")
  .description("Get election results")
  .action(async () => {
    const response = await axios.get(
      `${API_URL}/blockchain/get-results-computed`,
    );
    const { totalVotes, results } = response.data.data;

    console.log(`Total votes: ${totalVotes}\n`);
    console.log("Results:");
    results
      .sort((a: any, b: any) => b.votes - a.votes)
      .forEach((r: any, i: number) => {
        console.log(`${i + 1}. ${r.candidateName}`);
        console.log(`   Votes: ${r.votes} (${r.percentage.toFixed(2)}%)`);
      });
  });

// Command: Verify integrity
program
  .command("verify")
  .description("Verify blockchain integrity")
  .action(async () => {
    console.log("Verifying blockchain integrity...");
    const isValid = await verifyBlockchainIntegrity();
    console.log(isValid ? "✓ Valid" : "✗ Invalid");
  });

// Command: Stats
program
  .command("stats")
  .description("Show blockchain statistics")
  .action(async () => {
    const [blocksRes, txRes] = await Promise.all([
      axios.get(`${API_URL}/blockchain/blocks`),
      axios.get(`${API_URL}/blockchain/transactions`),
    ]);

    const blocks = blocksRes.data.data;
    const transactions = txRes.data.data;

    console.log("Blockchain Statistics:");
    console.log(`Total blocks: ${blocks.length}`);
    console.log(`Total transactions: ${transactions.length}`);
    console.log(
      `Avg transactions/block: ${(transactions.length / blocks.length).toFixed(2)}`,
    );

    if (blocks.length > 1) {
      const firstBlock = blocks[1]; // Skip genesis
      const lastBlock = blocks[blocks.length - 1];
      const timeSpan = lastBlock.timestamp - firstBlock.timestamp;
      const avgBlockTime = timeSpan / (blocks.length - 1);
      console.log(`Avg block time: ${avgBlockTime.toFixed(2)}s`);
    }
  });

program.parse();
```

### Usage

```bash
# Build and run
npx ts-node scripts/blockchain-explorer.ts

# List all blocks
./blockchain-explorer blocks

# Get block details
./blockchain-explorer block 0a1b2c3d...

# Get election results
./blockchain-explorer results

# Verify blockchain
./blockchain-explorer verify

# Show statistics
./blockchain-explorer stats
```

---

## Real-world Use Cases

### Use Case 1: Audit Trail

Export complete audit trail of all votes:

```typescript
async function exportAuditTrail() {
  const blockchain = await getBlockchain();
  const auditTrail = [];

  for (const block of blockchain.chain) {
    for (const tx of block.transactions) {
      auditTrail.push({
        blockIndex: block.blockIndex,
        blockHash: block.blockHeader.blockHash,
        timestamp: new Date(block.blockHeader.timestamp * 1000).toISOString(),
        transactionId: tx.transactionId,
        // Note: actual vote data is encrypted
        voteData: tx.data,
      });
    }
  }

  return auditTrail;
}

// Export to JSON
const audit = await exportAuditTrail();
console.log(JSON.stringify(audit, null, 2));
```

### Use Case 2: Real-time Monitoring

Monitor blockchain for new blocks and transactions:

```typescript
import { io } from "socket.io-client";

function monitorBlockchain() {
  const socket = io("http://localhost:3000");

  socket.on("connect", () => {
    console.log("Connected to blockchain monitor");
  });

  socket.on("newBlock", async (data: any) => {
    console.log(`\n🔗 New block mined: ${data.blockIndex}`);
    const block = await getBlockDetails(data.blockHash);
    console.log(`   Transactions: ${block.transactions.length}`);
    console.log(`   Hash: ${data.blockHash.substring(0, 16)}...`);
  });

  socket.on("newVote", (data: any) => {
    console.log(
      `\n🗳️  New vote received: ${data.transactionId.substring(0, 10)}...`,
    );
  });
}

// Start monitoring
monitorBlockchain();
```

---

## Next Steps

- See [voting-flow.md](voting-flow.md) for voter experience
- See [election-setup.md](election-setup.md) for election configuration
- See [API.md](../API.md) for complete API reference

---

_This example is part of the QuantumBallot documentation. For more examples, see [examples/](../examples/)._
