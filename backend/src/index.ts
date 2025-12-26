import express, { Request, Response } from "express";
import dotenv from "dotenv";
import path from "path";
import { connectToDB } from "./leveldb";
import BlockChain from "./blockchain/blockchain";
import cors from "cors";

// Load environment variables from .env file
dotenv.config({ path: path.join(__dirname, "../.env") });

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// CORS configuration
const allowedOrigins = [
  "http://localhost:3007",
  "http://localhost:3010",
  "http://127.0.0.1:5500",
  "http://localhost:3500",
  "http://localhost:3000",
  "http://localhost:3001",
  "http://localhost:3002",
  "http://localhost:3003",
  "http://localhost:3004",
  "http://localhost:3005",
  "http://localhost:3006",
];

const corsOptions = {
  origin: (
    origin: string | undefined,
    callback: (err: Error | null, allow?: boolean) => void,
  ) => {
    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  optionsSuccessStatus: 200,
  credentials: true,
};

app.use(cors(corsOptions));

// Health check route
app.get("/", (req: Request, res: Response) => {
  res.json({
    message: "QuantumBallot Backend API is running!",
    version: "1.0.0",
    status: "healthy",
    timestamp: new Date().toISOString(),
  });
});

// Health check endpoint
app.get("/health", (req: Request, res: Response) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// Initialize blockchain and routes
let blockchain: BlockChain;
const allNodes = [PORT.toString()]; // Single node for now

// Start server
const startServer = async () => {
  try {
    console.log("Starting QuantumBallot Backend...");

    // Connect to LevelDB
    console.log("Connecting to database...");
    await connectToDB();
    console.log("Database connected successfully");

    // Initialize blockchain
    console.log("Initializing blockchain...");
    blockchain = new BlockChain();
    blockchain.setNodeAddress(PORT.toString());
    console.log("Blockchain initialized");

    // Import and mount API routes
    const apiRouter = require("./api/index")(blockchain, allNodes);
    app.use("/api", apiRouter);
    console.log("API routes mounted");

    // Error handling middleware
    app.use((err: Error, req: Request, res: Response, next: any) => {
      console.error("Error:", err.message);
      res.status(500).json({
        success: false,
        message: "Internal server error",
        error: process.env.NODE_ENV === "development" ? err.message : undefined,
      });
    });

    // 404 handler
    app.use((req: Request, res: Response) => {
      res.status(404).json({
        success: false,
        message: "Route not found",
        path: req.path,
      });
    });

    app.listen(PORT, () => {
      console.log("=".repeat(50));
      console.log(`✓ QuantumBallot Backend Server`);
      console.log(`✓ Environment: ${process.env.NODE_ENV || "development"}`);
      console.log(`✓ Server running on: http://localhost:${PORT}`);
      console.log(`✓ Health check: http://localhost:${PORT}/health`);
      console.log(`✓ API endpoint: http://localhost:${PORT}/api`);
      console.log("=".repeat(50));
    });
  } catch (error: any) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

// Handle graceful shutdown
process.on("SIGINT", async () => {
  console.log("\nShutting down gracefully...");
  process.exit(0);
});

process.on("SIGTERM", async () => {
  console.log("\nShutting down gracefully...");
  process.exit(0);
});

startServer();
