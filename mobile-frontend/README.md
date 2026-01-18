# QuantumBallot Mobile Frontend

## Overview

React Native mobile application for QuantumBallot - a secure blockchain-based voting system for American elections. This mobile app allows voters to cast their votes securely on iOS and Android devices.

## Features

- ✅ Secure voter authentication
- ✅ Two-factor authentication (OTP)
- ✅ Browse candidates and election information
- ✅ Cast votes recorded on blockchain
- ✅ Vote verification and confirmation
- ✅ Real-time election updates
- ✅ QR code scanning for verification
- ✅ Responsive UI for all screen sizes

## Technology Stack

- **Framework:** React Native (Expo)
- **Language:** TypeScript
- **Navigation:** React Navigation
- **UI Library:** React Native Paper
- **State Management:** React Context API
- **HTTP Client:** Axios
- **Authentication:** JWT + Expo Secure Store

## Prerequisites

- Node.js 16+ and npm/yarn
- Expo CLI (`npm install -g expo-cli`)
- iOS Simulator (macOS) or Android Emulator/Device
- Running QuantumBallot backend server

## Installation

### 1. Clone and Navigate

```bash
cd mobile-frontend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and update:

```env
API_BASE_URL=http://YOUR_IP:3010/api  # Replace YOUR_IP with your backend IP
API_TIMEOUT=30000
NODE_ENV=development
```

**Important:** For testing on physical devices, use your computer's local IP address (not `localhost`). Find your IP:

- **macOS/Linux:** `ifconfig | grep inet`
- **Windows:** `ipconfig`

### 4. Start Development Server

```bash
npm start
```

This opens Expo Dev Tools in your browser. From here you can:

- Press `a` to open in Android emulator
- Press `i` to open in iOS simulator
- Scan QR code with Expo Go app on physical device

## Running on Devices

### Android

```bash
npm run android
```

Requirements:

- Android Studio with SDK installed
- Android emulator running OR
- Physical Android device with USB debugging enabled

### iOS (macOS only)

```bash
npm run ios
```

Requirements:

- Xcode installed
- iOS Simulator OR
- Physical iOS device with development profile

## Project Structure

```
mobile-frontend/
├── src/
│   ├── @types/           # TypeScript type definitions
│   ├── api/              # API client configuration
│   ├── assets/           # Images, fonts, static files
│   ├── components/       # Reusable UI components
│   ├── constants/        # App configuration constants
│   ├── context/          # React Context (Auth, etc.)
│   ├── data_types/       # TypeScript interfaces
│   ├── hooks/            # Custom React hooks
│   ├── routes/           # Navigation configuration
│   ├── screens/          # App screens
│   ├── services/         # Business logic services
│   └── theme/            # Styling and theme
├── __tests__/            # Test files
├── App.tsx               # App entry point
├── app.json              # Expo configuration
├── babel.config.js       # Babel configuration
├── jest.config.js        # Jest test configuration
├── package.json          # Dependencies
├── tsconfig.json         # TypeScript configuration
└── .env.example          # Environment template
```

## Main Screens

### 1. Login Screen

- Enter Electoral ID and password
- Secure authentication via JWT
- Navigate to Registration if needed

### 2. Registration Screen

- Register new voters
- Collect: Electoral ID, name, email, password, address, state
- Form validation
- Email verification

### 3. Candidates Screen

- View all election candidates
- See candidate details (name, party, code)
- View candidate photos
- Access candidate details

### 4. Groups/Voting Screen

- Select candidate to vote for
- Radio button selection
- Submit vote to blockchain
- Confirmation dialog

### 5. Two-Factor Authentication

- Enter 6-digit OTP code
- Visual PIN pad
- Code verification
- Vote submission after OTP

### 6. Thank You Screen

- Vote confirmation
- Transaction hash display
- Success message

## Configuration

### API Endpoints

Defined in `src/constants/config.ts`:

```typescript
ENDPOINTS: {
  LOGIN: "/api/committee/auth-mobile",
  REGISTER: "/api/committee/register-voter",
  CANDIDATES: "/api/committee/candidates",
  ANNOUNCEMENT: "/api/committee/announcement",
  VERIFY_OTP: "/api/committee/verify-otp",
  // ... more endpoints
}
```

### Storage Keys

```typescript
STORAGE_KEYS: {
  JWT_TOKEN: "my-jwt",
  EMAIL: "my-email",
  ELECTORAL_ID: "my-electoral-id",
  PORT: "my-port",
}
```

## Testing

### Run All Tests

```bash
npm test
```

### Run Tests in Watch Mode

```bash
npm test:watch
```

### Generate Coverage Report

```bash
npm test:coverage
```

### Test Files

- `__tests__/api/` - API client tests
- `__tests__/components/` - Component unit tests
- `__tests__/context/` - Context provider tests
- `__tests__/screens/` - Screen component tests
- `__tests__/integration/` - Integration tests
- `__tests__/e2e/` - End-to-end tests

## Development

### Linting

```bash
npm run lint
```

### Code Formatting

```bash
npm run format
```

### Hot Reload

Expo supports hot reloading. Save your files and changes appear instantly on the device/emulator.

### Debugging

- Shake device to open developer menu
- Use React Native Debugger
- Check Expo Dev Tools console
- View logs: `npx expo start --dev-client`

## Building for Production

### Android APK

```bash
eas build --platform android
```

### iOS IPA

```bash
eas build --platform ios
```

Requires Expo Application Services (EAS) account. See [Expo EAS Build](https://docs.expo.dev/build/introduction/) for setup.

## Common Issues & Solutions

### Issue: "Cannot connect to backend"

**Solution:**

- Verify backend is running: `cd backend && npm run dev`
- Check `.env` API_BASE_URL is correct
- Use local IP, not `localhost` for physical devices
- Ensure device and computer are on same network

### Issue: "Module not found" errors

**Solution:**

```bash
rm -rf node_modules package-lock.json
npm install
```

### Issue: "Expo app crashes on startup"

**Solution:**

- Clear Expo cache: `expo start -c`
- Reinstall Expo Go app on device
- Check for compatibility issues in `package.json`

### Issue: "Cannot run on iOS simulator"

**Solution:**

- Ensure Xcode is installed
- Open Xcode and install additional components
- Select simulator: Xcode → Open Developer Tool → Simulator
- Run: `npm run ios`

## Security Considerations

### Secure Storage

- JWTs stored in Expo Secure Store (encrypted)
- Never store sensitive data in AsyncStorage
- Clear auth data on logout

### API Communication

- All requests use HTTPS in production
- JWT tokens in Authorization headers
- Cookie-based session management
- Request/response logging in development only

### Input Validation

- All forms validate before submission
- XSS prevention via React's default escaping
- SQL injection prevention (backend responsibility)

## Performance Optimization

### Image Loading

- Lazy load candidate images
- Cache network images
- Use appropriate image sizes

### API Calls

- Minimize redundant network requests
- Cache candidate and announcement data
- Implement retry logic for failed requests

### State Management

- Use Context sparingly (avoid re-renders)
- Memoize expensive computations
- Optimize list rendering with `FlatList`

## Accessibility

- Semantic labels on all inputs
- Screen reader support
- Sufficient color contrast
- Touch target sizes ≥ 44x44 pts
- Keyboard navigation support

## Contributing

1. Create a feature branch
2. Make your changes
3. Write/update tests
4. Run linter and tests
5. Submit a pull request

## Backend Integration

### Required Backend Endpoints

The mobile app expects these endpoints to exist:

**Authentication:**

- `POST /api/committee/auth-mobile` - Login
- `POST /api/committee/register-voter` - Register
- `GET /api/committee/refresh-token` - Refresh JWT
- `POST /api/committee/verify-otp` - Verify OTP

**Data:**

- `GET /api/committee/candidates` - Get candidates
- `GET /api/committee/announcement` - Get election info

**Blockchain:**

- `POST /api/blockchain/make-transaction` - Submit vote (on province-specific port)
- `GET /api/blockchain/voting-status?electoralId=X` - Check if voted (recommended)

### Dynamic Port Configuration

The backend uses province-specific ports for blockchain nodes:

- Each state has a dedicated port (e.g., 3010, 3011, 3012...)
- Port is returned during login and stored in auth state
- All blockchain requests use the user's assigned port

## License

MIT License - See LICENSE file for details

## Support

For issues or questions:

- GitHub Issues: [Create an issue](https://github.com/quantsingularity/QuantumBallot/issues)
- Documentation: See `/docs` directory
- Backend API: See `backend/README.md`

## Version History

- **v1.0.0** (Current) - Production-ready mobile frontend
  - All placeholders implemented
  - Voting status check implemented
  - Two-factor authentication fixed
  - Image loading service implemented
  - Comprehensive error handling
  - Full TypeScript support

---
