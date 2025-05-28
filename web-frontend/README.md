# Chainocracy Web Frontend

This directory contains the web application frontend for the Chainocracy project, a full-stack Web and Mobile application for American elections using Blockchain Technology. The web frontend is built using modern web technologies including React, TypeScript, Tailwind CSS, and Vite, providing a responsive and interactive user interface for committee members and administrators.

## Overview

The Chainocracy web application serves as the primary interface for election committee members and system administrators. It provides a comprehensive dashboard with features for election management, real-time data visualization, blockchain monitoring, and administrative controls. The web interface is designed to be intuitive yet powerful, offering advanced functionality while maintaining accessibility and ease of use.

## Directory Structure

The web frontend is organized as follows:

- `src/`: Main source code directory
  - `assets/`: Static assets including images, icons, and other resources
  - `components/`: Reusable UI components
  - `context/`: React context providers for state management
  - `data_types/`: TypeScript interfaces and type definitions
  - `geomap/`: Geographic mapping components and utilities
  - `global/`: Global constants and configuration
  - `hooks/`: Custom React hooks
  - `lib/`: Utility libraries and helper functions
  - `pages/`: Page components for routing
  - `screens/`: Main application screens and views
  - `services/`: Service layer for API communication
  - `sounds/`: Audio assets and sound effects
  - `styles/`: Global styles and CSS modules
  - `tables/`: Table components and data grid implementations
  - `tests/`: Unit and integration tests
  - `App.tsx`: Main application component
  - `main.tsx`: Application entry point
  - `index.css`: Global CSS styles
- `__tests__/`: Test files and testing utilities
- `app/`: Application-specific configurations
- `html/`: Static HTML templates
- `public/`: Publicly accessible static files
- Configuration files:
  - `.eslintrc.cjs`: ESLint configuration
  - `components.json`: UI component configuration
  - `index.html`: HTML entry point
  - `package.json`: NPM package configuration
  - `postcss.config.js`: PostCSS configuration
  - `tailwind.config.js`: Tailwind CSS configuration
  - `tsconfig.json`: TypeScript configuration
  - `vite.config.ts`: Vite bundler configuration
  - `vitest.config.ts`: Vitest testing configuration

## Setup and Installation

### Prerequisites

- Node.js (v16 or later)
- npm, yarn, or pnpm package manager
- Modern web browser (Google Chrome 124.0.6367.93 or later recommended)

### Installation Steps

1. Install dependencies:
   ```
   npm install
   ```
   or
   ```
   yarn install
   ```
   or
   ```
   pnpm install
   ```

2. Start the development server:
   ```
   npm run dev
   ```
   or
   ```
   yarn dev
   ```
   or
   ```
   pnpm dev
   ```

3. Access the application at http://localhost:5173 (or the port specified in your terminal)

## Development Guidelines

### Code Structure

- Follow the established directory structure
- Create reusable components in the `components/` directory
- Implement screens in the `screens/` or `pages/` directory
- Use TypeScript for type safety
- Leverage React hooks for state management and side effects
- Follow the component-driven development approach

### Styling

- Use Tailwind CSS for styling components
- Follow the design system defined in the project
- Ensure responsive layouts for different screen sizes
- Support both light and dark mode where applicable
- Use CSS modules for component-specific styles

### Testing

- Write unit tests for components and services
- Place test files in the `__tests__/` directory
- Use Vitest and React Testing Library for testing
- Run tests with `npm test` or `yarn test`

## Building for Production

To build the application for production:

1. Run the build command:
   ```
   npm run build
   ```
   or
   ```
   yarn build
   ```
   or
   ```
   pnpm build
   ```

2. The built files will be available in the `dist/` directory

## Deployment

### Static Hosting

The built application can be deployed to any static hosting service:

1. Build the application as described above
2. Upload the contents of the `dist/` directory to your hosting provider
3. Configure the server to handle client-side routing (if applicable)

### Docker Deployment

For containerized deployment:

1. Use the provided Dockerfile in the `infrastructure/docker/` directory
2. Build and run the Docker container as specified in the infrastructure documentation

## Features

The web frontend includes several key features:

- Interactive dashboard for election monitoring
- Geographic visualization of election data
- Real-time blockchain transaction monitoring
- Administrative controls for system management
- Data tables for detailed information display
- Authentication and role-based access control
- Responsive design for desktop and tablet use

## Browser Compatibility

The web application is optimized for:

- Google Chrome 124.0.6367.93 or later (recommended)
- Firefox 115 or later
- Safari 16 or later
- Edge 110 or later

## Related Resources

- For backend API documentation, refer to the `backend-api` directory
- For deployment infrastructure, check the `infrastructure` directory
- For comprehensive system documentation, see the `docs` directory
- For mobile frontend implementation, explore the `mobile-frontend` directory
- For testing documentation, see the `TEST_DOCUMENTATION.md` file in this directory
