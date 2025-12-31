# Troubleshooting Guide

Common issues and solutions for QuantumBallot installation, development, and deployment.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Backend Issues](#backend-issues)
3. [Frontend Issues](#frontend-issues)
4. [Mobile App Issues](#mobile-app-issues)
5. [Blockchain Issues](#blockchain-issues)
6. [Database Issues](#database-issues)
7. [Network and API Issues](#network-and-api-issues)
8. [Performance Issues](#performance-issues)

---

## Installation Issues

### Node.js Version Mismatch

**Symptom**: Errors during `npm install` like "unsupported engine" or "node version not compatible"

**Solution**:

```bash
# Check current Node.js version
node --version

# Install Node.js 18 LTS (recommended)
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node@18
brew link node@18

# Verify installation
node --version  # Should show v18.x.x
```

---

### npm Install Fails

**Symptom**: `npm install` throws errors like "EACCES" or "permission denied"

**Solutions**:

```bash
# Solution 1: Clear npm cache
npm cache clean --force
rm -rf node_modules package-lock.json
npm install

# Solution 2: Fix permissions (Linux/macOS)
sudo chown -R $USER:$(id -gn $USER) ~/.npm
sudo chown -R $USER:$(id -gn $USER) ~/.config

# Solution 3: Use different registry
npm config set registry https://registry.npmjs.org/
npm install
```

---

### Git Clone Fails

**Symptom**: "Permission denied (publickey)" or "repository not found"

**Solution**:

```bash
# Use HTTPS instead of SSH
git clone https://github.com/abrar2030/QuantumBallot.git

# Or setup SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub account
```

---

## Backend Issues

### Port Already in Use

**Symptom**: "Error: listen EADDRINUSE: address already in use :::3000"

**Solution**:

```bash
# Find process using port 3000
lsof -ti:3000

# Kill the process
kill -9 $(lsof -ti:3000)

# Or use different port
# Edit backend/.env
PORT=3001
```

---

### Environment Variables Not Loaded

**Symptom**: "Required environment variables are not set" or undefined variables

**Solution**:

```bash
# 1. Verify .env file exists
ls -la backend/.env

# 2. Copy from example if missing
cd backend
cp .env.example .env

# 3. Edit with your values
nano .env

# 4. Generate encryption keys
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
# Paste output as SECRET_KEY_IDENTIFIER and SECRET_KEY_VOTES

node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"
# Paste output as SECRET_IV_IDENTIFIER and SECRET_IV_VOTES

# 5. Restart backend
npm run dev
```

---

### LevelDB Connection Error

**Symptom**: "Error opening database" or "LevelDB error"

**Solution**:

```bash
# 1. Check database path
echo $DB_PATH  # Should match backend/.env

# 2. Create database directory
mkdir -p backend/data

# 3. Fix permissions
chmod -R 755 backend/data

# 4. Delete corrupted database (WARNING: loses all data)
rm -rf backend/data/QuantumBallot_db
npm run dev  # Will create fresh database
```

---

### TypeScript Compilation Errors

**Symptom**: "Cannot find module" or type errors during build

**Solution**:

```bash
# 1. Reinstall dependencies
cd backend
rm -rf node_modules package-lock.json
npm install

# 2. Clean build
npm run build

# 3. Check TypeScript version
npm list typescript  # Should be 5.x

# 4. Update TypeScript (if needed)
npm install --save-dev typescript@latest
```

---

### JWT Secret Too Short

**Symptom**: "JWT secret must be at least 32 characters"

**Solution**:

```bash
# Generate secure JWT secret
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"

# Update backend/.env
JWT_SECRET=<generated_secret>
ACCESS_TOKEN_SECRET=<generated_secret>
```

---

## Frontend Issues

### Vite Build Fails

**Symptom**: Web frontend fails to build or start

**Solution**:

```bash
# 1. Clear Vite cache
cd web-frontend
rm -rf node_modules/.vite

# 2. Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# 3. Update Vite
npm update vite

# 4. Try again
npm run dev
```

---

### API Connection Refused

**Symptom**: "Network Error" or "ERR_CONNECTION_REFUSED" in browser console

**Solution**:

```bash
# 1. Verify backend is running
curl http://localhost:3000/health

# 2. Check API URL in web-frontend/.env
cat web-frontend/.env
# Should show: VITE_API_URL=http://localhost:3000/api

# 3. Update if incorrect
echo "VITE_API_URL=http://localhost:3000/api" >> web-frontend/.env

# 4. Restart frontend
npm run dev
```

---

### CORS Errors

**Symptom**: "CORS policy: No 'Access-Control-Allow-Origin' header is present"

**Solution**:

```bash
# Add your frontend URL to backend CORS whitelist
# Edit backend/src/index.ts or backend/src/config/allowedOrigins.ts

const allowedOrigins = [
  "http://localhost:5173",  # Vite default
  "http://localhost:3007",
  // Add your URL here
];
```

---

### Build Output Too Large

**Symptom**: Webpack/Vite bundle size warning

**Solution**:

```javascript
// web-frontend/vite.config.ts
export default defineConfig({
  build: {
    chunkSizeWarningLimit: 1000, // Increase limit
    rollupOptions: {
      output: {
        manualChunks(id) {
          // Split vendor chunks
          if (id.includes("node_modules")) {
            return id
              .toString()
              .split("node_modules/")[1]
              .split("/")[0]
              .toString();
          }
        },
      },
    },
  },
});
```

---

## Mobile App Issues

### Expo Start Fails

**Symptom**: `expo start` or `npm start` throws errors

**Solution**:

```bash
# 1. Clear Expo cache
cd mobile-frontend
rm -rf .expo node_modules

# 2. Reinstall
npm install

# 3. Clear metro cache
npx expo start --clear

# 4. If still fails, reinstall Expo CLI globally
npm install -g expo-cli
```

---

### Cannot Connect to Metro Bundler

**Symptom**: Mobile app shows "Unable to connect to Metro"

**Solution**:

```bash
# 1. Check firewall allows connections on port 19000-19001
# Ubuntu
sudo ufw allow 19000:19001/tcp

# 2. Use tunnel mode
npx expo start --tunnel

# 3. Or specify host manually
npx expo start --host tunnel
```

---

### API Connection from Mobile

**Symptom**: Mobile app cannot reach backend API

**Solution**:

```bash
# 1. Find your computer's local IP
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig | findstr /i "IPv4"

# 2. Update mobile-frontend/.env
# Replace localhost with your IP
API_URL=http://192.168.1.100:3000/api

# 3. Ensure backend allows connections
# Check backend CORS configuration

# 4. Restart Expo
npx expo start
```

---

### QR Code Scanner Not Working

**Symptom**: Camera permission denied or scanner not functioning

**Solution**:

```bash
# 1. Check permissions in app.json
{
  "expo": {
    "plugins": [
      [
        "expo-camera",
        {
          "cameraPermission": "Allow $(PRODUCT_NAME) to access your camera."
        }
      ]
    ]
  }
}

# 2. Rebuild app
npx expo prebuild --clean
npx expo run:ios  # or run:android

# 3. Check device settings
# iOS: Settings → QuantumBallot → Camera → Enable
# Android: Settings → Apps → QuantumBallot → Permissions → Camera → Allow
```

---

## Blockchain Issues

### Block Mining Too Slow

**Symptom**: Mining blocks takes excessively long

**Solution**:

```typescript
// Adjust difficulty in backend/src/blockchain/blockchain.ts
private difficulty = 2;  // Lower value = faster mining (default: 4)

// Note: Lower difficulty reduces security
// Only use in development/testing
```

---

### Blockchain Validation Fails

**Symptom**: "Invalid blockchain" or validation errors

**Solution**:

```bash
# 1. Check blockchain integrity via API
curl http://localhost:3000/api/blockchain/chain

# 2. Reset blockchain (WARNING: loses all data)
curl http://localhost:3000/api/committee/clear-chains

# 3. Or delete database
rm -rf backend/data/QuantumBallot_db

# 4. Restart backend
npm run dev
```

---

### Transactions Not Being Mined

**Symptom**: Transactions stay in pending pool

**Solution**:

```typescript
// Check transaction pool size threshold
// backend/src/blockchain/blockchain.ts

// Manually trigger mining (development only)
// Add this to blockchain.route.ts
router.post("/mine", async (req, res) => {
  const newBlock = blockchain.mineBlock(blockchain.getPendingTransactions());
  blockchain.addBlock(newBlock);
  res.json({ success: true, block: newBlock });
});
```

---

## Database Issues

### Database Locked Error

**Symptom**: "Database is locked" or "Resource temporarily unavailable"

**Solution**:

```bash
# 1. Close all backend instances
killall node

# 2. Remove lock files
rm -f backend/data/QuantumBallot_db/LOCK

# 3. Restart backend
cd backend
npm run dev
```

---

### Data Corruption

**Symptom**: "Corrupted database" or unexpected data

**Solution**:

```bash
# 1. Backup existing data
cp -r backend/data/QuantumBallot_db backend/data/backup_$(date +%Y%m%d)

# 2. Try repair (may not always work)
node -e "
const level = require('level');
const db = level('./backend/data/QuantumBallot_db');
db.open().then(() => db.close());
"

# 3. If repair fails, restore from backup or reset
rm -rf backend/data/QuantumBallot_db
# Restore backup or start fresh
```

---

## Network and API Issues

### Request Timeout

**Symptom**: API requests timeout or take very long

**Solution**:

```javascript
// Increase timeout in API client
// web-frontend/src/services/api.ts
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 30000, // Increase from default 10000ms
});
```

---

### WebSocket Connection Fails

**Symptom**: Real-time updates not working, Socket.IO errors

**Solution**:

```bash
# 1. Verify Socket.IO is enabled in backend
# backend/src/index.ts should have Socket.IO initialization

# 2. Check WebSocket URL in frontend
# web-frontend/.env
VITE_SOCKET_URL=http://localhost:3000

# 3. Test WebSocket connection
# In browser console:
const socket = io('http://localhost:3000');
socket.on('connect', () => console.log('Connected'));
```

---

### Authentication Token Expired

**Symptom**: "Token expired" or 401 Unauthorized after period of inactivity

**Solution**:

```javascript
// Implement token refresh
// web-frontend/src/services/api.ts
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Redirect to login
      window.location.href = "/login";
    }
    return Promise.reject(error);
  },
);
```

---

## Performance Issues

### High Memory Usage

**Symptom**: Backend consumes excessive memory

**Solution**:

```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"
npm start

# Or in package.json
{
  "scripts": {
    "start": "node --max-old-space-size=4096 dist/index.js"
  }
}
```

---

### Slow API Responses

**Symptom**: API endpoints respond slowly

**Solution**:

```javascript
// Add caching for frequently accessed data
// backend/src/api/routes/blockchain.route.ts
let resultsCache = null;
let cacheTimestamp = 0;

router.get("/get-results-computed", async (req, res) => {
  const now = Date.now();
  if (resultsCache && now - cacheTimestamp < 60000) {
    return res.json({ success: true, data: resultsCache });
  }

  const results = await blockchain.smartContract.getResultsComputed();
  resultsCache = results;
  cacheTimestamp = now;

  res.json({ success: true, data: results });
});
```

---

### Frontend Rendering Lag

**Symptom**: Web/mobile UI feels slow or unresponsive

**Solution**:

```tsx
// Use React.memo for expensive components
export const CandidateList = React.memo(({ candidates }) => {
  return candidates.map((c) => <CandidateCard key={c.id} {...c} />);
});

// Virtualize long lists
import { FixedSizeList } from "react-window";

<FixedSizeList height={600} itemCount={candidates.length} itemSize={100}>
  {({ index, style }) => <CandidateCard style={style} {...candidates[index]} />}
</FixedSizeList>;
```

---

## Getting More Help

If your issue isn't covered here:

1. **Check logs**:

   ```bash
   # Backend logs
   cd backend && npm run dev  # Watch console output

   # Browser console (Web)
   F12 → Console tab

   # Expo logs (Mobile)
   npx expo start  # Watch terminal output
   ```

2. **Search existing issues**: https://github.com/abrar2030/QuantumBallot/issues

3. **Create new issue**: Include:
   - OS and version
   - Node.js version
   - Steps to reproduce
   - Error messages
   - What you've tried

4. **Ask in Discussions**: https://github.com/abrar2030/QuantumBallot/discussions

---

_For installation help, see [INSTALLATION.md](INSTALLATION.md). For configuration, see [CONFIGURATION.md](CONFIGURATION.md)._
