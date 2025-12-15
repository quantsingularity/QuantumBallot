import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
} from "react-native";
import { Button, Card, RadioButton } from "react-native-paper";
import { useNavigation } from "@react-navigation/native";
import axios from "src/api/axios";
import { Config } from "../../constants/config";
import { useAuth } from "../../context/AuthContext";
import { Container, Title } from "./styles";

interface Candidate {
  code: number;
  name: string;
  party: string;
  acronym?: string;
  status?: string;
}

interface VotingStatusResponse {
  hasVoted: boolean;
  message?: string;
}

export function Groups() {
  const navigation = useNavigation();
  const { authState } = useAuth();
  const [candidates, setCandidates] = useState<Candidate[]>([]);
  const [selectedCandidate, setSelectedCandidate] = useState<number | null>(
    null,
  );
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [announcement, setAnnouncement] = useState<any>(null);
  const [hasVoted, setHasVoted] = useState(false);

  useEffect(() => {
    initializeVotingScreen();
  }, []);

  const initializeVotingScreen = async () => {
    setLoading(true);
    try {
      await Promise.all([
        fetchCandidates(),
        fetchAnnouncement(),
        checkVotingStatus(),
      ]);
    } catch (error) {
      if (Config.APP.SHOW_LOGS) {
        console.error("Error initializing voting screen:", error);
      }
    } finally {
      setLoading(false);
    }
  };

  const fetchCandidates = async () => {
    try {
      const response = await axios.get(Config.ENDPOINTS.CANDIDATES);
      if (response.data && response.data.candidates) {
        setCandidates(response.data.candidates);
      }
    } catch (error: any) {
      if (Config.APP.SHOW_LOGS) {
        console.error("Error fetching candidates:", error);
      }
      Alert.alert(
        "Error",
        "Failed to load candidates. Please try again later.",
      );
    }
  };

  const fetchAnnouncement = async () => {
    try {
      const response = await axios.get(Config.ENDPOINTS.ANNOUNCEMENT);
      if (response.data && response.data.announcement) {
        setAnnouncement(response.data.announcement);
      }
    } catch (error: any) {
      if (Config.APP.SHOW_LOGS) {
        console.error("Error fetching announcement:", error);
      }
    }
  };

  const checkVotingStatus = async () => {
    try {
      // Check if the user has already voted by querying the blockchain
      // This endpoint should return whether the electoral ID has already cast a vote
      const port = authState?.port || "3010";
      const baseUrl = Config.API_BASE_URL.replace(/:\d+$/, "");
      const votingStatusUrl = `${baseUrl}:${port}/api/blockchain/voting-status`;

      const response = await axios.get(votingStatusUrl, {
        params: {
          electoralId: authState?.electoralId,
        },
      });

      if (response.data && typeof response.data.hasVoted === "boolean") {
        setHasVoted(response.data.hasVoted);
      } else {
        // If endpoint doesn't exist or returns unexpected data, assume not voted
        setHasVoted(false);
      }
    } catch (error: any) {
      if (Config.APP.SHOW_LOGS) {
        console.error("Error checking voting status:", error);
      }
      // On error, assume user hasn't voted (fail-open for better UX)
      // In production, you might want to be more conservative
      if (error.response?.status === 404) {
        // Endpoint not implemented yet - allow voting
        setHasVoted(false);
      } else {
        // Other errors - show warning but allow voting
        setHasVoted(false);
      }
    }
  };

  const handleVoteSubmit = async () => {
    if (!selectedCandidate) {
      Alert.alert(
        "No Selection",
        "Please select a candidate before submitting your vote.",
      );
      return;
    }

    // Find the selected candidate's name for the confirmation message
    const candidate = candidates.find((c) => c.code === selectedCandidate);
    const candidateName = candidate
      ? `${candidate.name} (${candidate.party})`
      : `Candidate ${selectedCandidate}`;

    Alert.alert(
      "Confirm Vote",
      `Are you sure you want to vote for ${candidateName}?\n\nThis action cannot be undone and will be permanently recorded on the blockchain.`,
      [
        {
          text: "Cancel",
          style: "cancel",
        },
        {
          text: "Confirm",
          onPress: async () => {
            await submitVote();
          },
        },
      ],
    );
  };

  const submitVote = async () => {
    setSubmitting(true);
    try {
      // Get the province port from auth state
      const port = authState?.port || "3010";
      const baseUrl = Config.API_BASE_URL.replace(/:\d+$/, "");
      const blockchainUrl = `${baseUrl}:${port}/api/blockchain/make-transaction`;

      if (Config.APP.SHOW_LOGS) {
        console.log("Submitting vote to:", blockchainUrl);
      }

      const voteData = {
        candidateCode: selectedCandidate,
        electoralId: authState?.electoralId,
        timestamp: new Date().toISOString(),
      };

      const response = await axios.post(blockchainUrl, voteData);

      if (response.status === 200 || response.status === 201) {
        setHasVoted(true);
        Alert.alert(
          "Success",
          "Your vote has been recorded successfully on the blockchain!",
          [
            {
              text: "OK",
              onPress: () => {
                // Navigate to thank you screen
                (navigation as any).navigate("Thank Vote", {
                  candidateCode: selectedCandidate,
                  transactionHash:
                    response.data.transactionHash ||
                    response.data.details?.transactionHash,
                });
              },
            },
          ],
        );
      }
    } catch (error: any) {
      if (Config.APP.SHOW_LOGS) {
        console.error("Error submitting vote:", error);
      }

      let errorMessage =
        "Failed to submit vote. Please try again or contact support.";

      if (error.response?.status === 409) {
        errorMessage =
          "You have already voted in this election. Each voter can only vote once.";
        setHasVoted(true);
      } else if (error.response?.data?.message) {
        errorMessage = error.response.data.message;
      }

      Alert.alert("Error", errorMessage);
    } finally {
      setSubmitting(false);
    }
  };

  const isVotingOpen = () => {
    if (!announcement) return false;

    try {
      const now = new Date();
      const startTime = new Date(announcement.startTimeVoting);
      const endTime = new Date(announcement.endTimeVoting);

      return now >= startTime && now <= endTime;
    } catch (error) {
      if (Config.APP.SHOW_LOGS) {
        console.error("Error checking voting time window:", error);
      }
      return false;
    }
  };

  if (loading) {
    return (
      <Container style={{ justifyContent: "center", alignItems: "center" }}>
        <ActivityIndicator size="large" color="#0000ff" />
        <Text style={{ marginTop: 10 }}>Loading candidates...</Text>
      </Container>
    );
  }

  if (hasVoted) {
    return (
      <Container
        style={{ justifyContent: "center", alignItems: "center", padding: 20 }}
      >
        <Title>Thank You!</Title>
        <Text style={{ textAlign: "center", marginTop: 20, fontSize: 16 }}>
          You have already cast your vote in this election.
        </Text>
        <Text
          style={{
            textAlign: "center",
            marginTop: 10,
            fontSize: 14,
            color: "#666",
          }}
        >
          Your vote has been securely recorded on the blockchain and cannot be
          changed.
        </Text>
        <Text
          style={{
            textAlign: "center",
            marginTop: 10,
            fontSize: 14,
            color: "#666",
          }}
        >
          Results will be available after the voting period ends.
        </Text>
      </Container>
    );
  }

  if (!isVotingOpen()) {
    return (
      <Container
        style={{ justifyContent: "center", alignItems: "center", padding: 20 }}
      >
        <Title>Voting Not Available</Title>
        <Text style={{ textAlign: "center", marginTop: 20, fontSize: 16 }}>
          The voting period is not currently active.
        </Text>
        {announcement && (
          <Text
            style={{
              textAlign: "center",
              marginTop: 10,
              fontSize: 14,
              color: "#666",
            }}
          >
            Voting will be open from{" "}
            {new Date(announcement.startTimeVoting).toLocaleString()} to{" "}
            {new Date(announcement.endTimeVoting).toLocaleString()}
          </Text>
        )}
      </Container>
    );
  }

  return (
    <Container>
      <ScrollView style={{ flex: 1 }}>
        <Title style={{ padding: 20, fontSize: 24 }}>Cast Your Vote</Title>

        {announcement && (
          <Card style={{ margin: 20, marginTop: 0 }}>
            <Card.Content>
              <Text
                style={{ fontSize: 16, fontWeight: "bold", marginBottom: 5 }}
              >
                {announcement.title || "Election Information"}
              </Text>
              <Text style={{ fontSize: 14, color: "#666" }}>
                Voting closes:{" "}
                {new Date(announcement.endTimeVoting).toLocaleString()}
              </Text>
              {announcement.description && (
                <Text style={{ fontSize: 13, color: "#666", marginTop: 5 }}>
                  {announcement.description}
                </Text>
              )}
            </Card.Content>
          </Card>
        )}

        <Text style={{ paddingHorizontal: 20, fontSize: 16, marginBottom: 10 }}>
          Select a candidate:
        </Text>

        {candidates.length === 0 ? (
          <View style={{ padding: 20 }}>
            <Text style={{ textAlign: "center", color: "#666" }}>
              No candidates available at this time.
            </Text>
          </View>
        ) : (
          <RadioButton.Group
            onValueChange={(value) => setSelectedCandidate(Number(value))}
            value={selectedCandidate?.toString() || ""}
          >
            {candidates.map((candidate) => (
              <TouchableOpacity
                key={candidate.code}
                onPress={() => setSelectedCandidate(candidate.code)}
                style={{ marginHorizontal: 20, marginBottom: 10 }}
              >
                <Card>
                  <Card.Content
                    style={{ flexDirection: "row", alignItems: "center" }}
                  >
                    <RadioButton value={candidate.code.toString()} />
                    <View style={{ flex: 1, marginLeft: 10 }}>
                      <Text style={{ fontSize: 18, fontWeight: "bold" }}>
                        {candidate.name}
                      </Text>
                      <Text style={{ fontSize: 14, color: "#666" }}>
                        {candidate.party}
                        {candidate.acronym ? ` (${candidate.acronym})` : ""}
                      </Text>
                      <Text style={{ fontSize: 12, color: "#999" }}>
                        Code: {candidate.code}
                      </Text>
                    </View>
                  </Card.Content>
                </Card>
              </TouchableOpacity>
            ))}
          </RadioButton.Group>
        )}

        <View style={{ padding: 20 }}>
          <Button
            mode="contained"
            onPress={handleVoteSubmit}
            disabled={!selectedCandidate || submitting}
            loading={submitting}
            style={{ paddingVertical: 8 }}
          >
            {submitting ? "Submitting Vote..." : "Submit Vote"}
          </Button>
        </View>

        <Text
          style={{
            padding: 20,
            fontSize: 12,
            color: "#999",
            textAlign: "center",
          }}
        >
          Your vote is secure and anonymous. It will be recorded on the
          blockchain and cannot be changed once submitted. The integrity of your
          vote is guaranteed by cryptographic verification.
        </Text>
      </ScrollView>
    </Container>
  );
}
