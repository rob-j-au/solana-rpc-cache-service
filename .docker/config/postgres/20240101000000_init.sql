-- Create schema and transactions table
CREATE SCHEMA IF NOT EXISTS solana;

CREATE TABLE IF NOT EXISTS solana.transactions (
    id SERIAL PRIMARY KEY,
    signature VARCHAR(128) NOT NULL UNIQUE,
    block_time TIMESTAMP WITH TIME ZONE,
    slot BIGINT NOT NULL,
    fee BIGINT,
    status VARCHAR(20) DEFAULT 'success',
    signer VARCHAR(64) NOT NULL,
    instructions_count INT DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_transactions_block_time ON solana.transactions(block_time DESC);

-- Create readonly user for pgAdmin
CREATE USER IF NOT EXISTS solana_readonly WITH PASSWORD 'readonly';
GRANT CONNECT ON DATABASE solana TO solana_readonly;
GRANT USAGE ON SCHEMA solana TO solana_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA solana TO solana_readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA solana TO solana_readonly;

-- Ensure future tables are also readable by readonly user
ALTER DEFAULT PRIVILEGES IN SCHEMA solana GRANT SELECT ON TABLES TO solana_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA solana GRANT SELECT ON SEQUENCES TO solana_readonly;
