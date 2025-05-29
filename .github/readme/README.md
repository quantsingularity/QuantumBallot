# GitHub Workflows Documentation

This document provides a comprehensive overview of the GitHub Actions workflows used in the Chainocracy project. These workflows automate the continuous integration and continuous deployment (CI/CD) processes for different components of the application.

## Overview

The Chainocracy project uses GitHub Actions to automate testing, building, and deployment processes across multiple components:

- Backend API (Node.js)
- Web Frontend
- Mobile Frontend (React Native/Expo)
- Documentation

The workflow architecture is designed with a main orchestrator workflow that detects changes and triggers component-specific workflows as needed. This approach ensures efficient resource usage and maintains separation of concerns between different application components.

## Workflow Structure

### Main Workflow (`main.yml`)

The main workflow serves as an orchestrator that detects changes in specific directories and triggers the appropriate component-specific workflows. This approach allows for efficient resource usage by only running workflows for components that have been modified.

**Triggers:**
- Push to `main` branch
- Pull requests targeting `main` branch

**Key Jobs:**
1. **detect-changes**: Uses the `dorny/paths-filter` action to identify which components have been modified.
2. **trigger-workflows**: Based on the detected changes, conditionally triggers the appropriate component-specific workflows using the `benc-uk/workflow-dispatch` action.

**Dependencies:**
- Requires `GITHUB_TOKEN` with workflow dispatch permissions

### Backend API Workflow (`backend-api.yml`)

This workflow handles the CI/CD pipeline for the Node.js backend API.

**Triggers:**
- Push to `main` branch with changes in the `backend-api/` directory
- Pull requests targeting `main` branch with changes in the `backend-api/` directory
- Manual trigger from the main workflow

**Key Jobs:**
1. **test**: Runs tests and linting across multiple Node.js versions (16.x, 18.x, 20.x).
2. **build**: Creates a production build and uploads it as an artifact.
3. **deploy**: Deploys the build to the production server using SSH and rsync.

**Environment Variables and Secrets:**
- `SSH_PRIVATE_KEY`: SSH key for server access
- `PRODUCTION_HOST`: Hostname of the production server
- `PRODUCTION_USER`: Username for SSH connection
- `PRODUCTION_PATH`: Destination path on the production server

**Deployment Process:**
- Uses rsync to transfer files to the production server
- Restarts the application using PM2 (process manager)

### Web Frontend Workflow (`web-frontend.yml`)

This workflow manages the CI/CD pipeline for the web frontend application.

**Triggers:**
- Push to `main` branch with changes in the `web-frontend/` directory
- Pull requests targeting `main` branch with changes in the `web-frontend/` directory
- Manual trigger from the main workflow

**Key Jobs:**
1. **test**: Runs tests and linting checks.
2. **build**: Creates a production build and uploads it as an artifact.
3. **deploy**: Deploys the build to the production server using SSH and rsync.

**Environment Variables and Secrets:**
- `SSH_PRIVATE_KEY`: SSH key for server access
- `PRODUCTION_HOST`: Hostname of the production server
- `PRODUCTION_USER`: Username for SSH connection
- `PRODUCTION_PATH`: Destination path on the production server

**Deployment Process:**
- Uses rsync to transfer files to the production server
- Reloads Nginx configuration if needed

### Mobile Frontend Workflow (`mobile-frontend.yml`)

This workflow handles the CI/CD pipeline for the mobile application built with React Native and Expo.

**Triggers:**
- Push to `main` branch with changes in the `mobile-frontend/` directory
- Pull requests targeting `main` branch with changes in the `mobile-frontend/` directory
- Manual trigger from the main workflow

**Key Jobs:**
1. **test**: Runs tests and linting checks.
2. **build-android**: Builds the Android application using Expo EAS.
3. **build-ios**: Builds the iOS application using Expo EAS (runs on macOS runner).
4. **deploy-preview**: For pull requests, publishes a preview update to Expo.
5. **deploy-production**: For main branch, publishes a production update to Expo.

**Environment Variables and Secrets:**
- `EXPO_TOKEN`: Authentication token for Expo services

**Platform-Specific Considerations:**
- Android builds run on Ubuntu runners
- iOS builds require macOS runners
- Both use Expo EAS for building and publishing

### Documentation Workflow (`documentation.yml`)

This workflow manages the documentation build and deployment process.

**Triggers:**
- Push to `main` branch with changes in the `docs/` directory
- Pull requests targeting `main` branch with changes in the `docs/` directory
- Manual trigger from the main workflow

**Key Jobs:**
1. **build**: Builds the documentation using Python and uploads it as an artifact.
2. **deploy**: Deploys the documentation to GitHub Pages.

**Environment Variables and Secrets:**
- `GITHUB_TOKEN`: Used for GitHub Pages deployment

**Documentation Build Process:**
- Uses Python to build documentation (likely Sphinx or similar)
- Deploys to GitHub Pages using the `peaceiris/actions-gh-pages` action

## Workflow Interdependencies

The workflows in this project are designed with the following dependencies:

1. **Main Workflow** → Triggers component-specific workflows based on detected changes
2. **Component Workflows** → Independent execution paths with internal job dependencies:
   - **Test** → **Build** → **Deploy**

This architecture ensures that:
- Only affected components are processed when changes are made
- Tests must pass before building
- Building must succeed before deployment
- Production deployments only occur for the `main` branch

## Environment Setup

### Production Environment

The production environment is configured with the following components:

1. **Backend Server**: Accessed via SSH using the `SSH_PRIVATE_KEY` secret
2. **Web Hosting**: Served via Nginx on the production server
3. **Mobile Distribution**: Managed through Expo's services

### Secrets Management

The following secrets are required for the workflows to function properly:

- `SSH_PRIVATE_KEY`: SSH private key for server access
- `PRODUCTION_HOST`: Hostname of the production server
- `PRODUCTION_USER`: Username for SSH connection
- `PRODUCTION_PATH`: Destination path on the production server
- `EXPO_TOKEN`: Authentication token for Expo services
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions

These secrets should be configured in the repository settings under "Secrets and variables" → "Actions".

## Best Practices and Recommendations

### Adding New Components

When adding a new component to the project:

1. Create a new workflow file in the `.github/workflows/` directory
2. Update the `main.yml` workflow to detect changes in the new component's directory
3. Add the necessary trigger in the `trigger-workflows` job

### Troubleshooting

Common issues and their solutions:

1. **Failed Deployments**: Check SSH credentials and server connectivity
2. **Build Failures**: Verify that all dependencies are correctly specified
3. **Test Failures**: Run tests locally before pushing to identify issues early

### Security Considerations

- Secrets are securely managed by GitHub Actions
- SSH keys should have limited scope and be regularly rotated
- Production deployments are protected by environment approval requirements

## Conclusion

The GitHub Actions workflows in the Chainocracy project provide a robust CI/CD pipeline that ensures code quality, automates testing, and streamlines deployment across multiple application components. By following the modular architecture pattern, the workflows maintain separation of concerns while efficiently utilizing GitHub Actions resources.
