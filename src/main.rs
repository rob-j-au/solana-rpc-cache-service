use std::convert::Infallible;
use std::net::SocketAddr;
use std::sync::Arc;

use chrono::{DateTime, Utc};
use hyper::service::{make_service_fn, service_fn};
use hyper::{Body, Request, Response, Server, StatusCode};
use serde::{Deserialize, Serialize};
use tokio_postgres::{Client, NoTls};

mod views;

#[derive(Debug, Deserialize)]
struct AppConfig {
    database_url: String,
    tx_display_count: i64,
    port: u16,
    host: String,
    tx_explorer_url: String,
}


fn load_config() -> AppConfig {
    let database_url = std::env::var("DATABASE_URL")
        .expect("DATABASE_URL environment variable is required");
    
    let tx_display_count = std::env::var("APP_TX_DISPLAY_COUNT")
        .expect("APP_TX_DISPLAY_COUNT environment variable is required")
        .parse::<i64>()
        .expect("APP_TX_DISPLAY_COUNT must be a valid integer");

    let port = std::env::var("APP_PORT")
        .expect("APP_PORT environment variable is required")
        .parse::<u16>()
        .expect("APP_PORT must be a valid port number");

    let host = std::env::var("APP_HOST")
        .expect("APP_HOST environment variable is required");

    let tx_explorer_url = std::env::var("APP_TX_EXPLORER_URL")
        .expect("APP_TX_EXPLORER_URL environment variable is required");

    AppConfig {
        database_url,
        tx_display_count,
        port,
        host,
        tx_explorer_url,
    }
}

#[derive(Serialize)]
struct Transaction {
    id: i32,
    signature: String,
    block_time: Option<DateTime<Utc>>,
    slot: i64,
    fee: Option<i64>,
    status: Option<String>,
    signer: String,
    instructions_count: Option<i32>,
}

async fn get_transactions(client: &Client, limit: i64) -> Vec<Transaction> {
    let rows = client
        .query(
            "SELECT id, signature, block_time, slot, fee, status, signer, instructions_count 
             FROM solana.transactions ORDER BY block_time DESC LIMIT $1",
            &[&limit],
        )
        .await
        .unwrap_or_default();

    rows.iter()
        .map(|row| Transaction {
            id: row.get(0),
            signature: row.get(1),
            block_time: row.get(2),
            slot: row.get(3),
            fee: row.get(4),
            status: row.get(5),
            signer: row.get(6),
            instructions_count: row.get(7),
        })
        .collect()
}

async fn get_transaction_count(client: &Client) -> i64 {
    let row = client
        .query_one("SELECT COUNT(*) FROM solana.transactions", &[])
        .await;
    
    match row {
        Ok(r) => r.get::<_, i64>(0),
        Err(_) => 0,
    }
}


async fn handle_request(
    client: Arc<Client>,
    config: Arc<AppConfig>,
    req: Request<Body>,
) -> Result<Response<Body>, Infallible> {
    let response = match req.uri().path() {
        "/" => {
            let transactions = get_transactions(&client, config.tx_display_count).await;
            let html = views::render_transactions_page(&transactions, &config);
            Response::builder()
                .status(StatusCode::OK)
                .header("content-type", "text/html; charset=utf-8")
                .body(Body::from(html))
                .unwrap()
        }

        "/api/transactions" => {
            let transactions = get_transactions(&client, config.tx_display_count).await;
            let json = serde_json::to_string(&transactions).unwrap_or_else(|_| "[]".to_string());
            Response::builder()
                .status(StatusCode::OK)
                .header("content-type", "application/json")
                .body(Body::from(json))
                .unwrap()
        }

        "/health" => Response::builder()
            .status(StatusCode::OK)
            .header("content-type", "application/json")
            .body(Body::from(r#"{"status":"healthy"}"#))
            .unwrap(),

        "/metrics" => {
            let tx_count = get_transaction_count(&client).await;
            let metrics = format!(
                r#"# HELP solana_rpc_cache_service_up Service is up and running
# TYPE solana_rpc_cache_service_up gauge
solana_rpc_cache_service_up 1
# HELP solana_rpc_cache_service_tx_count Total number of transactions in the database
# TYPE solana_rpc_cache_service_tx_count gauge
solana_rpc_cache_service_tx_count {}
"#,
                tx_count
            );
            Response::builder()
                .status(StatusCode::OK)
                .header("content-type", "text/plain; version=0.0.4")
                .body(Body::from(metrics))
                .unwrap()
        }

        _ => Response::builder()
            .status(StatusCode::NOT_FOUND)
            .body(Body::from("Not Found"))
            .unwrap(),
    };

    Ok(response)
}

#[tokio::main]
async fn main() {
    let config = load_config();
    println!("Config loaded: DATABASE_URL={}, TX_DISPLAY_COUNT={}", 
             config.database_url, config.tx_display_count);

    println!("Connecting to database...");
    let (client, connection) = tokio_postgres::connect(&config.database_url, NoTls)
        .await
        .expect("Failed to connect to database");

    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("Database connection error: {}", e);
        }
    });

    let client = Arc::new(client);
    let addr: SocketAddr = format!("{}:{}", config.host, config.port)
        .parse()
        .expect("Invalid host or port configuration");

    let config = Arc::new(config);
    let make_svc = make_service_fn(move |_conn| {
        let client = Arc::clone(&client);
        let config = Arc::clone(&config);
        async move { Ok::<_, Infallible>(service_fn(move |req| handle_request(Arc::clone(&client), Arc::clone(&config), req))) }
    });

    let server = Server::bind(&addr).serve(make_svc);

    println!("Solana RPC Cache Service listening on http://{}", addr);
    println!("Endpoints:");
    println!("  GET /                  - Transactions page");
    println!("  GET /api/transactions  - JSON API");
    println!("  GET /health            - Health check");
    println!("  GET /metrics           - Prometheus metrics");

    if let Err(e) = server.await {
        eprintln!("Server error: {}", e);
    }
}
