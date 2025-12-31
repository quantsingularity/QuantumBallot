# Contributing to QuantumBallot

Thank you for your interest in contributing to QuantumBallot! This guide will help you get started.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Code Style Guidelines](#code-style-guidelines)
5. [Testing Requirements](#testing-requirements)
6. [Commit Guidelines](#commit-guidelines)
7. [Pull Request Process](#pull-request-process)
8. [Documentation Updates](#documentation-updates)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of background, experience level, or identity.

### Expected Behavior

- Be respectful and constructive in communication
- Welcome newcomers and help them get started
- Focus on what is best for the project and community
- Show empathy towards other contributors

### Unacceptable Behavior

- Harassment, discrimination, or trolling
- Personal attacks or inflammatory comments
- Publishing others' private information
- Any conduct that could be considered inappropriate in a professional setting

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Development Environment**:
   - Node.js 16+ installed
   - Git configured with your GitHub account
   - Code editor (VS Code recommended)

2. **Knowledge Requirements**:
   - TypeScript/JavaScript fundamentals
   - React (for frontend contributions)
   - Blockchain basics (for core contributions)
   - Git workflow understanding

### Setting Up Development Environment

```bash
# 1. Fork the repository on GitHub
# Click "Fork" button at https://github.com/abrar2030/QuantumBallot

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/QuantumBallot.git
cd QuantumBallot

# 3. Add upstream remote
git remote add upstream https://github.com/abrar2030/QuantumBallot.git

# 4. Install dependencies
./scripts/setup.sh

# 5. Configure environment
./scripts/setup_environment.sh

# 6. Verify setup
npm test  # in each component directory
```

---

## Development Workflow

### 1. Find or Create an Issue

Before starting work:

1. **Check existing issues**: https://github.com/abrar2030/QuantumBallot/issues
2. **Create new issue** if your contribution doesn't have one
3. **Discuss your approach** in the issue comments
4. **Wait for approval** from maintainers

### 2. Create a Feature Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

**Branch Naming Convention**:

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `test/` - Test additions/improvements
- `refactor/` - Code refactoring

### 3. Make Your Changes

Follow these guidelines:

- **Keep commits focused**: One logical change per commit
- **Write tests**: Add tests for new features/fixes
- **Update docs**: Update relevant documentation
- **Follow code style**: Run linters before committing

### 4. Test Your Changes

```bash
# Backend tests
cd backend
npm test
npm run lint

# Web frontend tests
cd web-frontend
npm test
npm run lint

# Mobile frontend tests
cd mobile-frontend
npm test
npm run lint
```

### 5. Commit Your Changes

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: add candidate photo upload feature"

# Push to your fork
git push origin feature/your-feature-name
```

### 6. Create Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your feature branch
4. Fill out the PR template
5. Submit and wait for review

---

## Code Style Guidelines

### TypeScript/JavaScript

**General Rules**:

- Use TypeScript for type safety
- Use `const` and `let`, never `var`
- Use async/await instead of callbacks
- Use meaningful variable names
- Add JSDoc comments for public functions

**Example**:

```typescript
/**
 * Validates a vote transaction before adding to blockchain
 * @param identifier - Encrypted voter identifier
 * @param choiceCode - Candidate code
 * @returns True if valid, false otherwise
 */
async function validateVoteTransaction(
  identifier: string,
  choiceCode: number,
): Promise<boolean> {
  // Validation logic
  return true;
}
```

**Formatting**:

- Indent: 2 spaces
- Line length: 80-100 characters
- Semicolons: Required
- Trailing commas: Yes
- Single quotes for strings

**Run Linter**:

```bash
# Backend
cd backend
npm run lint

# Auto-fix
npm run lint -- --fix
```

### React/JSX

**Component Structure**:

```tsx
// 1. Imports
import React, { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";

// 2. Type definitions
interface CandidateCardProps {
  name: string;
  party: string;
  onSelect: (id: number) => void;
}

// 3. Component
export const CandidateCard: React.FC<CandidateCardProps> = ({
  name,
  party,
  onSelect,
}) => {
  // 4. State and hooks
  const [selected, setSelected] = useState(false);

  // 5. Event handlers
  const handleClick = () => {
    setSelected(true);
    onSelect(1);
  };

  // 6. Render
  return (
    <div className="candidate-card">
      <h3>{name}</h3>
      <p>{party}</p>
      <Button onClick={handleClick}>Select</Button>
    </div>
  );
};
```

**React Best Practices**:

- Use functional components
- Use hooks appropriately
- Memoize expensive computations
- Keep components small and focused
- Extract reusable logic to custom hooks

### File Organization

```
src/
├── components/         # Reusable components
│   ├── ui/            # UI primitives (Button, Input, etc.)
│   └── feature/       # Feature-specific components
├── pages/             # Page components
├── hooks/             # Custom React hooks
├── utils/             # Utility functions
├── types/             # TypeScript type definitions
└── services/          # API services
```

### Naming Conventions

| Type       | Convention            | Example              |
| ---------- | --------------------- | -------------------- |
| Files      | kebab-case            | `vote-submission.ts` |
| Components | PascalCase            | `CandidateCard.tsx`  |
| Functions  | camelCase             | `validateVote()`     |
| Constants  | UPPER_SNAKE_CASE      | `MAX_CANDIDATES`     |
| Interfaces | PascalCase + I prefix | `IBlockHeader`       |
| Types      | PascalCase            | `BlockType`          |

---

## Testing Requirements

### Test Coverage Goals

| Component       | Minimum Coverage | Target Coverage |
| --------------- | ---------------- | --------------- |
| Backend API     | 80%              | 90%+            |
| Web Frontend    | 75%              | 85%+            |
| Mobile Frontend | 75%              | 85%+            |
| Blockchain Core | 85%              | 95%+            |

### Writing Tests

**Backend Tests (Jest)**:

```typescript
// backend/src/tests/blockchain.test.ts
import BlockChain from "../blockchain/blockchain";

describe("BlockChain", () => {
  let blockchain: BlockChain;

  beforeEach(() => {
    blockchain = new BlockChain();
  });

  describe("addPendingTransaction", () => {
    it("should add valid transaction to pool", async () => {
      const result = await blockchain.addPendingTransaction(
        "identifier123",
        "electoral456",
        101,
      );

      expect(result).toBe(true);
      expect(blockchain.getPendingTransactions()).toHaveLength(1);
    });

    it("should reject duplicate vote", async () => {
      await blockchain.addPendingTransaction("id1", "electoral1", 101);
      const result = await blockchain.addPendingTransaction(
        "id1",
        "electoral1",
        102,
      );

      expect(result).toBe(false);
    });
  });
});
```

**Frontend Tests (Vitest + Testing Library)**:

```tsx
// web-frontend/src/__tests__/CandidateCard.test.tsx
import { render, screen, fireEvent } from "@testing-library/react";
import { CandidateCard } from "../components/CandidateCard";

describe("CandidateCard", () => {
  it("renders candidate information", () => {
    render(
      <CandidateCard name="John Doe" party="Test Party" onSelect={() => {}} />,
    );

    expect(screen.getByText("John Doe")).toBeInTheDocument();
    expect(screen.getByText("Test Party")).toBeInTheDocument();
  });

  it("calls onSelect when clicked", () => {
    const handleSelect = jest.fn();
    render(
      <CandidateCard
        name="John Doe"
        party="Test Party"
        onSelect={handleSelect}
      />,
    );

    fireEvent.click(screen.getByText("Select"));
    expect(handleSelect).toHaveBeenCalledWith(1);
  });
});
```

### Running Tests

```bash
# Run all tests
npm test

# Watch mode
npm run test:watch

# Coverage report
npm run test:coverage

# Specific test file
npm test -- blockchain.test.ts
```

---

## Commit Guidelines

### Commit Message Format

Follow the Conventional Commits specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:

```bash
# Feature
git commit -m "feat(blockchain): add transaction validation"

# Bug fix
git commit -m "fix(api): correct vote encryption issue"

# Documentation
git commit -m "docs: update installation guide"

# Multi-line commit
git commit -m "feat(mobile): add biometric authentication

Implements fingerprint and face recognition for iOS and Android.
Uses Expo LocalAuthentication API.

Closes #123"
```

### Commit Best Practices

- **Atomic commits**: One logical change per commit
- **Clear subject**: Summarize change in 50 chars or less
- **Detailed body**: Explain what and why, not how
- **Reference issues**: Include issue numbers (e.g., "Fixes #123")
- **Sign commits**: Use GPG signing for verified commits

---

## Pull Request Process

### Before Submitting

✅ Checklist:

- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] New tests added for new features
- [ ] Documentation updated
- [ ] Commit messages follow conventions
- [ ] Branch is up to date with main
- [ ] No merge conflicts

### PR Description Template

```markdown
## Description

Brief description of changes

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issue

Closes #<issue_number>

## How Has This Been Tested?

Describe testing approach

## Screenshots (if applicable)

Add screenshots for UI changes

## Checklist

- [ ] My code follows the project's code style
- [ ] I have added tests that prove my fix/feature works
- [ ] All new and existing tests pass
- [ ] I have updated the documentation
```

### Review Process

1. **Automated checks**: CI/CD runs tests and linters
2. **Maintainer review**: Core team reviews code
3. **Feedback**: Address review comments
4. **Approval**: Requires 1+ approvals
5. **Merge**: Maintainer merges to main

### After Merge

- Delete your feature branch
- Close related issues
- Update documentation if needed

---

## Documentation Updates

### When to Update Docs

Update documentation when:

- Adding new features
- Changing API endpoints
- Modifying configuration options
- Fixing bugs that affect usage
- Improving existing processes

### Documentation Structure

```
docs/
├── README.md                  # Docs index
├── INSTALLATION.md            # Installation guide
├── USAGE.md                   # Usage guide
├── API.md                     # API reference
├── CONFIGURATION.md           # Configuration guide
├── ARCHITECTURE.md            # Architecture docs
├── CONTRIBUTING.md            # This file
└── examples/                  # Code examples
```

### Writing Style

- **Clear and concise**: Use simple language
- **Include examples**: Show, don't just tell
- **Keep updated**: Update docs with code changes
- **Use tables**: For options, parameters, etc.
- **Add diagrams**: Use Mermaid for architecture diagrams

### Updating API Documentation

When adding/modifying API endpoints, update `docs/API.md`:

````markdown
### POST /api/new-endpoint

Description of endpoint.

| Name     | Type   | Required? | Default | Description           | Example   |
| -------- | ------ | --------- | ------- | --------------------- | --------- |
| `param1` | string | Yes       | -       | Parameter description | `example` |

**Request**:
\```bash
curl -X POST http://localhost:3000/api/new-endpoint
\```

**Response**:
\```json
{
"success": true,
"data": {...}
}
\```
````

---
