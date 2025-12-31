# Architecture Documentation

System architecture, component interactions, and technical design for QuantumBallot.

---

## Table of Contents

1. [System Overview](#system-overview)
2. [High-Level Architecture](#high-level-architecture)
3. [Component Architecture](#component-architecture)
4. [Data Flow](#data-flow)
5. [Database Design](#database-design)
6. [Security Architecture](#security-architecture)
7. [Deployment Architecture](#deployment-architecture)

---

## System Overview

QuantumBallot is a full-stack blockchain-based voting system designed as a three-tier architecture:

1. **Client Tier**: Web (React) and Mobile (React Native) applications
2. **Application Tier**: Node.js/Express backend with REST API
3. **Data Tier**: Custom blockchain with LevelDB storage

**Key Design Principles**:

- **Immutability**: All votes recorded on blockchain are permanent
- **Privacy**: Voter identities encrypted, votes anonymous
- **Transparency**: Complete blockchain accessible for verification
- **Security**: Multi-layer encryption, authentication, and validation
- **Scalability**: Designed for horizontal scaling (future)

---

## High-Level Architecture

### System Context Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    QuantumBallot System                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐        ┌──────────────┐                  │
│  │ Web Frontend │        │Mobile Frontend│                  │
│  │   (React)    │        │(React Native) │                  │
│  │              │        │               │                  │
│  │ Committee    │        │ Voters        │                  │
│  │ Dashboard    │        │ Voting App    │                  │
│  └──────┬───────┘        └───────┬───────┘                  │
│         │                        │                           │
│         └────────┬───────────────┘                           │
│                  │ HTTPS/WSS                                 │
│         ┌────────▼───────────┐                              │
│         │                    │                              │
│         │  Backend API       │                              │
│         │  (Node.js/Express) │                              │
│         │                    │                              │
│         │  ┌──────────────┐  │                              │
│         │  │  Blockchain  │  │                              │
│         │  │    Engine    │  │                              │
│         │  └──────┬───────┘  │                              │
│         │         │           │                              │
│         │  ┌──────▼───────┐  │                              │
│         │  │   LevelDB    │  │                              │
│         │  │   Storage    │  │                              │
│         │  └──────────────┘  │                              │
│         └────────────────────┘                              │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

```
┌─────────────────────────────────────────┐
│         Frontend Layers                 │
├─────────────────────────────────────────┤
│ Web: React + TypeScript + Tailwind     │
│ Mobile: React Native + Expo            │
└─────────────────┬───────────────────────┘
                  │ HTTP/REST + WebSocket
┌─────────────────▼───────────────────────┐
│        Backend Layer                    │
├─────────────────────────────────────────┤
│ Express.js API + TypeScript             │
│ Socket.IO (Real-time)                   │
│ JWT Authentication                      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Business Logic Layer               │
├─────────────────────────────────────────┤
│ Blockchain Engine                       │
│ Smart Contract                          │
│ Cryptography Module                     │
│ Committee Management                    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Data Layer                      │
├─────────────────────────────────────────┤
│ LevelDB (Blockchain Persistence)        │
│ In-Memory (Transaction Pool)            │
└─────────────────────────────────────────┘
```

---

## Component Architecture

### Backend Components

```
backend/
├── src/
│   ├── index.ts                    # Application entry point
│   ├── api/                        # REST API layer
│   │   ├── index.ts               # API router aggregator
│   │   └── routes/
│   │       ├── blockchain.route.ts  # Blockchain endpoints
│   │       └── committee.route.ts   # Committee endpoints
│   ├── blockchain/                 # Blockchain core
│   │   ├── blockchain.ts          # Main blockchain class
│   │   └── data_types.ts          # Type definitions
│   ├── smart_contract/            # Smart contract logic
│   │   └── smart_contract.ts      # Election rules & validation
│   ├── crypto/                    # Cryptography
│   │   ├── cryptoBlockchain.ts    # AES encryption wrapper
│   │   └── genKey.ts              # Key generation
│   ├── committee/                 # Committee management
│   │   ├── committee.ts           # Committee operations
│   │   └── data_types.ts          # Committee types
│   ├── leveldb/                   # Database layer
│   │   └── index.ts               # LevelDB operations
│   ├── middleware/                # Express middleware
│   │   ├── verifyJWT.ts           # JWT authentication
│   │   └── credentials.ts         # CORS credentials
│   ├── email_center/              # Email notifications
│   │   ├── sendEmail.ts           # Email sender
│   │   └── emailTemplate.ts       # Email templates
│   ├── network/                   # P2P networking (future)
│   │   └── p2p.ts                 # Peer-to-peer logic
│   └── config/                    # Configuration
│       ├── allowedOrigins.ts      # CORS whitelist
│       └── coreOptions.ts         # Core options
```

### Module Interactions

```
┌──────────────┐
│  index.ts    │ ──> Initializes Express app
└──────┬───────┘
       │
       ├──> ┌──────────────┐
       │    │ API Router   │ ──> Routes HTTP requests
       │    └──────┬───────┘
       │           │
       │           ├──> Blockchain Routes ──> blockchain.ts
       │           └──> Committee Routes ──> committee.ts
       │
       ├──> ┌──────────────┐
       │    │ Middleware   │ ──> Authentication, CORS
       │    └──────────────┘
       │
       └──> ┌──────────────┐
            │  LevelDB     │ ──> Persistent storage
            └──────────────┘
```

### Frontend Architecture (Web)

```
web-frontend/
├── src/
│   ├── App.tsx                    # Root component
│   ├── main.tsx                   # Entry point
│   ├── pages/                     # Page components
│   │   ├── Dashboard/             # Main dashboard
│   │   ├── Elections/             # Election management
│   │   ├── Candidates/            # Candidate management
│   │   ├── Voters/                # Voter management
│   │   ├── Results/               # Results visualization
│   │   └── Blockchain/            # Blockchain explorer
│   ├── components/                # Reusable components
│   │   ├── ui/                    # UI primitives
│   │   ├── charts/                # Data visualization
│   │   └── forms/                 # Form components
│   ├── services/                  # API services
│   │   ├── api.ts                 # API client
│   │   └── socket.ts              # WebSocket client
│   ├── hooks/                     # Custom React hooks
│   ├── context/                   # React context providers
│   ├── utils/                     # Utility functions
│   └── types/                     # TypeScript types
```

### Frontend Architecture (Mobile)

```
mobile-frontend/
├── App.tsx                        # Root component
├── src/
│   ├── screens/                   # Screen components
│   │   ├── Auth/                  # Authentication screens
│   │   ├── Home/                  # Home dashboard
│   │   ├── Candidates/            # Candidate listing
│   │   ├── Voting/                # Voting interface
│   │   └── Profile/               # User profile
│   ├── navigation/                # Navigation config
│   │   └── AppNavigator.tsx       # Stack navigator
│   ├── components/                # Reusable components
│   ├── services/                  # API services
│   │   └── api.ts                 # API client
│   ├── hooks/                     # Custom hooks
│   ├── utils/                     # Utility functions
│   └── types/                     # TypeScript types
```

---

## Data Flow

### Vote Submission Flow

```
┌─────────────┐
│   Voter     │
│  (Mobile)   │
└──────┬──────┘
       │ 1. Select candidate
       ▼
┌──────────────┐
│ Vote Screen  │
└──────┬───────┘
       │ 2. Submit vote (electoralId + candidateCode)
       ▼
┌─────────────────────┐
│  POST /api/         │
│  blockchain/        │
│  transaction        │
└──────┬──────────────┘
       │ 3. Validate request
       ▼
┌─────────────────────┐
│  Blockchain.        │
│  addPending         │
│  Transaction()      │
└──────┬──────────────┘
       │ 4. Verify voter hasn't voted
       │ 5. Encrypt vote data
       ▼
┌─────────────────────┐
│  Transaction Pool   │
│  (In Memory)        │
└──────┬──────────────┘
       │ 6. Mining process (when pool full or timer)
       ▼
┌─────────────────────┐
│  mineBlock()        │
│  - Proof of Work    │
│  - Create block     │
└──────┬──────────────┘
       │ 7. Validate and add block
       ▼
┌─────────────────────┐
│  Blockchain.chain   │
│  (Array of blocks)  │
└──────┬──────────────┘
       │ 8. Persist to storage
       ▼
┌─────────────────────┐
│  LevelDB            │
│  (Persistent)       │
└──────┬──────────────┘
       │ 9. Broadcast via WebSocket
       ▼
┌─────────────────────┐
│  All Connected      │
│  Clients            │
└─────────────────────┘
```

### Election Setup Flow

```
┌──────────────┐
│ Committee    │
│ Member (Web) │
└──────┬───────┘
       │ 1. Configure election
       ▼
┌────────────────────────┐
│ POST /api/committee/   │
│ deploy-announcement    │
└──────┬─────────────────┘
       │ 2. Validate parameters
       ▼
┌────────────────────────┐
│ Committee.deploy       │
│ Announcement()         │
└──────┬─────────────────┘
       │ 3. Store in LevelDB
       ▼
┌────────────────────────┐
│ Smart Contract         │
│ .initVariables()       │
└──────┬─────────────────┘
       │ 4. Load candidates & voters
       ▼
┌────────────────────────┐
│ Election Active        │
│ Voting Enabled         │
└────────────────────────┘
```

### Result Computation Flow

```
┌────────────────────────┐
│ GET /api/blockchain/   │
│ get-results-computed   │
└──────┬─────────────────┘
       │ 1. Request results
       ▼
┌────────────────────────┐
│ SmartContract.         │
│ getResultsComputed()   │
└──────┬─────────────────┘
       │ 2. Read all blocks
       ▼
┌────────────────────────┐
│ Decrypt all votes      │
│ (from transactions)    │
└──────┬─────────────────┘
       │ 3. Count votes per candidate
       ▼
┌────────────────────────┐
│ Calculate percentages  │
└──────┬─────────────────┘
       │ 4. Return results
       ▼
┌────────────────────────┐
│ {                      │
│   totalVotes: 450,     │
│   results: [           │
│     {candidate: ...},  │
│     ...                │
│   ]                    │
│ }                      │
└────────────────────────┘
```

---

## Database Design

### LevelDB Schema

QuantumBallot uses LevelDB, a key-value store. Keys are structured hierarchically:

```
Key Structure:
  blockchain:chain              → Serialized blockchain array
  blockchain:candidates         → Array of candidates
  blockchain:voters             → Array of generated voter IDs
  blockchain:citizens           → Array of registered citizens
  blockchain:announcement       → Election announcement object
  blockchain:results            → Computed election results
  blockchain:voterCitizen:{id}  → Mapping of voter to citizen
```

**Data Types**:

```typescript
// Blockchain
interface Block {
  blockIndex: number;
  blockHeader: BlockHeader;
  transactions: Transaction[];
}

interface BlockHeader {
  timestamp: number;
  previousBlockHash: string;
  blockHash: string;
  nonce: number;
}

interface Transaction {
  transactionId: string;
  data: {
    identifier: string; // Encrypted
    vote: string; // Encrypted
    timestamp: number;
  };
}

// Candidates
interface Candidate {
  name: string;
  code: number; // Unique
  party: string;
  acronym: string;
  status: "active" | "inactive";
}

// Voters
interface Voter {
  identifier: string; // Encrypted unique ID
  hasVoted: boolean;
  timestamp?: number;
}

// Citizens (registered voters)
interface Citizen {
  name: string;
  electoralId: string; // Government-issued ID
  province: string;
  registrationDate: string;
}

// Announcement
interface Announcement {
  startTimeVoting: string; // ISO 8601
  endTimeVoting: string;
  dateResults: string;
  numOfCandidates: number;
  numOfVoters: number;
  status: "active" | "completed";
}
```

---

## Security Architecture

### Multi-Layer Security

```
┌────────────────────────────────────────────┐
│  Layer 1: Transport Security               │
│  - HTTPS/TLS 1.3                          │
│  - WSS (WebSocket Secure)                 │
└────────────────┬───────────────────────────┘
                 │
┌────────────────▼───────────────────────────┐
│  Layer 2: Authentication                   │
│  - JWT tokens (24h expiry)                │
│  - 2FA via email OTP                      │
│  - Biometric auth (mobile)                │
└────────────────┬───────────────────────────┘
                 │
┌────────────────▼───────────────────────────┐
│  Layer 3: Data Encryption                  │
│  - AES-256 for votes                      │
│  - AES-256 for voter identifiers          │
│  - bcrypt for passwords                   │
└────────────────┬───────────────────────────┘
                 │
┌────────────────▼───────────────────────────┐
│  Layer 4: Blockchain Integrity             │
│  - SHA-256 block hashing                  │
│  - Proof of Work                          │
│  - Chain validation                       │
└────────────────┬───────────────────────────┘
                 │
┌────────────────▼───────────────────────────┐
│  Layer 5: Application Logic                │
│  - Input validation                       │
│  - Double-vote prevention                 │
│  - Smart contract rules                   │
└────────────────────────────────────────────┘
```

### Encryption Details

**Vote Encryption**:

- Algorithm: AES-256-CBC
- Key: 32 bytes (from environment)
- IV: 16 bytes (from environment)
- Input: `{electoralId, candidateCode, timestamp}`
- Output: Base64 encrypted string

**Workflow**:

```
Plain Vote → AES Encrypt → Store in Block → Mine Block → Persist to DB
                ↓
         Encrypted string in blockchain
                ↓
         Decrypt only for result computation
```

---

## Deployment Architecture

### Production Deployment (Kubernetes)

```
┌────────────────────────────────────────────┐
│           Load Balancer (Nginx)            │
│         SSL Termination (Let's Encrypt)    │
└────────────┬───────────────────────────────┘
             │
     ┌───────┴────────┐
     │                │
┌────▼─────┐    ┌────▼─────┐
│   Web    │    │ API Pod  │
│   Pod    │    │ (3 reps) │
└──────────┘    └────┬─────┘
                     │
               ┌─────▼──────┐
               │ Persistent │
               │  Volume    │
               │ (LevelDB)  │
               └────────────┘
```

### Scaling Strategy

**Horizontal Scaling** (future):

- Multiple backend pods
- Shared blockchain storage (distributed)
- Load balancer distribution

**Current Limitations**:

- Single-node blockchain (no P2P yet)
- Shared LevelDB (not distributed)

---

_For deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md). For security details, see [SECURITY.md](SECURITY.md)._
