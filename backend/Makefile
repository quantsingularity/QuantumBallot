.PHONY: help install build start dev test clean setup

help:
	@echo "QuantumBallot Backend - Available commands:"
	@echo ""
	@echo "  make setup    - Run full setup (install deps, generate secrets, build)"
	@echo "  make install  - Install dependencies"
	@echo "  make build    - Build TypeScript code"
	@echo "  make start    - Start production server"
	@echo "  make dev      - Start development server with auto-reload"
	@echo "  make test     - Run test suite"
	@echo "  make clean    - Clean build artifacts and database"
	@echo ""

setup:
	@./setup.sh

install:
	@echo "Installing dependencies..."
	@npm install

build: install
	@echo "Building TypeScript..."
	@npm run build

start: build
	@echo "Starting production server..."
	@npm start

dev: install
	@echo "Starting development server..."
	@npm run dev

test: install
	@echo "Running tests..."
	@npm test

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf dist node_modules data
	@echo "✓ Clean complete"
