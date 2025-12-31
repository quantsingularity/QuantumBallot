# Example: Election Setup

This example demonstrates how to set up a complete election as a committee member.

---

## Overview

This example shows:

1. Adding candidates
2. Registering citizens
3. Generating voter identifiers
4. Deploying election announcement
5. Monitoring election progress

**Technologies**: Web frontend (React), Backend API (Node.js)

---

## Prerequisites

- Backend running at `http://localhost:3000`
- Web frontend running at `http://localhost:5173`
- Committee member account with authentication

---

## Step 1: Add Candidates

### Using Web UI

1. Navigate to **Elections** → **Manage Candidates**
2. Click **Add Candidate**
3. Fill in the form:
   - Name: Candidate full name
   - Party: Political party
   - Code: Unique numeric code
   - Acronym: Party acronym
   - Status: Active

### Using API Directly

```bash
# Add Candidate 1
curl -X POST http://localhost:3000/api/committee/add-candidate \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Johnson",
    "code": 101,
    "party": "Progressive Democratic Party",
    "acronym": "PDP",
    "status": "active"
  }'

# Add Candidate 2
curl -X POST http://localhost:3000/api/committee/add-candidate \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Bob Martinez",
    "code": 102,
    "party": "Conservative Unity Party",
    "acronym": "CUP",
    "status": "active"
  }'

# Add Candidate 3
curl -X POST http://localhost:3000/api/committee/add-candidate \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Carol Williams",
    "code": 103,
    "party": "Independent Alliance",
    "acronym": "IND",
    "status": "active"
  }'
```

### Using TypeScript/JavaScript

```typescript
// web-frontend/src/services/candidates.ts
import axios from "axios";

const API_URL = import.meta.env.VITE_API_URL;

export interface Candidate {
  name: string;
  code: number;
  party: string;
  acronym: string;
  status: "active" | "inactive";
}

export async function addCandidate(candidate: Candidate) {
  try {
    const response = await axios.post(
      `${API_URL}/committee/add-candidate`,
      candidate,
    );

    return {
      success: true,
      candidates: response.data.candidates,
    };
  } catch (error: any) {
    throw new Error(error.response?.data?.note || "Failed to add candidate");
  }
}

// Usage in component
const candidates: Candidate[] = [
  {
    name: "Alice Johnson",
    code: 101,
    party: "Progressive Democratic Party",
    acronym: "PDP",
    status: "active",
  },
  {
    name: "Bob Martinez",
    code: 102,
    party: "Conservative Unity Party",
    acronym: "CUP",
    status: "active",
  },
  {
    name: "Carol Williams",
    code: 103,
    party: "Independent Alliance",
    acronym: "IND",
    status: "active",
  },
];

// Add all candidates
for (const candidate of candidates) {
  await addCandidate(candidate);
}
```

### React Component Example

```tsx
// web-frontend/src/pages/Candidates/AddCandidateForm.tsx
import React, { useState } from "react";
import { useForm } from "react-hook-form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { addCandidate } from "@/services/candidates";

interface CandidateForm {
  name: string;
  code: number;
  party: string;
  acronym: string;
}

export const AddCandidateForm = () => {
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<CandidateForm>();
  const [loading, setLoading] = useState(false);

  const onSubmit = async (data: CandidateForm) => {
    setLoading(true);
    try {
      await addCandidate({
        ...data,
        status: "active",
      });

      alert("Candidate added successfully!");
      reset();
    } catch (error: any) {
      alert(`Error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label>Candidate Name *</label>
        <Input
          {...register("name", { required: "Name is required" })}
          placeholder="Full name"
        />
        {errors.name && <span className="error">{errors.name.message}</span>}
      </div>

      <div>
        <label>Candidate Code *</label>
        <Input
          type="number"
          {...register("code", {
            required: "Code is required",
            min: { value: 100, message: "Code must be at least 100" },
          })}
          placeholder="e.g., 101"
        />
        {errors.code && <span className="error">{errors.code.message}</span>}
      </div>

      <div>
        <label>Political Party *</label>
        <Input
          {...register("party", { required: "Party is required" })}
          placeholder="Party name"
        />
        {errors.party && <span className="error">{errors.party.message}</span>}
      </div>

      <div>
        <label>Party Acronym</label>
        <Input {...register("acronym")} placeholder="e.g., PDP" maxLength={5} />
      </div>

      <Button type="submit" disabled={loading}>
        {loading ? "Adding..." : "Add Candidate"}
      </Button>
    </form>
  );
};
```

---

## Step 2: Register Citizens

Citizens must be registered before voter identifiers can be generated.

### Register Citizens (Manual)

```bash
# Note: This endpoint may need to be implemented
# For now, citizens are typically pre-loaded from a database

curl -X POST http://localhost:3000/api/committee/register-citizen \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "electoralId": "ABC123456",
    "province": "New York",
    "registrationDate": "2025-01-15"
  }'
```

### Bulk Upload Citizens

```typescript
// web-frontend/src/services/citizens.ts
export async function bulkUploadCitizens(file: File) {
  const formData = new FormData();
  formData.append("file", file);

  const response = await axios.post(
    `${API_URL}/committee/bulk-upload-citizens`,
    formData,
    {
      headers: { "Content-Type": "multipart/form-data" },
    },
  );

  return response.data;
}
```

---

## Step 3: Generate Voter Identifiers

After citizens are registered, generate cryptographic identifiers for them.

### Generate Identifiers

```bash
# Generate all voter identifiers
curl http://localhost:3000/api/committee/generate-identifiers
```

**Response**:

```json
{
  "voters": [
    {
      "electoralId": "ABC123456",
      "identifier": "encrypted_unique_identifier_here",
      "hasVoted": false
    },
    ...
  ],
  "note": "Request accepted ..."
}
```

### TypeScript Implementation

```typescript
// web-frontend/src/services/voters.ts
export async function generateVoterIdentifiers() {
  try {
    const response = await axios.get(
      `${API_URL}/committee/generate-identifiers`,
    );

    return {
      success: true,
      voters: response.data.voters,
      count: response.data.voters.length,
    };
  } catch (error: any) {
    throw new Error("Failed to generate identifiers");
  }
}
```

### React Component

```tsx
// web-frontend/src/pages/Voters/GenerateIdentifiers.tsx
import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { generateVoterIdentifiers } from "@/services/voters";

export const GenerateIdentifiers = () => {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);

  const handleGenerate = async () => {
    if (!confirm("Generate voter identifiers? This can only be done once.")) {
      return;
    }

    setLoading(true);
    try {
      const data = await generateVoterIdentifiers();
      setResult(data);
      alert(`Successfully generated ${data.count} voter identifiers!`);
    } catch (error: any) {
      alert(`Error: ${error.message}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <h2 className="text-2xl font-bold mb-4">Generate Voter Identifiers</h2>

      <div className="bg-yellow-50 border border-yellow-200 p-4 rounded mb-4">
        <p className="text-sm">
          ⚠️ <strong>Important:</strong> Voter identifiers can only be generated
          once. Ensure all citizens are registered before proceeding.
        </p>
      </div>

      <Button onClick={handleGenerate} disabled={loading}>
        {loading ? "Generating..." : "Generate Identifiers"}
      </Button>

      {result && (
        <div className="mt-6">
          <h3 className="font-semibold">Result:</h3>
          <p>Total identifiers generated: {result.count}</p>
          <p className="text-green-600">✓ Success</p>
        </div>
      )}
    </div>
  );
};
```

---

## Step 4: Deploy Election Announcement

Configure and deploy the election announcement with start/end times and parameters.

### Announcement Parameters

```typescript
interface Announcement {
  startTimeVoting: string; // ISO 8601 format
  endTimeVoting: string; // ISO 8601 format
  dateResults: string; // ISO 8601 format
  numOfCandidates: number;
  numOfVoters: number;
}
```

### Deploy via API

```bash
curl -X POST http://localhost:3000/api/committee/deploy-announcement \
  -H "Content-Type: application/json" \
  -d '{
    "startTimeVoting": "2025-11-05T08:00:00Z",
    "endTimeVoting": "2025-11-05T20:00:00Z",
    "dateResults": "2025-11-06T00:00:00Z",
    "numOfCandidates": 3,
    "numOfVoters": 10000
  }'
```

### TypeScript Implementation

```typescript
// web-frontend/src/services/election.ts
export async function deployAnnouncement(announcement: Announcement) {
  try {
    const response = await axios.post(
      `${API_URL}/committee/deploy-announcement`,
      announcement,
    );

    return {
      success: true,
      message: "Election announcement deployed",
    };
  } catch (error: any) {
    throw new Error(error.response?.data?.note || "Deployment failed");
  }
}
```

### React Component

```tsx
// web-frontend/src/pages/Elections/DeployAnnouncement.tsx
import React from "react";
import { useForm } from "react-hook-form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { deployAnnouncement } from "@/services/election";

interface AnnouncementForm {
  startDate: string;
  startTime: string;
  endDate: string;
  endTime: string;
  resultsDate: string;
  resultsTime: string;
  numOfCandidates: number;
  numOfVoters: number;
}

export const DeployAnnouncementForm = () => {
  const { register, handleSubmit } = useForm<AnnouncementForm>();

  const onSubmit = async (data: AnnouncementForm) => {
    // Combine date and time into ISO 8601
    const startTimeVoting = `${data.startDate}T${data.startTime}:00Z`;
    const endTimeVoting = `${data.endDate}T${data.endTime}:00Z`;
    const dateResults = `${data.resultsDate}T${data.resultsTime}:00Z`;

    try {
      await deployAnnouncement({
        startTimeVoting,
        endTimeVoting,
        dateResults,
        numOfCandidates: data.numOfCandidates,
        numOfVoters: data.numOfVoters,
      });

      alert("Election announcement deployed successfully!");
    } catch (error: any) {
      alert(`Error: ${error.message}`);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div>
        <h3 className="font-semibold mb-2">Voting Start</h3>
        <div className="grid grid-cols-2 gap-4">
          <Input type="date" {...register("startDate")} required />
          <Input type="time" {...register("startTime")} required />
        </div>
      </div>

      <div>
        <h3 className="font-semibold mb-2">Voting End</h3>
        <div className="grid grid-cols-2 gap-4">
          <Input type="date" {...register("endDate")} required />
          <Input type="time" {...register("endTime")} required />
        </div>
      </div>

      <div>
        <h3 className="font-semibold mb-2">Results Publication</h3>
        <div className="grid grid-cols-2 gap-4">
          <Input type="date" {...register("resultsDate")} required />
          <Input type="time" {...register("resultsTime")} required />
        </div>
      </div>

      <div>
        <label>Number of Candidates</label>
        <Input
          type="number"
          {...register("numOfCandidates")}
          required
          min={1}
        />
      </div>

      <div>
        <label>Expected Number of Voters</label>
        <Input type="number" {...register("numOfVoters")} required min={1} />
      </div>

      <Button type="submit">Deploy Announcement</Button>
    </form>
  );
};
```

---

## Step 5: Monitor Election Progress

### Real-time Dashboard

```tsx
// web-frontend/src/pages/Dashboard/ElectionDashboard.tsx
import React, { useEffect, useState } from "react";
import { io } from "socket.io-client";
import axios from "axios";

export const ElectionDashboard = () => {
  const [stats, setStats] = useState({
    totalVoters: 0,
    votedCount: 0,
    turnoutPercentage: 0,
    blocksCount: 0,
  });

  useEffect(() => {
    // Load initial stats
    loadStats();

    // Connect to WebSocket for real-time updates
    const socket = io(import.meta.env.VITE_SOCKET_URL);

    socket.on("newVote", () => {
      loadStats();
    });

    socket.on("newBlock", () => {
      loadStats();
    });

    return () => {
      socket.disconnect();
    };
  }, []);

  const loadStats = async () => {
    const [votersRes, blockchainRes] = await Promise.all([
      axios.get(`${API_URL}/committee/voter-identifiers`),
      axios.get(`${API_URL}/blockchain/blocks`),
    ]);

    const voters = votersRes.data.registers;
    const votedCount = voters.filter((v: any) => v.hasVoted).length;

    setStats({
      totalVoters: voters.length,
      votedCount,
      turnoutPercentage: (votedCount / voters.length) * 100,
      blocksCount: blockchainRes.data.data.length,
    });
  };

  return (
    <div className="p-6">
      <h1 className="text-3xl font-bold mb-6">Election Dashboard</h1>

      <div className="grid grid-cols-4 gap-4">
        <StatCard title="Total Voters" value={stats.totalVoters} icon="👥" />
        <StatCard title="Votes Cast" value={stats.votedCount} icon="🗳️" />
        <StatCard
          title="Turnout"
          value={`${stats.turnoutPercentage.toFixed(1)}%`}
          icon="📊"
        />
        <StatCard
          title="Blockchain Blocks"
          value={stats.blocksCount}
          icon="⛓️"
        />
      </div>
    </div>
  );
};
```

---

## Complete Setup Script

Automate the entire setup process:

```bash
#!/bin/bash
# scripts/setup-election.sh

API_URL="http://localhost:3000/api"

echo "=== QuantumBallot Election Setup ==="

# 1. Add candidates
echo "Adding candidates..."
curl -s -X POST $API_URL/committee/add-candidate \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice Johnson","code":101,"party":"PDP","acronym":"PDP","status":"active"}' > /dev/null

curl -s -X POST $API_URL/committee/add-candidate \
  -H "Content-Type: application/json" \
  -d '{"name":"Bob Martinez","code":102,"party":"CUP","acronym":"CUP","status":"active"}' > /dev/null

curl -s -X POST $API_URL/committee/add-candidate \
  -H "Content-Type: application/json" \
  -d '{"name":"Carol Williams","code":103,"party":"IND","acronym":"IND","status":"active"}' > /dev/null

echo "✓ Candidates added"

# 2. Generate voter identifiers
echo "Generating voter identifiers..."
curl -s $API_URL/committee/generate-identifiers > /dev/null
echo "✓ Identifiers generated"

# 3. Deploy announcement
echo "Deploying election announcement..."
curl -s -X POST $API_URL/committee/deploy-announcement \
  -H "Content-Type: application/json" \
  -d '{
    "startTimeVoting":"2025-11-05T08:00:00Z",
    "endTimeVoting":"2025-11-05T20:00:00Z",
    "dateResults":"2025-11-06T00:00:00Z",
    "numOfCandidates":3,
    "numOfVoters":1000
  }' > /dev/null
echo "✓ Announcement deployed"

echo ""
echo "Election setup complete! 🎉"
echo "Candidates: 3"
echo "Voting starts: 2025-11-05 08:00 UTC"
echo "Voting ends: 2025-11-05 20:00 UTC"
```

---

## Verification

Verify the setup:

```bash
# Check candidates
curl http://localhost:3000/api/committee/candidates

# Check announcement
curl http://localhost:3000/api/committee/announcement

# Check voter identifiers
curl http://localhost:3000/api/committee/voter-identifiers
```

---

## Next Steps

- See [voting-flow.md](voting-flow.md) for voter experience
- See [blockchain-query.md](blockchain-query.md) for blockchain queries
- See [USAGE.md](../USAGE.md) for more usage examples

---

_This example is part of the QuantumBallot documentation. For more examples, see [examples/](../examples/)._
