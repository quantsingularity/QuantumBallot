#!/bin/bash

# QuantumBallot Project Setup Script

# Exit immediately if a command exits with a non-zero status.
set -e

# Prerequisites (ensure these are installed and configured):
# - Node.js (likely for backend)
# - npm (Node package manager)
# - Potentially Python and pip if other components exist but are not clearly defined by dependency files.

echo "Starting QuantumBallot project setup..."

PROJECT_DIR="/home/ubuntu/projects_extracted/QuantumBallot"

if [ ! -d "${PROJECT_DIR}" ]; then
  echo "Error: Project directory ${PROJECT_DIR} not found."
  echo "Please ensure the project is extracted correctly."
  exit 1
fi

cd "${PROJECT_DIR}"
echo "Changed directory to $(pwd)"

# --- Backend API Setup (Likely Node.js) ---
echo ""
echo "Setting up QuantumBallot backend environment..."
BACKEND_API_DIR="${PROJECT_DIR}/backend"

if [ ! -d "${BACKEND_API_DIR}" ]; then
    echo "Warning: Backend API directory ${BACKEND_API_DIR} not found. Skipping its setup."
else
    cd "${BACKEND_API_DIR}"
    echo "Changed directory to $(pwd) for backend setup."

    if [ -f "package.json" ]; then
        echo "Found package.json in ${BACKEND_API_DIR}. Installing Node.js dependencies using npm..."
        if ! command -v npm &> /dev/null; then
            echo "npm command could not be found. Please ensure Node.js and npm are installed and in your PATH."
        else
            npm install
            echo "Backend API Node.js dependencies installed."
            echo "Refer to package.json scripts or project documentation (if any) for how to run the backend API."
        fi
    elif [ -d "node_modules" ]; then
        echo "Warning: package.json not found in ${BACKEND_API_DIR}, but a node_modules directory exists."
        echo "This suggests it is a Node.js project, but dependencies might be pre-installed or managed differently."
        echo "Manual verification of dependencies and run commands is recommended."
    else
        echo "Warning: No package.json or node_modules directory found in ${BACKEND_API_DIR}."
        echo "The nature of this component is unclear. Manual inspection is required."
    fi
    cd "${PROJECT_DIR}" # Return to the main project directory
fi

# --- General Instructions & Reminders ---
echo ""
echo "QuantumBallot project setup script finished."
echo "NOTE: This project (QuantumBallot) was missing a README.md and key dependency files like a root-level requirements.txt or package.json, and package.json in backend."
echo "The setup script attempts to handle the 'backend' directory as a Node.js project if a package.json or node_modules is present."
echo "Due to missing information, this script is less comprehensive than for other projects."
echo "Please ensure all prerequisites are met (likely Node.js and npm)."
echo "Thoroughly review the project structure and any available files within subdirectories to determine full setup steps and how to run the application."
echo "You may need to manually identify and install dependencies if they are not captured by this script."
