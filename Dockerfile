# Optimized Dockerfile for solana-rpc-cache-service using cargo-chef
# ============================================================================
# Chef Stage - Base image with cargo-chef
# ============================================================================
FROM lukemathwalker/cargo-chef:latest-rust-1.83-alpine AS chef

# Install build dependencies
RUN apk add --no-cache \
    musl-dev \
    pkgconfig \
    openssl-dev \
    openssl-libs-static

WORKDIR /build

# ============================================================================
# Planner Stage - Analyze dependencies
# ============================================================================
FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# ============================================================================
# Builder Stage - Build dependencies then application
# ============================================================================
FROM chef AS builder

# Build dependencies (this layer will be cached unless dependencies change)
COPY --from=planner /build/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

# Copy source code and build application
COPY . .
RUN cargo build --release && \
    strip target/release/solana-rpc-cache-service

# ============================================================================
# Runtime Stage
# ============================================================================
FROM alpine:3.21

# Install runtime dependencies and create user in single layer
RUN apk add --no-cache ca-certificates curl && \
    adduser -D -u 1000 -s /bin/sh app

WORKDIR /app

# Copy binary with correct ownership
COPY --from=builder --chown=app:app /build/target/release/solana-rpc-cache-service ./solana-rpc-cache-service

USER app

EXPOSE 8080

# Use curl instead of wget for healthcheck (already installed)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["./solana-rpc-cache-service"]
