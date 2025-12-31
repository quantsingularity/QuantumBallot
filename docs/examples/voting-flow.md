# Example: Complete Voting Flow

This example demonstrates the complete voting flow from voter perspective.

---

## Overview

This example shows:

1. Voter registration
2. Authentication
3. Viewing candidates
4. Casting a vote
5. Vote verification

**Technologies**: Mobile app (React Native), Backend API (Node.js)

---

## Prerequisites

- Backend running at `http://localhost:3000`
- Mobile app running with Expo
- Election configured with candidates
- Voter identifiers generated

---

## Step 1: Voter Registration

### Mobile App Code

```typescript
// mobile-frontend/src/services/auth.ts
import axios from "axios";
import * as SecureStore from "expo-secure-store";

const API_URL = "http://192.168.1.100:3000/api";

export async function registerVoter(
  electoralId: string,
  pin: string,
  email: string,
) {
  try {
    // 1. Validate electoral ID with backend
    const response = await axios.post(`${API_URL}/committee/validate-voter`, {
      electoralId,
    });

    if (!response.data.valid) {
      throw new Error("Invalid electoral ID");
    }

    // 2. Store credentials securely
    await SecureStore.setItemAsync("electoralId", electoralId);
    await SecureStore.setItemAsync("pin", pin);
    await SecureStore.setItemAsync("email", email);

    // 3. Send verification email
    await axios.post(`${API_URL}/committee/send-otp`, {
      email,
      electoralId,
    });

    return { success: true, message: "Verification email sent" };
  } catch (error: any) {
    throw new Error(error.response?.data?.message || "Registration failed");
  }
}
```

### Usage in Component

```tsx
// mobile-frontend/src/screens/Auth/RegisterScreen.tsx
import React, { useState } from "react";
import { View, Text, TextInput, Button, Alert } from "react-native";
import { registerVoter } from "../../services/auth";

export const RegisterScreen = ({ navigation }) => {
  const [electoralId, setElectoralId] = useState("");
  const [pin, setPin] = useState("");
  const [email, setEmail] = useState("");

  const handleRegister = async () => {
    try {
      await registerVoter(electoralId, pin, email);
      Alert.alert("Success", "Verification email sent. Check your inbox.");
      navigation.navigate("VerifyOTP");
    } catch (error: any) {
      Alert.alert("Error", error.message);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Register to Vote</Text>

      <TextInput
        placeholder="Electoral ID"
        value={electoralId}
        onChangeText={setElectoralId}
        style={styles.input}
      />

      <TextInput
        placeholder="Create PIN (4 digits)"
        value={pin}
        onChangeText={setPin}
        secureTextEntry
        maxLength={4}
        keyboardType="numeric"
        style={styles.input}
      />

      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        style={styles.input}
      />

      <Button title="Register" onPress={handleRegister} />
    </View>
  );
};
```

---

## Step 2: Authentication

### Login with PIN

```typescript
// mobile-frontend/src/services/auth.ts
export async function loginVoter(electoralId: string, pin: string) {
  try {
    // 1. Get stored credentials
    const storedId = await SecureStore.getItemAsync("electoralId");
    const storedPin = await SecureStore.getItemAsync("pin");

    // 2. Validate credentials
    if (storedId !== electoralId || storedPin !== pin) {
      throw new Error("Invalid credentials");
    }

    // 3. Get voter identifier from backend
    const response = await axios.post(`${API_URL}/committee/get-identifier`, {
      electoralId,
    });

    const { identifier } = response.data;

    // 4. Store session
    await SecureStore.setItemAsync("voterIdentifier", identifier);
    await SecureStore.setItemAsync("isAuthenticated", "true");

    return { success: true, identifier };
  } catch (error: any) {
    throw new Error("Login failed");
  }
}
```

### Biometric Authentication (Optional)

```typescript
import * as LocalAuthentication from "expo-local-authentication";

export async function loginWithBiometric() {
  try {
    // 1. Check if biometric is available
    const hasHardware = await LocalAuthentication.hasHardwareAsync();
    const isEnrolled = await LocalAuthentication.isEnrolledAsync();

    if (!hasHardware || !isEnrolled) {
      throw new Error("Biometric authentication not available");
    }

    // 2. Authenticate
    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: "Authenticate to vote",
      fallbackLabel: "Use PIN",
    });

    if (!result.success) {
      throw new Error("Authentication failed");
    }

    // 3. Get stored credentials
    const electoralId = await SecureStore.getItemAsync("electoralId");
    const identifier = await SecureStore.getItemAsync("voterIdentifier");

    return { success: true, identifier };
  } catch (error: any) {
    throw new Error(error.message);
  }
}
```

---

## Step 3: View Candidates

### Fetch Candidates

```typescript
// mobile-frontend/src/services/api.ts
export async function getCandidates() {
  try {
    const response = await axios.get(`${API_URL}/committee/candidates`);
    return response.data.candidates;
  } catch (error) {
    throw new Error("Failed to fetch candidates");
  }
}
```

### Display Candidates

```tsx
// mobile-frontend/src/screens/Candidates/CandidatesScreen.tsx
import React, { useEffect, useState } from "react";
import { View, FlatList, StyleSheet } from "react-native";
import { getCandidates } from "../../services/api";
import { CandidateCard } from "../../components/CandidateCard";

export const CandidatesScreen = () => {
  const [candidates, setCandidates] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadCandidates();
  }, []);

  const loadCandidates = async () => {
    try {
      const data = await getCandidates();
      setCandidates(data);
    } catch (error: any) {
      Alert.alert("Error", error.message);
    } finally {
      setLoading(false);
    }
  };

  const renderCandidate = ({ item }) => (
    <CandidateCard
      name={item.name}
      party={item.party}
      acronym={item.acronym}
      code={item.code}
    />
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={candidates}
        renderItem={renderCandidate}
        keyExtractor={(item) => item.code.toString()}
        refreshing={loading}
        onRefresh={loadCandidates}
      />
    </View>
  );
};
```

---

## Step 4: Cast Vote

### Vote Submission Service

```typescript
// mobile-frontend/src/services/voting.ts
import * as SecureStore from "expo-secure-store";
import axios from "axios";

export async function castVote(candidateCode: number) {
  try {
    // 1. Get voter identifier
    const electoralId = await SecureStore.getItemAsync("electoralId");
    if (!electoralId) {
      throw new Error("Not authenticated");
    }

    // 2. Submit vote transaction
    const response = await axios.post(`${API_URL}/blockchain/transaction`, {
      identifier: electoralId,
      choiceCode: candidateCode,
    });

    if (!response.data.success) {
      throw new Error(response.data.message);
    }

    // 3. Store vote confirmation
    await SecureStore.setItemAsync("hasVoted", "true");
    await SecureStore.setItemAsync(
      "voteConfirmation",
      JSON.stringify(response.data.data),
    );

    return {
      success: true,
      transactionId: response.data.data.transactionId,
      timestamp: response.data.data.timestamp,
    };
  } catch (error: any) {
    throw new Error(error.response?.data?.message || "Vote submission failed");
  }
}
```

### Voting Screen

```tsx
// mobile-frontend/src/screens/Voting/VotingScreen.tsx
import React, { useState } from "react";
import { View, Text, Alert } from "react-native";
import { castVote } from "../../services/voting";

export const VotingScreen = ({ route, navigation }) => {
  const { candidate } = route.params;
  const [confirming, setConfirming] = useState(false);

  const handleConfirmVote = async () => {
    Alert.alert(
      "Confirm Your Vote",
      `Are you sure you want to vote for ${candidate.name} (${candidate.party})?`,
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Confirm",
          onPress: async () => {
            setConfirming(true);
            try {
              const result = await castVote(candidate.code);

              Alert.alert(
                "Vote Cast Successfully!",
                `Transaction ID: ${result.transactionId.substring(0, 10)}...`,
                [
                  {
                    text: "OK",
                    onPress: () =>
                      navigation.navigate("Confirmation", { result }),
                  },
                ],
              );
            } catch (error: any) {
              Alert.alert("Error", error.message);
            } finally {
              setConfirming(false);
            }
          },
        },
      ],
    );
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Confirm Your Vote</Text>

      <View style={styles.candidateInfo}>
        <Text style={styles.candidateName}>{candidate.name}</Text>
        <Text style={styles.party}>{candidate.party}</Text>
        <Text style={styles.code}>Candidate Code: {candidate.code}</Text>
      </View>

      <Button
        title={confirming ? "Submitting..." : "Cast Vote"}
        onPress={handleConfirmVote}
        disabled={confirming}
      />

      <Text style={styles.warning}>
        ⚠️ This action cannot be undone. You can only vote once.
      </Text>
    </View>
  );
};
```

---

## Step 5: Vote Verification

### Verify Vote Transaction

```typescript
// mobile-frontend/src/services/voting.ts
export async function verifyVote() {
  try {
    // 1. Get vote confirmation
    const confirmation = await SecureStore.getItemAsync("voteConfirmation");
    if (!confirmation) {
      throw new Error("No vote found");
    }

    const { transactionId } = JSON.parse(confirmation);

    // 2. Query blockchain for transaction
    const response = await axios.get(`${API_URL}/blockchain/transactions`);

    const transaction = response.data.data.find(
      (tx: any) => tx.transactionId === transactionId,
    );

    if (!transaction) {
      return { verified: false, status: "pending" };
    }

    return {
      verified: true,
      status: "confirmed",
      blockIndex: transaction.blockIndex,
      timestamp: transaction.timestamp,
    };
  } catch (error) {
    throw new Error("Verification failed");
  }
}
```

### Verification Screen

```tsx
// mobile-frontend/src/screens/Profile/VerificationScreen.tsx
import React, { useEffect, useState } from "react";
import { View, Text, ActivityIndicator } from "react-native";
import { verifyVote } from "../../services/voting";

export const VerificationScreen = () => {
  const [verification, setVerification] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkVerification();
  }, []);

  const checkVerification = async () => {
    try {
      const result = await verifyVote();
      setVerification(result);
    } catch (error: any) {
      Alert.alert("Error", error.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <ActivityIndicator size="large" />;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Vote Verification</Text>

      {verification?.verified ? (
        <View style={styles.verified}>
          <Text style={styles.statusIcon}>✅</Text>
          <Text style={styles.status}>Vote Confirmed</Text>
          <Text>Block: {verification.blockIndex}</Text>
          <Text>Status: {verification.status}</Text>
          <Text>
            Timestamp: {new Date(verification.timestamp).toLocaleString()}
          </Text>
        </View>
      ) : (
        <View style={styles.pending}>
          <Text style={styles.statusIcon}>⏳</Text>
          <Text style={styles.status}>Vote Pending</Text>
          <Text>Your vote is being processed...</Text>
        </View>
      )}

      <Button title="Refresh" onPress={checkVerification} />
    </View>
  );
};
```

---

## Complete Flow Diagram

```
┌─────────────────┐
│  1. Register    │
│  Electoral ID   │
│  PIN, Email     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  2. Verify OTP  │
│  Email OTP      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  3. Login       │
│  PIN/Biometric  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  4. View        │
│  Candidates     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  5. Select      │
│  Candidate      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  6. Confirm     │
│  Vote Choice    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  7. Submit to   │
│  Blockchain     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  8. Verify      │
│  Transaction    │
└─────────────────┘
```

---

## Testing the Flow

### Manual Test

```bash
# 1. Start backend
cd backend
npm run dev

# 2. Start mobile app
cd mobile-frontend
npm start

# 3. Scan QR with Expo Go

# 4. Follow registration flow in app

# 5. Verify vote in backend
curl http://localhost:3000/api/blockchain/transactions
```

### Automated Test

```typescript
// mobile-frontend/__tests__/voting-flow.test.ts
describe("Voting Flow", () => {
  it("completes full voting flow", async () => {
    // 1. Register
    await registerVoter("TEST123", "1234", "test@example.com");

    // 2. Login
    const auth = await loginVoter("TEST123", "1234");
    expect(auth.success).toBe(true);

    // 3. Get candidates
    const candidates = await getCandidates();
    expect(candidates.length).toBeGreaterThan(0);

    // 4. Cast vote
    const vote = await castVote(candidates[0].code);
    expect(vote.success).toBe(true);

    // 5. Verify
    const verification = await verifyVote();
    expect(verification.verified).toBe(true);
  });
});
```

---

## Next Steps

- See [election-setup.md](election-setup.md) for committee setup
- See [blockchain-query.md](blockchain-query.md) for blockchain exploration
- See [API.md](../API.md) for complete API reference

---

_This example is part of the QuantumBallot documentation. For more examples, see [examples/](../examples/)._
