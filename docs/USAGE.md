# Usage Guide

Complete guide to using QuantumBallot for election management and voting.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Backend API Usage](#backend-api-usage)
3. [Web Frontend Usage](#web-frontend-usage)
4. [Mobile Frontend Usage](#mobile-frontend-usage)
5. [Common Workflows](#common-workflows)
6. [Library Usage](#library-usage)

---

## Quick Start

### Starting the System

```bash
# Terminal 1: Start backend
cd backend
npm run dev

# Terminal 2: Start web frontend
cd web-frontend
npm run dev

# Terminal 3: Start mobile frontend (optional)
cd mobile-frontend
npm start
```

### Access Points

- **Backend API**: http://localhost:3000
- **Web Dashboard**: http://localhost:5173
- **Mobile App**: Expo Go app (scan QR code)
- **API Health**: http://localhost:3000/health

---

## Backend API Usage

### Starting the Backend

```bash
# Development mode (auto-reload)
npm run dev

# Production build
npm run build
npm start

# Run tests
npm test

# Watch tests
npm run test:watch
```

### Basic API Interaction

```bash
# Health check
curl http://localhost:3000/health

# Get blockchain status
curl http://localhost:3000/api/blockchain/chain

# Get all blocks
curl http://localhost:3000/api/blockchain/blocks

# Get pending transactions
curl http://localhost:3000/api/blockchain/pending-transactions
```

---

## Web Frontend Usage

### For Election Committee Members

#### 1. Login to Dashboard

```
URL: http://localhost:5173
Credentials: Use committee member account
```

#### 2. Create an Election

**Step-by-step:**

1. Navigate to **Elections** > **Create New**
2. Fill in election details:
   - Election name
   - Start date/time
   - End date/time
   - Description
3. Click **Create Election**

**Example parameters:**

```json
{
  "name": "2025 Presidential Election",
  "startTimeVoting": "2025-11-05T08:00:00Z",
  "endTimeVoting": "2025-11-05T20:00:00Z",
  "dateResults": "2025-11-06T00:00:00Z",
  "numOfCandidates": 4,
  "numOfVoters": 10000
}
```

#### 3. Add Candidates

**Navigate to:** Elections > [Election Name] > Candidates > Add Candidate

**Required fields:**

- Name: Candidate full name
- Party: Political party
- Code: Unique numeric code (e.g., 101, 102, 103)
- Acronym: Party acronym (e.g., DEM, REP)
- Status: Active/Inactive

**Example via API:**

```bash
curl -X POST http://localhost:3000/api/committee/add-candidate \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Smith",
    "party": "Democratic Party",
    "code": 101,
    "acronym": "DEM",
    "status": "active"
  }'
```

#### 4. Generate Voter Identifiers

**Purpose**: Create secure identifiers for registered voters

```bash
# Via API
curl http://localhost:3000/api/committee/generate-identifiers
```

**Web UI**: Navigate to **Voters** > **Generate Identifiers**

This creates cryptographic identifiers for each registered citizen.

#### 5. Deploy Election Announcement

**Web UI**: Elections > [Election Name] > **Deploy Announcement**

**Via API:**

```bash
curl -X POST http://localhost:3000/api/committee/deploy-announcement \
  -H "Content-Type: application/json" \
  -d '{
    "startTimeVoting": "2025-11-05T08:00:00Z",
    "endTimeVoting": "2025-11-05T20:00:00Z",
    "dateResults": "2025-11-06T00:00:00Z",
    "numOfCandidates": 4,
    "numOfVoters": 10000
  }'
```

#### 6. Monitor Voting

**Web UI**: Dashboard > **Real-time Voting**

**Features:**

- Live vote count
- Voter turnout percentage
- Votes per candidate
- Blockchain status
- Geographic distribution

#### 7. View Results

**Web UI**: Elections > [Election Name] > **Results**

**Via API:**

```bash
# Get results
curl http://localhost:3000/api/blockchain/get-results \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Get computed results
curl http://localhost:3000/api/blockchain/get-results-computed
```

---

## Mobile Frontend Usage

### For Voters

#### 1. Download and Install

- iOS: Download Expo Go from App Store
- Android: Download Expo Go from Google Play
- Scan QR code from `expo start` terminal

#### 2. Register/Login

**First-time users:**

1. Open app
2. Tap **Register**
3. Enter electoral ID (provided by election committee)
4. Set up PIN/biometric authentication
5. Verify email with OTP

**Returning users:**

1. Open app
2. Enter credentials
3. Optional: Use biometric authentication

#### 3. View Candidates

**Navigate to:** Home > **Candidates**

**Features:**

- Candidate photos and bios
- Party affiliation
- Campaign platform
- Candidate code (for voting)

#### 4. Cast Vote

**Steps:**

1. **Navigate**: Home > **Vote**
2. **Authenticate**: Enter PIN or use biometric
3. **Select Candidate**: Tap candidate card
4. **Confirm**: Review selection
5. **Submit**: Tap **Submit Vote**
6. **Verify**: Receive confirmation and transaction hash

**Behind the scenes:**

```
User selects candidate → App encrypts vote →
Sends to backend → Added to transaction pool →
Block mined → Vote recorded on blockchain →
Confirmation sent to user
```

#### 5. Verify Vote

**Navigate to:** Profile > **My Vote**

**Information shown:**

- Vote timestamp
- Transaction hash
- Block number
- Verification status

#### 6. QR Code Verification

**Navigate to:** Home > **Verify QR**

**Usage:**

1. Scan QR code (from committee or polling station)
2. App verifies code against blockchain
3. Shows verification result

---

## Common Workflows

### Workflow 1: Complete Election Setup

```bash
# 1. Start backend
cd backend && npm run dev

# 2. Add candidates (repeat for each)
curl -X POST http://localhost:3000/api/committee/add-candidate \
  -H "Content-Type: application/json" \
  -d '{"name":"Candidate A","party":"Party A","code":101,"acronym":"PA","status":"active"}'

# 3. Generate voter identifiers
curl http://localhost:3000/api/committee/generate-identifiers

# 4. Deploy announcement
curl -X POST http://localhost:3000/api/committee/deploy-announcement \
  -H "Content-Type: application/json" \
  -d '{
    "startTimeVoting":"2025-11-05T08:00:00Z",
    "endTimeVoting":"2025-11-05T20:00:00Z",
    "dateResults":"2025-11-06T00:00:00Z",
    "numOfCandidates":3,
    "numOfVoters":1000
  }'

# 5. Verify setup
curl http://localhost:3000/api/committee/candidates
curl http://localhost:3000/api/committee/announcement
```

### Workflow 2: Voter Registration and Voting

```javascript
// Mobile App Flow (pseudocode)

// 1. Register voter
await registerVoter({
  electoralId: "ABC123456",
  pin: "1234",
  email: "voter@example.com",
});

// 2. Login
await login({
  electoralId: "ABC123456",
  pin: "1234",
});

// 3. Fetch candidates
const candidates = await getCandidates();

// 4. Cast vote
await castVote({
  identifier: "ABC123456",
  choiceCode: 101, // Candidate code
});

// 5. Verify vote
const voteStatus = await getVoteStatus("ABC123456");
```

### Workflow 3: Blockchain Query

```bash
# Get entire blockchain
curl http://localhost:3000/api/blockchain/chain

# Get specific block details
BLOCK_HASH="0a1b2c3d4e5f..."
curl http://localhost:3000/api/blockchain/block-detail/$BLOCK_HASH

# Get all transactions
curl http://localhost:3000/api/blockchain/transactions

# Get pending transactions
curl http://localhost:3000/api/blockchain/pending-transactions
```

---

## Library Usage

### Using Blockchain Class Directly

```typescript
import BlockChain from "./blockchain/blockchain";

// Initialize blockchain
const blockchain = new BlockChain();
blockchain.setNodeAddress("3000");

// Add pending transaction
const success = await blockchain.addPendingTransaction(
  "voter_identifier",
  "electoral_id",
  101, // candidate code
);

// Mine new block
const newBlock = blockchain.mineBlock(blockchain.getPendingTransactions());
blockchain.addBlock(newBlock);

// Get blockchain data
const chain = blockchain.getChain();
const blocks = blockchain.getBlocks();
const transactions = blockchain.getTransactions();
```

### Using Smart Contract

```typescript
import SmartContract from "./smart_contract/smart_contract";

// Initialize smart contract
const smartContract = new SmartContract();

// Get election results
const results = await smartContract.getResults();
console.log(results);
// Output: { candidate1: 150, candidate2: 130, ... }

// Get computed results (with percentages)
const computedResults = await smartContract.getResultsComputed();
console.log(computedResults);
// Output: { candidate1: { votes: 150, percentage: 53.57 }, ... }

// Update smart contract (reloads data)
smartContract.update();
```

### Using Committee Class

```typescript
import Committee from "./committee/committee";

// Initialize committee
const committee = new Committee();

// Add candidate
await committee.addCandidateCommittee(
  "John Doe",
  101,
  "Independent Party",
  "IND",
  "active",
);

// Get all candidates
const candidates = await committee.getCandidates();

// Generate voter identifiers
const voters = await committee.generateIdentifiers();

// Deploy election announcement
await committee.deployAnnouncement({
  startTimeVoting: "2025-11-05T08:00:00Z",
  endTimeVoting: "2025-11-05T20:00:00Z",
  dateResults: "2025-11-06T00:00:00Z",
  numOfCandidates: 3,
  numOfVoters: 1000,
});
```

### Using Cryptography

```typescript
import CryptoBlockchain from "./crypto/cryptoBlockchain";

// Initialize crypto with keys
const crypto = new CryptoBlockchain(
  process.env.SECRET_KEY_IDENTIFIER,
  process.env.SECRET_IV_IDENTIFIER,
);

// Encrypt data
const encrypted = crypto.encrypt("sensitive_data");

// Decrypt data
const decrypted = crypto.decrypt(encrypted);
```

---

## Environment-Specific Usage

### Development

```bash
# Use development environment
export NODE_ENV=development
npm run dev

# Features enabled:
# - Auto-reload on file changes
# - Detailed error messages
# - Console logging
# - CORS from localhost origins
```

### Production

```bash
# Build and run production
npm run build
export NODE_ENV=production
npm start

# Features:
# - Optimized builds
# - Limited error details
# - Production logging
# - Strict CORS
```

### Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Watch mode
npm run test:watch

# Run specific test file
npm test -- blockchain.test.ts
```

---

## Next Steps

- **API Reference**: See [API.md](API.md) for complete API documentation
- **CLI Usage**: See [CLI.md](CLI.md) for command-line tools
- **Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- **Examples**: See [examples/](examples/) for more code examples

---

_For troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)_
