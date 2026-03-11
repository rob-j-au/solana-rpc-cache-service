# Solana RPC Cache Service

A demonstration Rust-based service for caching and displaying Solana blockchain transactions with comprehensive monitoring and observability.

## Features

- 🚀 **High Performance**: Rust-based async HTTP server with optimized caching
- 🔗 **Solana Integration**: Real transaction data with Solscan explorer links
- 📊 **Full Observability**: Prometheus metrics, Grafana dashboards, centralized logging
- 🐳 **Docker Ready**: Multi-stage builds with cargo-chef optimization
- 🔒 **Secure**: Environment-based configuration, readonly database access
- 📱 **Modern UI**: Responsive design with Tailwind CSS

## Quick Start

```sh
# Setup environment
make setup

# Start all services
make up

# Open the app
open http://localhost:8080
```

## Commands

| Command | Description |
|---------|-------------|
| `make setup` | Copy .env.example to .env |
| `make up` | Start all services |
| `make down` | Stop all services |
| `make logs` | Follow container logs |
| `make clean` | Remove containers and volumes |
| `make db-shell` | Open PostgreSQL shell |
| `make dev` | Run locally with cargo |

See [MAKE.md](MAKE.md) for full documentation.

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `/` | Transactions page (HTML) |
| `/api/transactions` | JSON API |
| `/health` | Health check |
| `/metrics` | Prometheus metrics |

## Services

| Service | Port | Description |
|---------|------|-------------|
| App | 8080 | Main application |
| PostgreSQL | 5432 | Database |
| Grafana | 3000 | Dashboards |
| Prometheus | 9090 | Metrics |
| pgAdmin | 5050 | Database admin |
| Dashboard | 4000 | Development dashboard |

## License

AGPL-3.0
