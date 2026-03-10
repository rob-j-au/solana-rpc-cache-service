# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Solana RPC Cache Service
- Rust-based HTTP server with async transaction handling
- PostgreSQL integration with real Solana transaction data
- Comprehensive monitoring stack (Prometheus, Grafana, Loki)
- Docker containerization with cargo-chef optimization
- GitHub Actions CI/CD pipeline for DockerHub publishing
- Development dashboard with service overview
- Configurable transaction explorer integration (Solscan)
- Health check and metrics endpoints
- Responsive web UI with Tailwind CSS

### Features
- Environment-based configuration (no hardcoded values)
- Multi-stage Docker builds for optimal caching
- Readonly database access for security
- Centralized logging with Promtail and Loki
- Real-time transaction display with clickable explorer links
- pgAdmin integration for database management

### Technical
- Cargo-chef for efficient Docker layer caching
- Multi-platform Docker builds (amd64/arm64)
- Comprehensive .dockerignore for build optimization
- Secure credential management via environment variables
