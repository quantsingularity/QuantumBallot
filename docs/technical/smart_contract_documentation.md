# QuantumBallot Smart Contract Technical Documentation

## Overview

This document provides comprehensive technical documentation for the enhanced QuantumBallot smart contract system. The system has been redesigned with a focus on security, robust voting mechanisms, and transparent governance. This documentation is intended for developers who need to understand, maintain, or extend the smart contract functionality.

## Architecture

The QuantumBallot smart contract system is implemented in Rust and consists of several key components:

1. **Core Contract Structure**: The `ElectionContract` struct serves as the main container for the contract state, providing thread-safe access to all components.
2. **State Management**: Election states are managed through a state machine pattern with clear transitions.
3. **Access Control**: Role-based access control restricts sensitive operations to authorized users.
4. **Event System**: A comprehensive event system tracks all important state changes for transparency and auditability.
5. **Error Handling**: Custom error types provide detailed information about operation failures.
6. **Timelock Governance**: Critical actions are subject to a timelock delay for security.
7. **Voting Mechanisms**: Enhanced voting includes quadratic voting, delegation, and transparent counting.
8. **Sybil Resistance**: Multiple mechanisms work together to prevent Sybil attacks.

## Data Structures

### Core Structures

#### ElectionState

```rust
pub enum ElectionState {
    Announced,
    Started,
    Happening,
    Ended,
}
```

Represents the current state of an election, controlling which operations are allowed.

#### Role

```rust
pub enum Role {
    Admin,
    Voter,
    Delegate,
    Observer,
}
```

Defines the roles users can have in the system, used for access control.

#### User

```rust
pub struct User {
    pub identifier: String,
    pub roles: Vec<Role>,
    pub reputation_score: u64,
    pub verified: bool,
    pub identity_proof: String,
    pub social_graph_score: u64,
    pub registration_time: u64,
}
```

Stores user information with Sybil resistance attributes.

#### Candidate

```rust
pub struct Candidate {
    pub name: String,
    pub num_votes: u64,
    pub code: u64,
    pub description: String,
    pub created_at: u64,
    pub created_by: String,
    pub proposal_hash: String,
    pub proposal_url: String,
}
```

Represents a candidate in an election with proposal verification.

#### Voter

```rust
pub struct Voter {
    pub identifier: String,
    pub choice_code: u64,
    pub has_voted: bool,
    pub voting_power: f64,
    pub last_vote_time: u64,
    pub delegated_to: Option<String>,
    pub delegated_from: Vec<String>,
    pub vote_weight: f64,
}
```

Stores voter information with delegation and quadratic voting support.

#### Event

```rust
pub struct Event {
    pub event_type: String,
    pub timestamp: u64,
    pub data: String,
    pub emitted_by: String,
    pub block_number: Option<u64>,
    pub transaction_hash: Option<String>,
}
```

Records important state changes for transparency.

#### TimelockAction

```rust
pub struct TimelockAction {
    pub action_type: String,
    pub description: String,
    pub proposed_by: String,
    pub proposed_at: u64,
    pub execution_time: u64,
    pub executed: bool,
    pub canceled: bool,
    pub data: String,
}
```

Represents a governance action subject to a timelock delay.

#### VoteRecord

```rust
pub struct VoteRecord {
    pub voter_id: String,
    pub candidate_code: u64,
    pub timestamp: u64,
    pub weight: f64,
    pub vote_hash: String,
}
```

Records vote details for transparent counting and verification.

#### ContractConfig

```rust
pub struct ContractConfig {
    pub candidate_data_url: String,
    pub voter_data_url: String,
    pub min_reputation_score: u64,
    pub max_votes_per_period: u64,
    pub voting_period_seconds: u64,
    pub emergency_stop: bool,
    pub timelock_delay: u64,
    pub min_social_graph_score: u64,
    pub min_account_age_seconds: u64,
    pub quadratic_voting_enabled: bool,
    pub delegation_enabled: bool,
}
```

Configurable parameters for the contract.

### Error Handling

The contract uses a custom error type for detailed error reporting:

```rust
pub enum ContractError {
    AccessDenied(String),
    InvalidInput(String),
    OperationFailed(String),
    StateError(String),
    ExternalResourceError(String),
    DatabaseError(String),
    TimelockError(String),
}
```

## Core Functions

### Contract Initialization

```rust
pub fn new(admin_address: String) -> Self
pub fn with_config(admin_address: String, config: ContractConfig) -> Self
```

These functions initialize the contract with default or custom configuration.

### Election Management

```rust
pub fn announce_election(&self, caller: &str) -> ContractResult<()>
pub fn start_election(&self, caller: &str) -> ContractResult<()>
pub fn end_election(&self, caller: &str) -> ContractResult<()>
```

These functions manage the election lifecycle, with appropriate state transitions and access control.

### Candidate Management

```rust
pub fn add_candidate(&self, caller: &str, name: &str, code: u64, description: &str, proposal_url: &str) -> ContractResult<()>
```

Adds a candidate to the election with validation and proposal verification.

### User and Voter Management

```rust
pub fn register_user(&self, caller: &str, user_id: &str, identity_proof: &str, social_graph_score: u64) -> ContractResult<()>
pub fn register_voter(&self, caller: &str, voter_id: &str) -> ContractResult<()>
```

Registers users and voters with Sybil resistance checks.

### Voting Functions

```rust
pub fn delegate_vote(&self, voter_id: &str, delegate_id: &str) -> ContractResult<()>
pub fn place_vote(&self, voter_id: &str, candidate_code: u64) -> ContractResult<()>
pub fn verify_vote(&self, voter_id: &str) -> ContractResult<bool>
```

Handles vote delegation, casting, and verification.

### Timelock Governance

```rust
pub fn propose_timelock_action(&self, caller: &str, action_type: &str, description: &str, data: &str) -> ContractResult<()>
pub fn execute_timelock_action(&self, caller: &str, index: usize) -> ContractResult<()>
pub fn cancel_timelock_action(&self, caller: &str, index: usize) -> ContractResult<()>
```

Manages timelock actions for critical governance operations.

### Emergency Controls

```rust
pub fn emergency_stop(&self, caller: &str) -> ContractResult<()>
pub fn resume_operations(&self, caller: &str) -> ContractResult<()>
```

Implements the circuit breaker pattern for emergency situations.

### Query Functions

```rust
pub fn winning_candidate(&self) -> ContractResult<Option<Candidate>>
pub fn get_all_candidates(&self) -> ContractResult<Vec<Candidate>>
pub fn get_all_voters(&self) -> ContractResult<Vec<Voter>>
pub fn get_election_state(&self) -> ContractResult<ElectionState>
pub fn get_events(&self) -> ContractResult<Vec<Event>>
pub fn get_vote_records(&self) -> ContractResult<Vec<VoteRecord>>
pub fn get_pending_timelocks(&self) -> ContractResult<Vec<TimelockAction>>
```

Provides read-only access to contract state.

### External Data Loading

```rust
pub async fn load_candidate_data(&self, caller: &str) -> Result<(), Error>
pub async fn load_voter_data(&self, caller: &str) -> Result<(), Error>
```

Loads candidate and voter data from external sources with proper error handling.

## Security Features

### Access Control

The contract implements role-based access control to restrict sensitive operations to authorized users. The `is_admin` helper function checks if the caller has admin privileges:

```rust
fn is_admin(&self, caller: &str) -> bool {
    let admin = self.admin.lock().unwrap();
    *admin == caller
}
```

This check is used throughout the contract to protect administrative functions.

### Input Validation

All user inputs are validated before processing to prevent invalid data from corrupting the contract state:

```rust
// Example from add_candidate
if name.trim().is_empty() {
    return Err(ContractError::InvalidInput(
        "Candidate name cannot be empty".to_string()
    ));
}
```

### State Validation

Operations are checked against the current election state to ensure they are only performed at appropriate times:

```rust
// Example from start_election
let mut state = self.state.lock().unwrap();
if *state != ElectionState::Announced {
    return Err(ContractError::StateError(
        "Election must be in Announced state to start".to_string()
    ));
}
```

### Integer Overflow Protection

The contract uses Rust's checked arithmetic to prevent integer overflow:

```rust
// Example from place_vote
match candidate.num_votes.checked_add(vote_weight_rounded) {
    Some(new_count) => candidate.num_votes = new_count,
    None => return Err(ContractError::OperationFailed(
        "Vote count overflow".to_string()
    )),
}
```

### Emergency Stop

The contract implements a circuit breaker pattern to halt operations in emergency situations:

```rust
fn check_emergency_stop(&self) -> ContractResult<()> {
    let config = self.config.lock().unwrap();
    if config.emergency_stop {
        return Err(ContractError::StateError(
            "Contract is in emergency stop mode".to_string()
        ));
    }
    Ok(())
}
```

### Rate Limiting

The contract implements rate limiting to prevent abuse:

```rust
// Example from place_vote
if current_time - voter.last_vote_time < config.voting_period_seconds {
    return Err(ContractError::OperationFailed(
        format!("Rate limit exceeded, please try again later")
    ));
}
```

### Timelock for Critical Actions

Critical governance actions are subject to a timelock delay:

```rust
// Example from execute_timelock_action
if current_time < action.execution_time {
    return Err(ContractError::TimelockError(
        format!("Timelock action not yet executable, wait until {}", action.execution_time)
    ));
}
```

## Voting Mechanisms

### Quadratic Voting

The contract implements quadratic voting, where voting power is calculated as the square root of a user's reputation score:

```rust
// Example from register_voter
let voting_power = if config.quadratic_voting_enabled {
    (user.reputation_score as f64).sqrt()
} else {
    1.0 // Default voting power if quadratic voting is disabled
};
```

This mechanism reduces the impact of wealth concentration by making each additional vote more expensive.

### Vote Delegation

Users can delegate their voting power to other users:

```rust
pub fn delegate_vote(&self, voter_id: &str, delegate_id: &str) -> ContractResult<()>
```

The delegation system includes checks for circular delegation and updates vote weights accordingly.

### Transparent Vote Counting

All votes are recorded with cryptographic hashes for verification:

```rust
// Example from place_vote
let vote_data = format!("{}:{}:{}", voter_id, candidate_code, current_time);
let vote_hash = self.create_hash(&vote_data);

let vote_record = VoteRecord {
    voter_id: voter_id.to_string(),
    candidate_code,
    timestamp: current_time,
    weight: vote_weight,
    vote_hash,
};
```

Users can verify their votes were counted correctly:

```rust
pub fn verify_vote(&self, voter_id: &str) -> ContractResult<bool>
```

## Sybil Resistance

The contract implements multiple mechanisms to prevent Sybil attacks:

### Reputation Scores

Users must have a minimum reputation score to participate:

```rust
// Example from register_user
if social_graph_score < config.min_social_graph_score {
    return Err(ContractError::InvalidInput(
        format!("Social graph score too low, minimum required: {}", config.min_social_graph_score)
    ));
}
```

### Account Age Requirements

New accounts are restricted from voting until they reach a minimum age:

```rust
// Example from register_voter
if current_time - user.registration_time < config.min_account_age_seconds {
    return Err(ContractError::InvalidInput(
        format!("Account too new, minimum age required: {} seconds", config.min_account_age_seconds)
    ));
}
```

### Identity Verification

Users must provide identity proofs that can be verified:

```rust
// In User struct
pub identity_proof: String,
```

### Social Graph Analysis

The contract uses social graph scores to detect fake accounts:

```rust
// In User struct
pub social_graph_score: u64,
```

## Event System

The contract emits events for all important state changes:

```rust
fn emit_event(&self, event_type: &str, data: &str, emitted_by: &str)
```

Events include:

- ElectionAnnounced
- ElectionStarted
- ElectionEnded
- CandidateAdded
- UserRegistered
- VoterRegistered
- VoteDelegated
- VoteCast
- TimelockProposed
- TimelockExecuted
- TimelockCanceled
- EmergencyStop
- ResumeOperations

## Integration Guidelines

### Contract Initialization

To initialize the contract:

```rust
let contract = ElectionContract::new("admin_address".to_string());
```

Or with custom configuration:

```rust
let config = ContractConfig {
    timelock_delay: 86400, // 24 hours
    quadratic_voting_enabled: true,
    delegation_enabled: true,
    // Other configuration options
    ..ContractConfig::default()
};
let contract = ElectionContract::with_config("admin_address".to_string(), config);
```

### Election Lifecycle

A typical election lifecycle:

1. Announce the election:

   ```rust
   contract.announce_election("admin_address")?;
   ```

2. Register users and voters:

   ```rust
   contract.register_user("admin_address", "user1", "identity_proof", 20)?;
   contract.register_voter("admin_address", "user1")?;
   ```

3. Add candidates:

   ```rust
   contract.add_candidate("admin_address", "Candidate 1", 1, "Description", "https://example.com/proposal1")?;
   ```

4. Start the election:

   ```rust
   contract.start_election("admin_address")?;
   ```

5. Users vote or delegate:

   ```rust
   contract.delegate_vote("user1", "user2")?;
   // or
   contract.place_vote("user1", 1)?;
   ```

6. End the election:

   ```rust
   contract.end_election("admin_address")?;
   ```

7. Get the results:
   ```rust
   let winner = contract.winning_candidate()?;
   ```

## Error Handling

All contract functions return a `ContractResult<T>` which should be properly handled:

```rust
match contract.place_vote("user1", 1) {
    Ok(_) => println!("Vote placed successfully"),
    Err(e) => println!("Error placing vote: {}", e),
}
```

## Conclusion

The enhanced QuantumBallot smart contract system provides a secure, transparent, and fair platform for decentralized governance. By implementing robust security measures, advanced voting mechanisms, and comprehensive Sybil resistance, the system ensures that governance decisions reflect the true will of the community while protecting against common vulnerabilities and attacks.

For further assistance or to report issues, please contact the QuantumBallot development team.
