#!/bin/bash

# Project Run Script for QuantumBallot
# Provides a unified entry point to run the application components in development mode.

set -euo pipefail # Exit on error, exit on unset variable, fail on pipe error

echo "----------------------------------------"
echo "Starting QuantumBallot Application Components..."
echo "----------------------------------------"

# --- Configuration ---
COMPONENTS=(
  "backend"
  "web-frontend"
  "mobile-frontend"
)

# Function to start a component
start_component() {
  local component_dir="$1"
  local start_command="$2"

  if [ -d "$component_dir" ]; then
    echo "--- Starting $component_dir ---"
    (
      cd "$component_dir"
      if [ -f "package.json" ]; then
        echo "Executing '$start_command' in $component_dir..."
        # Run in background and redirect output to a log file
        npm run "$start_command" > "../logs/$component_dir.log" 2>&1 &
        echo "$component_dir started (PID: $!)"
      else
        echo "Warning: package.json not found in $component_dir. Skipping start."
      fi
    )
  else
    echo "Warning: Component directory '$component_dir' not found. Skipping start."
  fi
}

# Create logs directory if it doesn't exist
mkdir -p logs

# Start all components
start_component "backend" "dev" # Assuming 'npm run dev' for backend
start_component "web-frontend" "dev" # Assuming 'npm run dev' for web frontend
start_component "mobile-frontend" "start" # Assuming 'npm run start' for mobile (e.g., Expo)

echo "----------------------------------------"
echo "QuantumBallot services are running in the background."
echo "Check 'logs/' directory for output."
echo "Use 'jobs' to see running jobs."
echo "To stop all services, use 'kill \$(jobs -p)'"
echo "----------------------------------------"

# Keep the script running to prevent the background jobs from being killed immediately
# Wait for all background jobs to finish
wait -n
