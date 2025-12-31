# Feature Matrix

Comprehensive feature catalog for QuantumBallot with locations and usage examples.

---

## Overview

This document catalogs all features in QuantumBallot, their locations in the codebase, and how to use them.

---

## Core Features

| Feature                    | Short description                                   | Module / File                                  | CLI flag / API                          | Example (path)                                      | Notes                         |
| -------------------------- | --------------------------------------------------- | ---------------------------------------------- | --------------------------------------- | --------------------------------------------------- | ----------------------------- |
| **Blockchain**             | Custom blockchain implementation with Proof of Work | `backend/src/blockchain/blockchain.ts`         | `/api/blockchain`                       | [blockchain-query.md](examples/blockchain-query.md) | Core voting ledger            |
| **Smart Contract**         | Election rules and vote validation                  | `backend/src/smart_contract/smart_contract.ts` | `/api/blockchain/get-results`           | [election-setup.md](examples/election-setup.md)     | Enforces election integrity   |
| **Vote Submission**        | Submit encrypted votes to blockchain                | `backend/src/blockchain/blockchain.ts`         | POST `/api/blockchain/transaction`      | [voting-flow.md](examples/voting-flow.md)           | Requires valid electoral ID   |
| **Cryptographic Security** | AES-256 encryption for votes and identifiers        | `backend/src/crypto/cryptoBlockchain.ts`       | Environment variables                   | [SECURITY.md](SECURITY.md)                          | Uses crypto-js library        |
| **Real-time Updates**      | WebSocket communication for live data               | `backend/src/index.ts` (Socket.IO)             | Socket.IO connection                    | N/A                                                 | Broadcasts blockchain events  |
| **JWT Authentication**     | Token-based authentication                          | `backend/src/middleware/verifyJWT.ts`          | Header: `Authorization: Bearer <token>` | [API.md](API.md#authentication)                     | Required for protected routes |
| **Two-Factor Auth**        | Email OTP verification                              | `backend/src/email_center/sendEmail.ts`        | `/api/committee/send-otp`               | N/A                                                 | Uses Nodemailer               |
| **QR Code Generation**     | Generate QR codes for voter verification            | `backend` (qrcode library)                     | N/A                                     | N/A                                                 | Used in mobile app            |
| **LevelDB Storage**        | Persistent blockchain storage                       | `backend/src/leveldb/index.ts`                 | Environment: `DB_PATH`                  | N/A                                                 | Embedded key-value database   |

---

## Election Management Features

| Feature                | Short description                      | Module / File                                  | CLI flag / API                            | Example (path)                                  | Notes                   |
| ---------------------- | -------------------------------------- | ---------------------------------------------- | ----------------------------------------- | ----------------------------------------------- | ----------------------- |
| **Create Election**    | Setup new election with parameters     | `backend/src/committee/committee.ts`           | POST `/api/committee/deploy-announcement` | [election-setup.md](examples/election-setup.md) | Defines start/end times |
| **Add Candidates**     | Register candidates for election       | `backend/src/committee/committee.ts`           | POST `/api/committee/add-candidate`       | [election-setup.md](examples/election-setup.md) | Requires unique code    |
| **Generate Voter IDs** | Create cryptographic voter identifiers | `backend/src/committee/committee.ts`           | GET `/api/committee/generate-identifiers` | [election-setup.md](examples/election-setup.md) | One-time operation      |
| **Manage Users**       | Add/remove committee members           | `backend/src/committee/committee.ts`           | POST `/api/committee/add-user`            | [API.md](API.md#post-apicommitteeadd-user)      | Role-based access       |
| **View Results**       | Access election results                | `backend/src/smart_contract/smart_contract.ts` | GET `/api/blockchain/get-results`         | [USAGE.md](USAGE.md#7-view-results)             | JWT required            |
| **Clear Data**         | Reset blockchain and data              | `backend/src/blockchain/blockchain.ts`         | GET `/api/committee/clear-*`              | N/A                                             | Development only        |

---

## Voter Features (Mobile)

| Feature                | Short description            | Module / File                             | CLI flag / API                     | Example (path)                            | Notes                     |
| ---------------------- | ---------------------------- | ----------------------------------------- | ---------------------------------- | ----------------------------------------- | ------------------------- |
| **Voter Registration** | Register with electoral ID   | `mobile-frontend/src/screens/Auth/`       | Mobile app UI                      | [voting-flow.md](examples/voting-flow.md) | First-time setup          |
| **Biometric Auth**     | Fingerprint/Face ID login    | `mobile-frontend` (Expo SecureStore)      | Mobile app UI                      | N/A                                       | iOS/Android native        |
| **View Candidates**    | Browse candidate information | `mobile-frontend/src/screens/Candidates/` | Mobile app UI                      | [voting-flow.md](examples/voting-flow.md) | Real-time data            |
| **Cast Vote**          | Submit vote for candidate    | `mobile-frontend/src/services/api.ts`     | POST `/api/blockchain/transaction` | [voting-flow.md](examples/voting-flow.md) | One vote per voter        |
| **Verify Vote**        | Check vote submission status | `mobile-frontend/src/screens/Profile/`    | Mobile app UI                      | N/A                                       | Shows block hash          |
| **QR Code Scan**       | Verify voter identity via QR | `mobile-frontend` (Expo Camera)           | Mobile app UI                      | N/A                                       | Uses expo-barcode-scanner |

---

## Committee Features (Web)

| Feature                   | Short description             | Module / File                        | CLI flag / API | Example (path)                                      | Notes                        |
| ------------------------- | ----------------------------- | ------------------------------------ | -------------- | --------------------------------------------------- | ---------------------------- |
| **Dashboard**             | Real-time election monitoring | `web-frontend/src/pages/Dashboard/`  | Web UI         | [USAGE.md](USAGE.md#6-monitor-voting)               | Live statistics              |
| **Election Setup**        | Configure election parameters | `web-frontend/src/pages/Elections/`  | Web UI         | [election-setup.md](examples/election-setup.md)     | Multi-step wizard            |
| **Candidate Management**  | Add/edit/remove candidates    | `web-frontend/src/pages/Candidates/` | Web UI         | [USAGE.md](USAGE.md#3-add-candidates)               | CRUD operations              |
| **Voter Management**      | Manage registered voters      | `web-frontend/src/pages/Voters/`     | Web UI         | [USAGE.md](USAGE.md#4-generate-voter-identifiers)   | View/generate IDs            |
| **Results Visualization** | Charts and graphs for results | `web-frontend/src/pages/Results/`    | Web UI         | N/A                                                 | Uses Recharts/MUI Charts     |
| **Blockchain Explorer**   | Browse blockchain blocks      | `web-frontend/src/pages/Blockchain/` | Web UI         | [blockchain-query.md](examples/blockchain-query.md) | View all blocks/transactions |
| **Audit Logs**            | View system activity logs     | `web-frontend/src/pages/Audit/`      | Web UI         | N/A                                                 | Security auditing            |

---

## API Features

| Feature                      | Short description        | Module / File                                | CLI flag / API                             | Example (path)                                         | Notes               |
| ---------------------------- | ------------------------ | -------------------------------------------- | ------------------------------------------ | ------------------------------------------------------ | ------------------- |
| **Get Blockchain**           | Retrieve full blockchain | `backend/src/api/routes/blockchain.route.ts` | GET `/api/blockchain`                      | [API.md](API.md#get-apiblockchain)                     | Public endpoint     |
| **Get Blocks**               | List all blocks          | `backend/src/api/routes/blockchain.route.ts` | GET `/api/blockchain/blocks`               | [API.md](API.md#get-apiblockchainblocks)               | Paginated (future)  |
| **Get Block Detail**         | Get specific block       | `backend/src/api/routes/blockchain.route.ts` | GET `/api/blockchain/block-detail/:id`     | [API.md](API.md#get-apiblockchainblock-detailid)       | Requires block hash |
| **Get Transactions**         | List all transactions    | `backend/src/api/routes/blockchain.route.ts` | GET `/api/blockchain/transactions`         | [API.md](API.md#get-apiblockchaintransactions)         | All confirmed votes |
| **Get Pending Transactions** | List pending votes       | `backend/src/api/routes/blockchain.route.ts` | GET `/api/blockchain/pending-transactions` | [API.md](API.md#get-apiblockchainpending-transactions) | Not yet mined       |
| **Submit Transaction**       | Submit new vote          | `backend/src/api/routes/blockchain.route.ts` | POST `/api/blockchain/transaction`         | [API.md](API.md#post-apiblockchaintransaction)         | Validates voter     |
| **Get Results**              | Get election results     | `backend/src/api/routes/blockchain.route.ts` | GET `/api/blockchain/get-results`          | [API.md](API.md#get-apiblockchainget-results)          | JWT required        |
| **Get Computed Results**     | Results with percentages | `backend/src/api/routes/blockchain.route.ts` | GET `/api/blockchain/get-results-computed` | [API.md](API.md#get-apiblockchainget-results-computed) | Public endpoint     |
| **Get Candidates**           | List all candidates      | `backend/src/api/routes/committee.route.ts`  | GET `/api/committee/candidates`            | [API.md](API.md#get-apicommitteecandidates)            | Public endpoint     |
| **Add Candidate**            | Register new candidate   | `backend/src/api/routes/committee.route.ts`  | POST `/api/committee/add-candidate`        | [API.md](API.md#post-apicommitteeadd-candidate)        | Requires auth       |
| **Get Announcement**         | Get election details     | `backend/src/api/routes/committee.route.ts`  | GET `/api/committee/announcement`          | [API.md](API.md#get-apicommitteeannouncement)          | Public endpoint     |
| **Deploy Announcement**      | Create election          | `backend/src/api/routes/committee.route.ts`  | POST `/api/committee/deploy-announcement`  | [API.md](API.md#post-apicommitteedeploy-announcement)  | Requires auth       |

---

## Security Features

| Feature                    | Short description          | Module / File                                  | CLI flag / API          | Example (path)                                          | Notes                  |
| -------------------------- | -------------------------- | ---------------------------------------------- | ----------------------- | ------------------------------------------------------- | ---------------------- |
| **Vote Encryption**        | Encrypt votes with AES-256 | `backend/src/crypto/cryptoBlockchain.ts`       | Environment keys        | [SECURITY.md](SECURITY.md)                              | End-to-end encryption  |
| **Identifier Encryption**  | Encrypt voter identifiers  | `backend/src/crypto/cryptoBlockchain.ts`       | Environment keys        | [SECURITY.md](SECURITY.md)                              | Protects voter privacy |
| **Password Hashing**       | bcrypt password hashing    | `backend` (bcrypt library)                     | N/A                     | [SECURITY.md](SECURITY.md)                              | Salt rounds: 10        |
| **JWT Tokens**             | Stateless authentication   | `backend` (jsonwebtoken library)               | Header: `Authorization` | [API.md](API.md#authentication)                         | Expires in 24h         |
| **CORS Protection**        | Restrict API access        | `backend/src/config/coreOptions.ts`            | Configuration file      | [CONFIGURATION.md](CONFIGURATION.md#cors-configuration) | Whitelist origins      |
| **Input Validation**       | Sanitize user input        | `backend/src/api/routes/*.route.ts`            | Middleware              | N/A                                                     | Prevents injection     |
| **Double-Vote Prevention** | Block duplicate votes      | `backend/src/smart_contract/smart_contract.ts` | Smart contract logic    | [SECURITY.md](SECURITY.md)                              | Tracked in Set         |
| **Audit Trails**           | Log all operations         | Throughout codebase                            | Console/file logs       | N/A                                                     | Production logging     |

---

## Blockchain Features

| Feature                   | Short description         | Module / File                          | CLI flag / API         | Example (path)                                         | Notes                  |
| ------------------------- | ------------------------- | -------------------------------------- | ---------------------- | ------------------------------------------------------ | ---------------------- |
| **Proof of Work**         | Mining algorithm          | `backend/src/blockchain/blockchain.ts` | `mineBlock()` method   | [blockchain-query.md](examples/blockchain-query.md)    | Difficulty: dynamic    |
| **SHA-256 Hashing**       | Cryptographic hashing     | `backend/src/blockchain/blockchain.ts` | crypto-js/sha256       | [ARCHITECTURE.md](ARCHITECTURE.md)                     | Block integrity        |
| **Genesis Block**         | First block creation      | `backend/src/blockchain/blockchain.ts` | `createGenesisBlock()` | [blockchain-query.md](examples/blockchain-query.md)    | Hardcoded              |
| **Block Validation**      | Validate new blocks       | `backend/src/blockchain/blockchain.ts` | `isValidBlock()`       | N/A                                                    | Checks hash, timestamp |
| **Chain Validation**      | Validate entire chain     | `backend/src/blockchain/blockchain.ts` | `isValidChain()`       | [blockchain-query.md](examples/blockchain-query.md)    | Integrity check        |
| **Transaction Pool**      | Pending transactions      | `backend/src/blockchain/blockchain.ts` | Array in memory        | [API.md](API.md#get-apiblockchainpending-transactions) | Cleared after mining   |
| **Persistent Storage**    | Save chain to LevelDB     | `backend/src/leveldb/index.ts`         | `writeChain()`         | N/A                                                    | Survives restarts      |
| **Chain Synchronization** | Multi-node sync (planned) | `backend/src/network/`                 | Future feature         | N/A                                                    | P2P network            |

---

## Testing Features

| Feature               | Short description        | Module / File                 | CLI flag / API          | Example (path)                     | Notes                               |
| --------------------- | ------------------------ | ----------------------------- | ----------------------- | ---------------------------------- | ----------------------------------- |
| **Unit Tests**        | Component-level tests    | `backend/src/tests/`          | `npm test`              | [CONTRIBUTING.md](CONTRIBUTING.md) | Jest framework                      |
| **Integration Tests** | API endpoint tests       | `backend/src/tests/`          | `npm test`              | [CONTRIBUTING.md](CONTRIBUTING.md) | Supertest library                   |
| **Coverage Reports**  | Code coverage analysis   | Test output                   | `npm run test:coverage` | N/A                                | Target: 80%+                        |
| **Mock Data**         | Test data generation     | Test files                    | N/A                     | N/A                                | Faker/custom                        |
| **Web Tests**         | Frontend component tests | `web-frontend/src/__tests__/` | `npm test`              | [CONTRIBUTING.md](CONTRIBUTING.md) | Vitest + Testing Library            |
| **Mobile Tests**      | Mobile component tests   | `mobile-frontend/__tests__/`  | `npm test`              | [CONTRIBUTING.md](CONTRIBUTING.md) | Jest + React Native Testing Library |

---

## DevOps Features

| Feature                  | Short description        | Module / File                | CLI flag / API      | Example (path)                       | Notes                 |
| ------------------------ | ------------------------ | ---------------------------- | ------------------- | ------------------------------------ | --------------------- |
| **Docker Support**       | Containerization         | `infrastructure/docker/`     | `docker-compose up` | [DEPLOYMENT.md](DEPLOYMENT.md)       | Multi-stage builds    |
| **Kubernetes Manifests** | K8s deployment configs   | `infrastructure/kubernetes/` | `kubectl apply -f`  | [DEPLOYMENT.md](DEPLOYMENT.md)       | Scalable deployment   |
| **Terraform Scripts**    | Infrastructure as Code   | `infrastructure/terraform/`  | `terraform apply`   | [DEPLOYMENT.md](DEPLOYMENT.md)       | AWS/GCP/Azure         |
| **Ansible Playbooks**    | Configuration management | `infrastructure/ansible/`    | `ansible-playbook`  | [DEPLOYMENT.md](DEPLOYMENT.md)       | Automated setup       |
| **CI/CD Pipeline**       | GitHub Actions workflows | `.github/workflows/`         | Automatic           | [DEPLOYMENT.md](DEPLOYMENT.md)       | Test + build + deploy |
| **Monitoring**           | Prometheus + Grafana     | `infrastructure/monitoring/` | Docker Compose      | [DEPLOYMENT.md](DEPLOYMENT.md)       | Metrics collection    |
| **Logging**              | Centralized logging      | Configuration files          | Environment vars    | [CONFIGURATION.md](CONFIGURATION.md) | Winston/Morgan        |

---

## Utility Scripts

| Feature                     | Short description      | Module / File                        | CLI flag / API                         | Example (path)                               | Notes              |
| --------------------------- | ---------------------- | ------------------------------------ | -------------------------------------- | -------------------------------------------- | ------------------ |
| **Setup Script**            | Install dependencies   | `scripts/setup.sh`                   | `./scripts/setup.sh`                   | [CLI.md](CLI.md#setup-script)                | All components     |
| **Build Script**            | Build all components   | `scripts/build.sh`                   | `./scripts/build.sh`                   | [CLI.md](CLI.md#build-script)                | Production builds  |
| **Dev Workflow**            | Start/stop dev servers | `scripts/dev_workflow.sh`            | `./scripts/dev_workflow.sh start`      | [CLI.md](CLI.md#development-workflow-script) | Multi-component    |
| **Deployment**              | Deploy to environments | `scripts/deployment.sh`              | `./scripts/deployment.sh <env>`        | [CLI.md](CLI.md#deployment-script)           | Staging/production |
| **Lint All**                | Run linters            | `scripts/lint-all.sh`                | `./scripts/lint-all.sh`                | [CLI.md](CLI.md#lint-all-script)             | ESLint/Prettier    |
| **Documentation Generator** | Generate docs          | `scripts/documentation_generator.sh` | `./scripts/documentation_generator.sh` | [CLI.md](CLI.md#documentation-generator)     | Sphinx/JSDoc       |
| **Environment Setup**       | Configure .env files   | `scripts/setup_environment.sh`       | `./scripts/setup_environment.sh`       | [CLI.md](CLI.md#environment-setup-script)    | Interactive        |

---

## Feature Dependencies

### Feature Dependency Graph

```
Blockchain
  └─> Smart Contract
       └─> Vote Submission
            └─> Voter Authentication
                 └─> JWT + 2FA
```

```
Election Management
  ├─> Candidate Management
  ├─> Voter ID Generation
  │    └─> Cryptographic Encryption
  └─> Announcement Deployment
       └─> Database Storage
```

---

_For detailed usage of any feature, see [USAGE.md](USAGE.md). For API details, see [API.md](API.md)._
