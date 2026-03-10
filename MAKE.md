# Development Guide

This document describes how to run the Solana RPC Cache Service locally for development.

## Prerequisites

- Docker & Docker Compose
- Rust (for local development without Docker)

## Quick Start

```sh
# 1. Setup environment
make setup

# 2. Start services
make up

# 3. Open browser
open http://localhost:8080
```

## Makefile Commands

### Setup

| Command | Description |
|---------|-------------|
| `make setup` | Copy `.env.example` to `.env` |

### Docker

| Command | Description |
|---------|-------------|
| `make up` | Start all services (app + postgres) |
| `make down` | Stop all services |
| `make logs` | Follow container logs |
| `make ps` | Show running containers |
| `make build` | Build Docker images |
| `make rebuild` | Rebuild images without cache |
| `make clean` | Remove containers and volumes |

### Database

| Command | Description |
|---------|-------------|
| `make db-shell` | Open PostgreSQL interactive shell |

### Local Development

| Command | Description |
|---------|-------------|
| `make dev` | Start postgres in Docker, run app locally with cargo |

## Environment Variables

See `.env.example` for all available configuration:

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgres://solana:solana@postgres:5432/solana` |
| `TX_DISPLAY_COUNT` | Number of transactions to display | `100` |
| `POSTGRES_USER` | Database user | `solana` |
| `POSTGRES_PASSWORD` | Database password | `solana` |
| `POSTGRES_DB` | Database name | `solana` |

## Services

| Service | Port | Description |
|---------|------|-------------|
| App | 8080 | Main application |
| PostgreSQL | 5432 | Database |

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /` | Transactions page (HTML) |
| `GET /api/transactions` | Transactions API (JSON) |
| `GET /health` | Health check |
| `GET /metrics` | Prometheus metrics |
