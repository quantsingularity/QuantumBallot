#!/bin/bash
# Quick verification script for QuantumBallot backend

echo "=========================================="
echo "QuantumBallot Backend Verification"
echo "=========================================="
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js v16+"
    exit 1
fi
echo "✓ Node.js: $(node -v)"

# Check npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm not found"
    exit 1
fi
echo "✓ npm: $(npm -v)"

# Check if backend directory exists
if [ ! -d "src" ]; then
    echo "❌ Not in backend directory. Please cd into backend/"
    exit 1
fi
echo "✓ In backend directory"

# Check for .env file
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Run ./setup.sh or copy .env.example to .env"
else
    echo "✓ .env file exists"
fi

# Check for node_modules
if [ ! -d "node_modules" ]; then
    echo "⚠️  Dependencies not installed. Run 'npm install'"
else
    echo "✓ Dependencies installed"
fi

# Check for dist directory
if [ ! -d "dist" ]; then
    echo "⚠️  TypeScript not built. Run 'npm run build'"
else
    echo "✓ TypeScript compiled"
fi

echo ""
echo "=========================================="
echo "Backend appears ready!"
echo "=========================================="
echo ""
echo "To start:"
echo "  npm start       # Production mode"
echo "  npm run dev     # Development mode"
echo ""
echo "To test:"
echo "  curl http://localhost:3000/health"
echo "=========================================="
