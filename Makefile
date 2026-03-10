# Solana RPC Cache Service - Development Makefile

.PHONY: help setup up down logs build rebuild clean db-shell ps migrate

# Default target
help:
	@echo "Solana RPC Cache Service - Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup     - Copy .env.example to .env"
	@echo ""
	@echo "Docker:"
	@echo "  make up        - Start all services"
	@echo "  make down      - Stop all services"
	@echo "  make logs      - Follow logs"
	@echo "  make ps        - Show running containers"
	@echo "  make build     - Build images"
	@echo "  make rebuild   - Rebuild images (no cache)"
	@echo "  make clean     - Remove containers and volumes"
	@echo ""
	@echo "Database:"
	@echo "  make db-shell  - Open PostgreSQL shell"
	@echo "  make migrate   - Run database migrations"
	@echo ""
	@echo "Development:"
	@echo "  make dev       - Run locally with cargo"

# Setup
setup:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "Created .env from .env.example"; \
	else \
		echo ".env already exists"; \
	fi

# Docker commands
up:
	docker-compose up -d
	@echo ""
	@echo "Services started. Open http://localhost:8080"

down:
	docker-compose down

logs:
	docker-compose logs -f

ps:
	docker-compose ps

build:
	docker-compose build

rebuild:
	docker-compose build --no-cache

clean:
	docker-compose down -v
	@echo "Containers and volumes removed"

# Database
db-shell:
	docker exec -it solana-rpc-cache-service-postgres psql -U solana

migrate:
	@echo "Running migrations..."
	docker-compose up postgres-migrate
	@echo "Migrations complete"

# Local development
dev:
	@echo "Starting PostgreSQL..."
	docker-compose up -d postgres
	@echo "Waiting for PostgreSQL..."
	@sleep 3
	@echo "Running application..."
	DATABASE_URL=postgres://solana:solana@localhost:5432/solana cargo run
