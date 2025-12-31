# API Reference

Complete REST API documentation for QuantumBallot backend.

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Blockchain Endpoints](#blockchain-endpoints)
4. [Committee Endpoints](#committee-endpoints)
5. [Response Format](#response-format)
6. [Error Handling](#error-handling)

---

## Overview

**Base URL**: `http://localhost:3000/api`

**Protocol**: HTTP/HTTPS

**Data Format**: JSON

**Authentication**: JWT tokens (where required)

---

## Authentication

### JWT Token Authentication

Protected endpoints require JWT token in Authorization header:

```http
Authorization: Bearer <your_jwt_token>
```

### Login Flow

```bash
# Login (get JWT token)
curl -X POST http://localhost:3000/api/committee/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'

# Response includes JWT token
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {...}
}
```

---

## Blockchain Endpoints

### GET /api/blockchain

Get complete blockchain data.

**Authentication**: Not required

**Response Example**:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "chain": [...],
    "transactionPool": [...],
    "nodeAddress": "3000"
  },
  "timestamp": "2025-12-30T10:30:00.000Z"
}
```

---

### GET /api/blockchain/chain

Get the entire blockchain chain.

| Name | Type | Required? | Default | Description             | Example |
| ---- | ---- | --------- | ------- | ----------------------- | ------- |
| -    | -    | -         | -       | Returns full blockchain | -       |

**Request**:

```bash
curl http://localhost:3000/api/blockchain/chain
```

**Response**:

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
          "blockHash": "genesis_hash",
          "nonce": 0
        },
        "transactions": []
      }
    ]
  }
}
```

---

### GET /api/blockchain/blocks

Get all blocks in the blockchain.

**Authentication**: Not required

**Request**:

```bash
curl http://localhost:3000/api/blockchain/blocks
```

**Response**:

```json
{
  "success": true,
  "data": [
    {
      "blockIndex": 0,
      "timestamp": 1640000000,
      "hash": "genesis_hash",
      "previousHash": "0",
      "transactionCount": 0
    },
    {
      "blockIndex": 1,
      "timestamp": 1640001000,
      "hash": "block1_hash",
      "previousHash": "genesis_hash",
      "transactionCount": 5
    }
  ]
}
```

---

### GET /api/blockchain/block-detail/:id

Get detailed information about a specific block.

| Name | Type   | Required? | Default | Description            | Example           |
| ---- | ------ | --------- | ------- | ---------------------- | ----------------- |
| `id` | string | Yes       | -       | Block hash to retrieve | `0a1b2c3d4e5f...` |

**Request**:

```bash
curl http://localhost:3000/api/blockchain/block-detail/0a1b2c3d4e5f...
```

**Response**:

```json
{
  "success": true,
  "data": {
    "blockIndex": 1,
    "blockHeader": {
      "timestamp": 1640001000,
      "previousBlockHash": "genesis_hash",
      "blockHash": "0a1b2c3d4e5f...",
      "nonce": 12345
    },
    "transactions": [
      {
        "transactionId": "tx1",
        "data": {
          "identifier": "encrypted_identifier",
          "vote": "encrypted_vote",
          "timestamp": 1640001000
        }
      }
    ]
  }
}
```

---

### GET /api/blockchain/transactions

Get all confirmed transactions from the blockchain.

**Authentication**: Not required

**Request**:

```bash
curl http://localhost:3000/api/blockchain/transactions
```

**Response**:

```json
{
  "success": true,
  "data": [
    {
      "transactionId": "tx1",
      "blockIndex": 1,
      "timestamp": 1640001000,
      "voterIdentifier": "encrypted",
      "candidateCode": "encrypted"
    }
  ]
}
```

---

### GET /api/blockchain/pending-transactions

Get pending transactions (not yet mined into a block).

**Authentication**: Not required

**Request**:

```bash
curl http://localhost:3000/api/blockchain/pending-transactions
```

**Response**:

```json
{
  "success": true,
  "data": [
    {
      "transactionId": "tx_pending_1",
      "data": {
        "identifier": "encrypted_identifier",
        "vote": "encrypted_vote",
        "timestamp": 1640002000
      }
    }
  ]
}
```

---

### POST /api/blockchain/transaction

Submit a new vote transaction.

| Name         | Type   | Required? | Default | Description          | Example     |
| ------------ | ------ | --------- | ------- | -------------------- | ----------- |
| `identifier` | string | Yes       | -       | Voter's electoral ID | `ABC123456` |
| `choiceCode` | number | Yes       | -       | Candidate code       | `101`       |

**Request**:

```bash
curl -X POST http://localhost:3000/api/blockchain/transaction \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "ABC123456",
    "choiceCode": 101
  }'
```

**Success Response**:

```json
{
  "success": true,
  "message": "Vote transaction added successfully",
  "data": {
    "transactionId": "tx_new_1",
    "status": "pending",
    "timestamp": "2025-12-30T10:30:00.000Z"
  }
}
```

**Error Responses**:

```json
// Missing identifier
{
  "success": false,
  "message": "Missing required field: identifier",
  "timestamp": "2025-12-30T10:30:00.000Z"
}

// Invalid electoral ID
{
  "success": false,
  "message": "Invalid electoral identifier",
  "timestamp": "2025-12-30T10:30:00.000Z"
}

// Already voted
{
  "success": false,
  "message": "Voter has already voted",
  "timestamp": "2025-12-30T10:30:00.000Z"
}
```

---

### GET /api/blockchain/get-results

Get election results (requires authentication).

**Authentication**: Required (JWT token)

| Name            | Type            | Required? | Default | Description      | Example            |
| --------------- | --------------- | --------- | ------- | ---------------- | ------------------ |
| `Authorization` | string (header) | Yes       | -       | JWT Bearer token | `Bearer eyJhbG...` |

**Request**:

```bash
curl http://localhost:3000/api/blockchain/get-results \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response**:

```json
{
  "success": true,
  "data": {
    "candidate_101": 150,
    "candidate_102": 130,
    "candidate_103": 95,
    "candidate_104": 75
  }
}
```

---

### GET /api/blockchain/get-results-computed

Get computed election results with percentages.

**Authentication**: Not required

**Request**:

```bash
curl http://localhost:3000/api/blockchain/get-results-computed
```

**Response**:

```json
{
  "success": true,
  "data": {
    "totalVotes": 450,
    "results": [
      {
        "candidateCode": 101,
        "candidateName": "John Smith",
        "votes": 150,
        "percentage": 33.33
      },
      {
        "candidateCode": 102,
        "candidateName": "Jane Doe",
        "votes": 130,
        "percentage": 28.89
      }
    ]
  }
}
```

---

## Committee Endpoints

### GET /api/committee/registers

Get all registered citizens.

**Authentication**: Required

**Request**:

```bash
curl http://localhost:3000/api/committee/registers \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response**:

```json
{
  "registers": [
    {
      "name": "John Citizen",
      "electoralId": "ABC123456",
      "province": "New York",
      "registrationDate": "2025-01-01"
    }
  ],
  "note": "Request accepted ..."
}
```

---

### GET /api/committee/generate-identifiers

Generate cryptographic identifiers for registered voters.

**Authentication**: Required

**Request**:

```bash
curl http://localhost:3000/api/committee/generate-identifiers
```

**Response**:

```json
{
  "voters": [
    {
      "electoralId": "ABC123456",
      "identifier": "encrypted_unique_identifier",
      "hasVoted": false
    }
  ],
  "note": "Request accepted ..."
}
```

---

### POST /api/committee/add-candidate

Add a new candidate to the election.

| Name      | Type   | Required? | Default  | Description           | Example                |
| --------- | ------ | --------- | -------- | --------------------- | ---------------------- |
| `name`    | string | Yes       | -        | Candidate full name   | `John Smith`           |
| `code`    | number | Yes       | -        | Unique candidate code | `101`                  |
| `party`   | string | Yes       | -        | Political party name  | `Democratic Party`     |
| `acronym` | string | No        | -        | Party acronym         | `DEM`                  |
| `status`  | string | No        | `active` | Candidate status      | `active` or `inactive` |

**Request**:

```bash
curl -X POST http://localhost:3000/api/committee/add-candidate \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Smith",
    "code": 101,
    "party": "Democratic Party",
    "acronym": "DEM",
    "status": "active"
  }'
```

**Response**:

```json
{
  "note": "Request accepted, candidate added.",
  "candidates": [
    {
      "name": "John Smith",
      "code": 101,
      "party": "Democratic Party",
      "acronym": "DEM",
      "status": "active"
    }
  ]
}
```

---

### POST /api/committee/add-user

Add a new committee user.

| Name       | Type   | Required? | Default | Description    | Example                |
| ---------- | ------ | --------- | ------- | -------------- | ---------------------- |
| `name`     | string | Yes       | -       | User full name | `Admin User`           |
| `username` | string | Yes       | -       | Login username | `admin`                |
| `password` | string | Yes       | -       | User password  | `secure_password`      |
| `role`     | string | Yes       | -       | User role      | `admin` or `committee` |

**Request**:

```bash
curl -X POST http://localhost:3000/api/committee/add-user \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin User",
    "username": "admin",
    "password": "secure_password",
    "role": "admin"
  }'
```

---

### GET /api/committee/candidates

Get all candidates for the election.

**Authentication**: Not required

**Request**:

```bash
curl http://localhost:3000/api/committee/candidates
```

**Response**:

```json
{
  "candidates": [
    {
      "name": "John Smith",
      "code": 101,
      "party": "Democratic Party",
      "acronym": "DEM",
      "status": "active"
    },
    {
      "name": "Jane Doe",
      "code": 102,
      "party": "Republican Party",
      "acronym": "REP",
      "status": "active"
    }
  ],
  "note": "Request accepted ..."
}
```

---

### POST /api/committee/deploy-announcement

Deploy election announcement with parameters.

| Name              | Type              | Required? | Default | Description               | Example                |
| ----------------- | ----------------- | --------- | ------- | ------------------------- | ---------------------- |
| `startTimeVoting` | string (ISO 8601) | Yes       | -       | Voting start time         | `2025-11-05T08:00:00Z` |
| `endTimeVoting`   | string (ISO 8601) | Yes       | -       | Voting end time           | `2025-11-05T20:00:00Z` |
| `dateResults`     | string (ISO 8601) | Yes       | -       | Results publication date  | `2025-11-06T00:00:00Z` |
| `numOfCandidates` | number            | Yes       | -       | Number of candidates      | `4`                    |
| `numOfVoters`     | number            | Yes       | -       | Expected number of voters | `10000`                |

**Request**:

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

**Response**:

```json
{
  "note": "Request accepted, announcement deployed."
}
```

---

### GET /api/committee/announcement

Get current election announcement.

**Request**:

```bash
curl http://localhost:3000/api/committee/announcement
```

**Response**:

```json
{
  "announcement": {
    "startTimeVoting": "2025-11-05T08:00:00Z",
    "endTimeVoting": "2025-11-05T20:00:00Z",
    "dateResults": "2025-11-06T00:00:00Z",
    "numOfCandidates": 4,
    "numOfVoters": 10000,
    "status": "active"
  },
  "note": "Request accepted ..."
}
```

---

### GET /api/committee/users

Get all committee users.

**Authentication**: Required

**Request**:

```bash
curl http://localhost:3000/api/committee/users
```

---

### GET /api/committee/voter-identifiers

Get all generated voter identifiers.

**Authentication**: Required

**Request**:

```bash
curl http://localhost:3000/api/committee/voter-identifiers
```

---

## Response Format

### Success Response

All successful API responses follow this format:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "timestamp": "2025-12-30T10:30:00.000Z"
}
```

### Error Response

All error responses follow this format:

```json
{
  "success": false,
  "message": "Error description",
  "details": "Additional error information (dev mode only)",
  "timestamp": "2025-12-30T10:30:00.000Z"
}
```

---

## Error Handling

### Common HTTP Status Codes

| Status Code | Meaning               | Common Causes                     |
| ----------- | --------------------- | --------------------------------- |
| 200         | OK                    | Request successful                |
| 201         | Created               | Resource created successfully     |
| 400         | Bad Request           | Missing or invalid parameters     |
| 401         | Unauthorized          | Missing or invalid authentication |
| 404         | Not Found             | Resource not found                |
| 500         | Internal Server Error | Server-side error                 |

### Error Examples

**400 Bad Request**:

```json
{
  "success": false,
  "message": "Missing required field: identifier",
  "timestamp": "2025-12-30T10:30:00.000Z"
}
```

**401 Unauthorized**:

```json
{
  "success": false,
  "message": "Invalid electoral identifier",
  "timestamp": "2025-12-30T10:30:00.000Z"
}
```

**404 Not Found**:

```json
{
  "success": false,
  "message": "Block not found",
  "timestamp": "2025-12-30T10:30:00.000Z"
}
```

**500 Internal Server Error**:

```json
{
  "success": false,
  "message": "Internal server error",
  "details": "Database connection failed (dev mode only)",
  "timestamp": "2025-12-30T10:30:00.000Z"
}
```

---

## Rate Limiting

Currently, there is no rate limiting implemented. In production, consider implementing rate limiting to prevent abuse.

---

## Pagination

Currently, pagination is not implemented. All endpoints return complete datasets. For large datasets, consider implementing pagination in future versions.

---

## Versioning

API version is currently `v1` (implicit). Future versions will use URL versioning:

- Current: `/api/blockchain/chain`
- Future: `/api/v2/blockchain/chain`

---

_For usage examples, see [USAGE.md](USAGE.md). For endpoint implementation details, see the backend source code._
