import express, { Request, Response } from "express";
import dotenv from "dotenv";
import { connectToDB } from "./leveldb"; // Assuming a connectToDB function exists

dotenv.config({ path: "../.env" });

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Basic route
app.get("/", (req: Request, res: Response) => {
  res.send("QuantumBallot Backend API is running!");
});

// Assuming routes are imported and used here
// import apiRoutes from './api/routes';
// app.use('/api', apiRoutes);

// Start server
const startServer = async () => {
  try {
    // Connect to LevelDB
    await connectToDB();

    app.listen(PORT, () => {
      console.log(`Server is running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();
