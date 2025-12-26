#!/bin/bash
set -e

echo "===================================="
echo "QuantumBallot Backend Setup"
echo "===================================="

# Check Node.js version
NODE_VERSION=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "Error: Node.js v16+ is required. Current version: $(node -v)"
    exit 1
fi

echo "✓ Node.js version: $(node -v)"
echo "✓ npm version: $(npm -v)"

# Install dependencies
echo ""
echo "Installing dependencies..."
npm install

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo "Creating .env file with generated secrets..."
    cp .env.example .env
    
    # Generate random secrets
    JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    ACCESS_TOKEN_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    REFRESH_TOKEN_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    SECRET_KEY_IDENTIFIER=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    SECRET_IV_IDENTIFIER=$(node -e "console.log(require('crypto').randomBytes(16).toString('hex'))")
    SECRET_KEY_VOTES=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    SECRET_IV_VOTES=$(node -e "console.log(require('crypto').randomBytes(16).toString('hex'))")
    
    # Update .env with generated secrets
    sed -i "s/your_jwt_secret_here_min_32_chars_long/$JWT_SECRET/" .env
    sed -i "s/your_access_token_secret_here_min_32_chars/$ACCESS_TOKEN_SECRET/" .env
    sed -i "s/0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef/$SECRET_KEY_IDENTIFIER/" .env
    sed -i "s/0123456789abcdef0123456789abcdef/$SECRET_IV_IDENTIFIER/" .env
    sed -i "s/fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210/$SECRET_KEY_VOTES/" .env
    sed -i "s/fedcba9876543210fedcba9876543210/$SECRET_IV_VOTES/" .env
    
    # Add REFRESH_TOKEN_SECRET if not present
    if ! grep -q "REFRESH_TOKEN_SECRET" .env; then
        echo "" >> .env
        echo "# Refresh Token Secret" >> .env
        echo "REFRESH_TOKEN_SECRET=$REFRESH_TOKEN_SECRET" >> .env
    fi
    
    echo "✓ .env file created with secure random secrets"
else
    echo ""
    echo "✓ .env file already exists"
    
    # Check if REFRESH_TOKEN_SECRET exists, if not add it
    if ! grep -q "REFRESH_TOKEN_SECRET" .env; then
        REFRESH_TOKEN_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
        echo "" >> .env
        echo "# Refresh Token Secret" >> .env
        echo "REFRESH_TOKEN_SECRET=$REFRESH_TOKEN_SECRET" >> .env
        echo "✓ Added missing REFRESH_TOKEN_SECRET to .env"
    fi
fi

# Build TypeScript
echo ""
echo "Building TypeScript..."
npm run build

# Create data directory
mkdir -p data

echo ""
echo "===================================="
echo "✓ Setup complete!"
echo "===================================="
echo ""
echo "Next steps:"
echo "  1. Review/edit .env file for email configuration"
echo "  2. Run 'npm start' to start the server"
echo "  3. Run 'npm run dev' for development mode"
echo "  4. Run 'npm test' to run tests"
echo ""
echo "Server will be available at: http://localhost:3000"
echo "===================================="
