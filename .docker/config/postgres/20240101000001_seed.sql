-- Seed 500 real transactions from Solscan (only if table is empty)
DO $$
DECLARE
    signers TEXT[] := ARRAY[
        'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4',
        'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc',
        'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
        'So11111111111111111111111111111111111111112',
        'orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE',
        'PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY',
        'MangoCzJ36AjZyKwVj3VnYU4GTonjfVEnJmvvWaxLac',
        'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s',
        'CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK',
        '11111111111111111111111111111111'
    ];
    csv_row RECORD;
    row_count INTEGER := 0;
BEGIN
    -- Only seed if table is empty
    IF NOT EXISTS (SELECT 1 FROM solana.transactions LIMIT 1) THEN
        -- Create temporary table to load CSV data
        CREATE TEMP TABLE temp_transactions (
            txid TEXT,
            date_utc TEXT
        );
        
        -- Copy CSV data into temporary table
        COPY temp_transactions(txid, date_utc) 
        FROM '/postgres/tx_seeds.csv' 
        DELIMITER ',' 
        CSV HEADER;
        
        -- Insert transactions from CSV with generated additional fields
        FOR csv_row IN 
            SELECT txid, date_utc FROM temp_transactions
        LOOP
            row_count := row_count + 1;
            
            INSERT INTO solana.transactions (
                signature, 
                block_time, 
                slot, 
                fee, 
                status, 
                signer, 
                instructions_count
            ) VALUES (
                csv_row.txid,
                csv_row.date_utc::timestamptz,
                285000000 + row_count,
                5000 + floor(random() * 50000)::int,
                CASE WHEN random() > 0.05 THEN 'success' ELSE 'failed' END,
                signers[1 + floor(random() * array_length(signers, 1))::int],
                1 + floor(random() * 20)::int
            );
        END LOOP;
        
        -- Drop temporary table
        DROP TABLE temp_transactions;
        
        RAISE NOTICE 'Seeded % real transactions from Solscan', row_count;
    END IF;
END $$;
