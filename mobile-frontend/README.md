# Chainocracy Mobile Frontend

This directory contains the mobile application frontend for the Chainocracy project, a full-stack Web and Mobile application for American elections using Blockchain Technology. The mobile frontend is built using React Native with Expo, providing a cross-platform solution for both iOS and Android devices.

## Overview

The Chainocracy mobile application serves as the primary interface for voters to participate in the election process. It provides a user-friendly experience with features such as authentication, QR code scanning, live election projections, data visualization, and blockchain interaction. The application is designed to be accessible and intuitive, ensuring that voters can easily navigate and participate in the democratic process.

## Directory Structure

The mobile frontend is organized as follows:

- `src/`: Main source code directory
  - `@types/`: TypeScript type definitions
  - `api/`: API client and service integrations
  - `assets/`: Static assets including images, fonts, and other resources
  - `components/`: Reusable UI components
  - `context/`: React context providers for state management
  - `data_types/`: Data type definitions and interfaces
  - `hooks/`: Custom React hooks
  - `routes/`: Navigation configuration and routing
  - `screens/`: Main application screens and views
  - `service/`: Service layer for business logic
  - `theme/`: Styling themes and design system
- `__tests__/`: Test files and test utilities
- `__mocks__/`: Mock data and mock implementations for testing
- `assets/`: Global static assets
- Configuration files:
  - `App.tsx`: Main application entry point
  - `app.json`: Expo configuration
  - `.babelrc`, `babel.config.js`: Babel configuration
  - `.eslintrc.js`, `eslint.config.js`: ESLint configuration
  - `jest.config.js`, `jest.setup.js`: Jest testing configuration
  - `tsconfig.json`: TypeScript configuration
  - `eas.json`: Expo Application Services configuration

## Setup and Installation

### Prerequisites

- Node.js (v16 or later)
- npm or yarn package manager
- Expo CLI (`npm install -g expo-cli`)
- iOS Simulator (for macOS) or Android Emulator
- Physical device for testing (optional)

### Installation Steps

1. Install dependencies:
   ```
   npm install
   ```
   or
   ```
   yarn install
   ```

2. Start the development server:
   ```
   npm start
   ```
   or
   ```
   yarn start
   ```

3. Run on specific platform:
   ```
   npm run ios     # for iOS
   npm run android # for Android
   ```

## Development Guidelines

### Code Structure

- Follow the established directory structure
- Create reusable components in the `components/` directory
- Implement screens in the `screens/` directory
- Use TypeScript for type safety
- Leverage React hooks for state management and side effects

### Styling

- Use the theme system defined in `src/theme/`
- Follow the design system for consistent UI
- Ensure responsive layouts for different device sizes
- Support both light and dark mode where applicable

### Testing

- Write unit tests for components and services
- Place test files in the `__tests__/` directory
- Use Jest and React Testing Library for testing
- Run tests with `npm test` or `yarn test`

## Building for Production

### Expo Build

To build the application using Expo's build service:

1. Configure your app in `app.json`
2. Run the build command:
   ```
   expo build:ios     # for iOS
   expo build:android # for Android
   ```

### EAS Build

For Expo Application Services build:

1. Configure your build in `eas.json`
2. Run the EAS build command:
   ```
   eas build --platform ios     # for iOS
   eas build --platform android # for Android
   ```

## Deployment

### App Store (iOS)

1. Create an App Store Connect account
2. Register your app bundle identifier
3. Submit the built IPA file to App Store Connect
4. Complete the submission process including metadata and screenshots

### Google Play Store (Android)

1. Create a Google Play Console account
2. Register your app package name
3. Upload the built APK or AAB file to the Play Console
4. Complete the submission process including metadata and screenshots

## Compatibility

The mobile application is designed to be compatible with:

- iOS 17.4.1 or later
- Android 13 or later
- Expo SDK 49 or later

## Related Resources

- For backend API documentation, refer to the `backend-api` directory
- For deployment infrastructure, check the `infrastructure` directory
- For comprehensive system documentation, see the `docs` directory
- For web frontend implementation, explore the `web-frontend` directory
