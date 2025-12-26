# QuantumBallot Backend

A secure blockchain-based voting system backend built with Node.js, TypeScript, Express, and LevelDB.

## Features

- **Blockchain-based voting**: Immutable transaction ledger for vote integrity
- **End-to-end encryption**: AES-256-CBC encryption for votes and voter identifiers
- **Smart contracts**: Automated vote tallying and result computation
- **JWT authentication**: Secure access control for voters and committee members
- **OTP verification**: Two-factor authentication using TOTP
- **RESTful API**: Comprehensive endpoints for voting, administration, and results
- **Embedded database**: LevelDB for fast, persistent storage without external dependencies

## Quick Start

### Prerequisites

- **Node.js** v16+ and npm v7+
- No external database required (uses embedded LevelDB)

### Installation & Startup

#### Option 1: Automated Setup (Recommended)

```bash
# Run the setup script
chmod +x setup.sh
./setup.sh

# Start the server
npm start
```

#### Option 2: Manual Setup

```bash
# 1. Install dependencies
npm install

# 2. Configure environment
cp .env.example .env

# Generate encryption keys
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Copy the output and update .env file with generated keys

# 3. Build TypeScript
npm run build

# 4. Start the server
npm start
```

#### Option 3: Using Makefile

```bash
make setup    # Full setup
make start    # Start server
make dev      # Development mode
make test     # Run tests
```

The server will start on `http://localhost:3000` (configurable via PORT in .env)

### Development Mode (with auto-reload)

```bash
npm run dev
```

## Verification

Test that everything works:

```bash
# Health check
curl http://localhost:3000/health

# Main API
curl http://localhost:3000/

# Blockchain API
curl http://localhost:3000/api/blockchain/

# Committee API
curl http://localhost:3000/api/committee/candidates
```

All endpoints should return proper JSON responses.

## Environment Configuration

Required environment variables (see `.env.example` for template):

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `JWT_SECRET` - JWT signing secret (min 32 chars)
- `ACCESS_TOKEN_SECRET` - Access token secret (min 32 chars)
- `REFRESH_TOKEN_SECRET` - Refresh token secret (min 32 chars)
- `DB_PATH` - LevelDB database path (default: ./data/QuantumBallot_db)
- `SECRET_KEY_IDENTIFIER` - 64-char hex encryption key for identifiers
- `SECRET_IV_IDENTIFIER` - 32-char hex IV for identifiers
- `SECRET_KEY_VOTES` - 64-char hex encryption key for votes
- `SECRET_IV_VOTES` - 32-char hex IV for votes
- Email settings (MAILER_SERVICE, MAILER_HOST, MAILER_PORT, MAILER_USER, MAILER_PASS)

**Generate encryption keys:**

```bash
# For 64-char hex keys (32 bytes)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# For 32-char hex IVs (16 bytes)
node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"
```

## Available Scripts

- `npm run build` - Compile TypeScript to JavaScript
- `npm start` - Start production server (requires build first)
- `npm run dev` - Start development server with auto-reload
- `npm test` - Run test suite
- `npm run test:coverage` - Run tests with coverage report
- `npm run test:watch` - Run tests in watch mode

## API Endpoints

### Core Endpoints

- `GET /` - API status and version
- `GET /health` - Health check

### Blockchain API (`/api/blockchain`)

**Public Endpoints:**

- `GET /` - Get full blockchain state
- `GET /chain` - Get blockchain
- `GET /blocks` - Get all blocks
- `GET /block-detail/:id` - Get specific block by hash
- `GET /transactions` - Get all transactions
- `GET /pending-transactions` - Get pending transactions
- `GET /voters` - Get voters list
- `GET /candidates` - Get candidates list
- `GET /get-results-computed` - Get computed results (cached)

**Protected Endpoints (require JWT):**

- `POST /transaction` - Submit new voting transaction
- `POST /transaction/broadcast` - Broadcast transaction to network
- `GET /mine` - Mine new block
- `GET /deploy-voters` - Deploy generated voters
- `GET /deploy-candidates` - Deploy candidates
- `GET /get-results` - Compute and get fresh election results
- `GET /clear-voters` - Clear voters (admin)
- `GET /clear-results` - Clear results (admin)
- `GET /clear-chains` - Clear blockchain (admin)

### Committee API (`/api/committee`)

**Public Endpoints:**

- `GET /registers` - Get citizen registers
- `GET /candidates` - Get candidates
- `GET /announcement` - Get election announcement
- `POST /register-voter` - Register new voter
- `POST /send-email` - Send OTP email to voter

**Authentication Endpoints:**

- `POST /auth-mobile` - Mobile authentication (returns JWT)
- `POST /auth-web` - Web authentication (returns JWT)
- `POST /verify-otp` - Verify OTP code (requires JWT)
- `GET /refresh-token` - Refresh access token (mobile)
- `GET /refresh-token-web` - Refresh access token (web)
- `GET /log-out` - Logout (mobile)
- `GET /log-out-web` - Logout (web)

**Admin Endpoints (require JWT):**

- `POST /add-candidate` - Add new candidate
- `POST /add-user` - Add committee user
- `POST /update-citizen` - Update citizen information
- `POST /update-user` - Update user information
- `POST /delete-register` - Delete citizen register
- `POST /delete-user` - Delete committee user
- `POST /deploy-announcement` - Deploy election announcement
- `GET /generate-identifiers` - Generate voter identifiers
- `GET /users` - Get committee users
- `GET /voter-identifiers` - Get generated voter identifiers
- `GET /clear-candidates` - Clear candidates
- `GET /clear-registers` - Clear citizen registers
- `GET /clear-users` - Clear committee users

## Architecture

- **Runtime**: Node.js with Express.js
- **Language**: TypeScript (compiled to JavaScript)
- **Database**: LevelDB (embedded key-value store, no external DB needed)
- **Blockchain**: Custom implementation with proof-of-work and Merkle trees
- **Smart Contracts**: Automated vote tallying and result computation
- **Encryption**: AES-256-CBC for vote and identifier encryption
- **Authentication**: JWT-based with refresh tokens
- **OTP**: TOTP-based two-factor authentication using Speakeasy

## Project Structure

```
backend/
├── src/
│   ├── api/
│   │   ├── index.ts              # API router configuration
│   │   └── routes/
│   │       ├── blockchain.route.ts  # Blockchain endpoints
│   │       └── committee.route.ts   # Committee endpoints
│   ├── blockchain/
│   │   ├── blockchain.ts         # Blockchain implementation
│   │   └── data_types.ts         # Block, Transaction types
│   ├── committee/
│   │   ├── committee.ts          # Committee management
│   │   └── data_types.ts         # Citizen, User types
│   ├── crypto/
│   │   └── cryptoBlockchain.ts   # Encryption utilities
│   ├── smart_contract/
│   │   └── smart_contract.ts     # Vote tallying logic
│   ├── leveldb/
│   │   └── index.ts              # Database operations
│   ├── middleware/
│   │   ├── verifyJWT.ts          # JWT verification
│   │   ├── verifyJWTWeb.ts       # Web JWT verification
│   │   └── credentials.ts        # CORS credentials
│   ├── email_center/
│   │   ├── sendEmail.ts          # Email sending
│   │   └── emailTemplate.ts      # HTML email template
│   ├── config/
│   │   ├── index.ts              # Config constants
│   │   ├── allowedOrigins.ts     # CORS origins
│   │   └── coreOptions.ts        # CORS options
│   └── index.ts                  # Main entry point
├── tests/                        # Test files
├── dist/                         # Compiled JavaScript (generated)
├── data/                         # LevelDB database (generated)
├── package.json                  # Dependencies and scripts
├── tsconfig.json                 # TypeScript configuration
├── jest.config.cjs               # Jest test configuration
├── .env.example                  # Environment variable template
├── .env                          # Environment variables (not in git)
├── setup.sh                      # Automated setup script
├── Makefile                      # Build automation
└── README.md                     # This file
```

## Security Notes

- **Never commit `.env` file** - It contains sensitive secrets
- **Generate unique secrets** - Use `crypto.randomBytes()` for all secrets
- **Use HTTPS in production** - Configure reverse proxy (nginx/Apache)
- **Secure email credentials** - Use app-specific passwords or OAuth2
- **Rate limiting recommended** - Add rate limiting middleware for production
- **Input validation** - All user inputs are validated

## Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Watch mode for development
npm run test:watch
```

## Troubleshooting

### Database Issues

- If you encounter database lock errors, ensure only one instance is running
- Delete the `data/` directory to reset the database

### Port Already in Use

- Change `PORT` in `.env` file
- Or kill the process using the port: `lsof -ti:3000 | xargs kill -9`

### TypeScript Errors

- Run `npm run build` to check for compilation errors
- Ensure TypeScript version matches `package.json`

### Email Not Sending

- Verify `MAILER_*` environment variables
- For Gmail, use app-specific password
- Check firewall/network settings

## Production Deployment

1. **Set NODE_ENV to production**:

   ```bash
   NODE_ENV=production
   ```

2. **Use process manager** (PM2 recommended):

   ```bash
   npm install -g pm2
   pm2 start dist/index.js --name quantumballot-backend
   pm2 save
   pm2 startup
   ```

3. **Set up reverse proxy** (nginx example):

   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

4. **Enable HTTPS** with Let's Encrypt:
   ```bash
   certbot --nginx -d your-domain.com
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `npm test`
5. Submit a pull request

## License

See LICENSE file for details.

## Support

For issues or questions:

- Check existing issues on GitHub
- Create a new issue with detailed information
- Include error messages and environment details
