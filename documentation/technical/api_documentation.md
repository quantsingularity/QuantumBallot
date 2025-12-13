# API Documentation for QuantumBallot Smart Contract

## Overview

This document provides comprehensive API documentation for the enhanced QuantumBallot smart contract system. It details all public functions, their parameters, return values, and potential errors to help developers integrate with and extend the system.

## Core API Functions

### Contract Initialization

#### `new(admin_address: String) -> ElectionContract`

Creates a new election contract with default configuration.

**Parameters:**

- `admin_address`: String - The address of the contract administrator

**Returns:**

- A new `ElectionContract` instance

**Example:**

```rust
let contract = ElectionContract::new("admin_address".to_string());
```

#### `with_config(admin_address: String, config: ContractConfig) -> ElectionContract`

Creates a new election contract with custom configuration.

**Parameters:**

- `admin_address`: String - The address of the contract administrator
- `config`: ContractConfig - Custom configuration parameters

**Returns:**

- A new `ElectionContract` instance with custom configuration

**Example:**

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

### Election Management

#### `announce_election(caller: &str) -> ContractResult<()>`

Announces a new election, setting the state to Announced.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin
- `StateError` - If contract is in emergency stop mode

**Example:**

```rust
match contract.announce_election("admin_address") {
    Ok(_) => println!("Election announced successfully"),
    Err(e) => println!("Error announcing election: {}", e),
}
```

#### `start_election(caller: &str) -> ContractResult<()>`

Starts an announced election, setting the state to Started.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin
- `StateError` - If election is not in Announced state or contract is in emergency stop mode

**Example:**

```rust
match contract.start_election("admin_address") {
    Ok(_) => println!("Election started successfully"),
    Err(e) => println!("Error starting election: {}", e),
}
```

#### `end_election(caller: &str) -> ContractResult<()>`

Ends an ongoing election, setting the state to Ended.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin
- `StateError` - If election is not in Started or Happening state or contract is in emergency stop mode

**Example:**

```rust
match contract.end_election("admin_address") {
    Ok(_) => println!("Election ended successfully"),
    Err(e) => println!("Error ending election: {}", e),
}
```

### Candidate Management

#### `add_candidate(caller: &str, name: &str, code: u64, description: &str, proposal_url: &str) -> ContractResult<()>`

Adds a candidate to the election.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)
- `name`: &str - The name of the candidate
- `code`: u64 - Unique identifier for the candidate
- `description`: &str - Description of the candidate
- `proposal_url`: &str - URL to the candidate's proposal

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin
- `StateError` - If election is not in Announced state or contract is in emergency stop mode
- `InvalidInput` - If name is empty or candidate code already exists

**Example:**

```rust
match contract.add_candidate("admin_address", "Candidate 1", 1, "Description for Candidate 1", "https://example.com/proposal1") {
    Ok(_) => println!("Candidate added successfully"),
    Err(e) => println!("Error adding candidate: {}", e),
}
```

### User and Voter Management

#### `register_user(caller: &str, user_id: &str, identity_proof: &str, social_graph_score: u64) -> ContractResult<()>`

Registers a user with Sybil resistance attributes.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)
- `user_id`: &str - Unique identifier for the user
- `identity_proof`: &str - Proof of user's identity
- `social_graph_score`: u64 - User's social graph score for Sybil resistance

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin
- `InvalidInput` - If user_id is empty, social graph score is too low, or user already exists
- `StateError` - If contract is in emergency stop mode

**Example:**

```rust
match contract.register_user("admin_address", "user1", "identity_proof_hash", 20) {
    Ok(_) => println!("User registered successfully"),
    Err(e) => println!("Error registering user: {}", e),
}
```

#### `register_voter(caller: &str, voter_id: &str) -> ContractResult<()>`

Registers a user as a voter for the election.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)
- `voter_id`: &str - Unique identifier for the voter (must be a registered user)

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin
- `StateError` - If election is not in Announced or Started state or contract is in emergency stop mode
- `InvalidInput` - If user does not exist, is not verified, account is too new, or voter already registered

**Example:**

```rust
match contract.register_voter("admin_address", "user1") {
    Ok(_) => println!("Voter registered successfully"),
    Err(e) => println!("Error registering voter: {}", e),
}
```

### Voting Functions

#### `delegate_vote(voter_id: &str, delegate_id: &str) -> ContractResult<()>`

Delegates a voter's voting power to another voter.

**Parameters:**

- `voter_id`: &str - The ID of the voter delegating their vote
- `delegate_id`: &str - The ID of the voter receiving the delegation

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `StateError` - If election is not in Started or Happening state or contract is in emergency stop mode
- `InvalidInput` - If either voter does not exist, voter has already voted, or circular delegation is detected
- `OperationFailed` - If delegation is disabled in configuration

**Example:**

```rust
match contract.delegate_vote("voter1", "voter2") {
    Ok(_) => println!("Vote delegated successfully"),
    Err(e) => println!("Error delegating vote: {}", e),
}
```

#### `place_vote(voter_id: &str, candidate_code: u64) -> ContractResult<()>`

Places a vote for a candidate.

**Parameters:**

- `voter_id`: &str - The ID of the voter
- `candidate_code`: u64 - The code of the candidate to vote for

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `StateError` - If election is not in Started or Happening state or contract is in emergency stop mode
- `InvalidInput` - If voter does not exist, has already voted, or candidate does not exist
- `OperationFailed` - If rate limit is exceeded, voting power is too low, or vote count would overflow

**Example:**

```rust
match contract.place_vote("voter1", 1) {
    Ok(_) => println!("Vote placed successfully"),
    Err(e) => println!("Error placing vote: {}", e),
}
```

#### `verify_vote(voter_id: &str) -> ContractResult<bool>`

Verifies that a voter's vote was correctly recorded.

**Parameters:**

- `voter_id`: &str - The ID of the voter

**Returns:**

- `Ok(true)` if vote is verified
- `Ok(false)` if vote is not found or verification fails
- `Err(ContractError)` on failure

**Example:**

```rust
match contract.verify_vote("voter1") {
    Ok(true) => println!("Vote verified successfully"),
    Ok(false) => println!("Vote verification failed"),
    Err(e) => println!("Error verifying vote: {}", e),
}
```

### Timelock Governance

#### `propose_timelock_action(caller: &str, action_type: &str, description: &str, data: &str) -> ContractResult<()>`

Proposes a timelock action for critical governance changes.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)
- `action_type`: &str - Type of action (e.g., "ChangeAdmin", "UpdateConfig")
- `description`: &str - Description of the action
- `data`: &str - Data required for the action

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin
- `StateError` - If contract is in emergency stop mode

**Example:**

```rust
match contract.propose_timelock_action("admin_address", "ChangeAdmin", "Change admin to new address", "new_admin_address") {
    Ok(_) => println!("Timelock action proposed successfully"),
    Err(e) => println!("Error proposing timelock action: {}", e),
}
```

#### `execute_timelock_action(caller: &str, index: usize) -> ContractResult<()>`

Executes a proposed timelock action after the delay period.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)
- `index`: usize - Index of the timelock action to execute

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin
- `InvalidInput` - If index is out of bounds
- `TimelockError` - If action is already executed, canceled, or delay period has not passed
- `StateError` - If contract is in emergency stop mode

**Example:**

```rust
match contract.execute_timelock_action("admin_address", 0) {
    Ok(_) => println!("Timelock action executed successfully"),
    Err(e) => println!("Error executing timelock action: {}", e),
}
```

#### `cancel_timelock_action(caller: &str, index: usize) -> ContractResult<()>`

Cancels a proposed timelock action before execution.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)
- `index`: usize - Index of the timelock action to cancel

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin
- `InvalidInput` - If index is out of bounds
- `TimelockError` - If action is already executed or canceled
- `StateError` - If contract is in emergency stop mode

**Example:**

```rust
match contract.cancel_timelock_action("admin_address", 0) {
    Ok(_) => println!("Timelock action canceled successfully"),
    Err(e) => println!("Error canceling timelock action: {}", e),
}
```

### Emergency Controls

#### `emergency_stop(caller: &str) -> ContractResult<()>`

Activates emergency stop mode to halt contract operations.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin

**Example:**

```rust
match contract.emergency_stop("admin_address") {
    Ok(_) => println!("Emergency stop activated"),
    Err(e) => println!("Error activating emergency stop: {}", e),
}
```

#### `resume_operations(caller: &str) -> ContractResult<()>`

Deactivates emergency stop mode to resume contract operations.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)

**Returns:**

- `Ok(())` on success
- `Err(ContractError)` on failure

**Possible Errors:**

- `AccessDenied` - If caller is not admin

**Example:**

```rust
match contract.resume_operations("admin_address") {
    Ok(_) => println!("Operations resumed"),
    Err(e) => println!("Error resuming operations: {}", e),
}
```

### Query Functions

#### `winning_candidate() -> ContractResult<Option<Candidate>>`

Gets the winning candidate after an election has ended.

**Returns:**

- `Ok(Some(Candidate))` if a winner is determined
- `Ok(None)` if no candidates or tie
- `Err(ContractError)` on failure

**Possible Errors:**

- `StateError` - If election is not in Ended state

**Example:**

```rust
match contract.winning_candidate() {
    Ok(Some(winner)) => println!("Winner: {}", winner),
    Ok(None) => println!("No winner determined"),
    Err(e) => println!("Error getting winner: {}", e),
}
```

#### `get_all_candidates() -> ContractResult<Vec<Candidate>>`

Gets all registered candidates.

**Returns:**

- `Ok(Vec<Candidate>)` - List of all candidates

**Example:**

```rust
match contract.get_all_candidates() {
    Ok(candidates) => {
        println!("Candidates:");
        for candidate in candidates {
            println!("{}", candidate);
        }
    },
    Err(e) => println!("Error getting candidates: {}", e),
}
```

#### `get_all_voters() -> ContractResult<Vec<Voter>>`

Gets all registered voters.

**Returns:**

- `Ok(Vec<Voter>)` - List of all voters

**Example:**

```rust
match contract.get_all_voters() {
    Ok(voters) => {
        println!("Voters:");
        for voter in voters {
            println!("{}", voter);
        }
    },
    Err(e) => println!("Error getting voters: {}", e),
}
```

#### `get_election_state() -> ContractResult<ElectionState>`

Gets the current election state.

**Returns:**

- `Ok(ElectionState)` - Current state of the election

**Example:**

```rust
match contract.get_election_state() {
    Ok(state) => println!("Election state: {:?}", state),
    Err(e) => println!("Error getting election state: {}", e),
}
```

#### `get_events() -> ContractResult<Vec<Event>>`

Gets all recorded events.

**Returns:**

- `Ok(Vec<Event>)` - List of all events

**Example:**

```rust
match contract.get_events() {
    Ok(events) => {
        println!("Events:");
        for event in events {
            println!("{:?}", event);
        }
    },
    Err(e) => println!("Error getting events: {}", e),
}
```

#### `get_vote_records() -> ContractResult<Vec<VoteRecord>>`

Gets all vote records for transparent counting.

**Returns:**

- `Ok(Vec<VoteRecord>)` - List of all vote records

**Example:**

```rust
match contract.get_vote_records() {
    Ok(records) => {
        println!("Vote Records:");
        for record in records {
            println!("{:?}", record);
        }
    },
    Err(e) => println!("Error getting vote records: {}", e),
}
```

#### `get_pending_timelocks() -> ContractResult<Vec<TimelockAction>>`

Gets all pending timelock actions.

**Returns:**

- `Ok(Vec<TimelockAction>)` - List of pending timelock actions

**Example:**

```rust
match contract.get_pending_timelocks() {
    Ok(timelocks) => {
        println!("Pending Timelocks:");
        for timelock in timelocks {
            println!("{:?}", timelock);
        }
    },
    Err(e) => println!("Error getting pending timelocks: {}", e),
}
```

### External Data Loading

#### `load_candidate_data(caller: &str) -> Result<(), Error>`

Loads candidate data from an external source.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)

**Returns:**

- `Ok(())` on success
- `Err(Error)` on failure

**Example:**

```rust
match contract.load_candidate_data("admin_address").await {
    Ok(_) => println!("Candidate data loaded successfully"),
    Err(e) => println!("Error loading candidate data: {}", e),
}
```

#### `load_voter_data(caller: &str) -> Result<(), Error>`

Loads voter data from an external source.

**Parameters:**

- `caller`: &str - The address of the caller (must be admin)

**Returns:**

- `Ok(())` on success
- `Err(Error)` on failure

**Example:**

```rust
match contract.load_voter_data("admin_address").await {
    Ok(_) => println!("Voter data loaded successfully"),
    Err(e) => println!("Error loading voter data: {}", e),
}
```

## Data Structures

### ContractConfig

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

Configuration parameters for the contract.

### ElectionState

```rust
pub enum ElectionState {
    Announced,
    Started,
    Happening,
    Ended,
}
```

Possible states of an election.

### Role

```rust
pub enum Role {
    Admin,
    Voter,
    Delegate,
    Observer,
}
```

Possible roles for users in the system.

### User

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

User information with Sybil resistance attributes.

### Candidate

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

Candidate information with proposal verification.

### Voter

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

Voter information with delegation and quadratic voting support.

### Event

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

Event information for transparency.

### TimelockAction

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

Timelock action information for governance.

### VoteRecord

```rust
pub struct VoteRecord {
    pub voter_id: String,
    pub candidate_code: u64,
    pub timestamp: u64,
    pub weight: f64,
    pub vote_hash: String,
}
```

Vote record information for transparent counting.

### ContractError

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

Possible error types returned by contract operations.

## Error Handling

All contract functions return a `ContractResult<T>` which is defined as:

```rust
type ContractResult<T> = Result<T, ContractError>;
```

This allows for detailed error reporting and proper error handling in client code.

## Conclusion

This API documentation provides a comprehensive reference for integrating with and extending the QuantumBallot smart contract system. By following the examples and understanding the function signatures, parameters, and return values, developers can effectively build applications that interact with the governance platform.

For further assistance or to report issues, please contact the QuantumBallot development team.
