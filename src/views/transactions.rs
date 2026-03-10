use crate::{Transaction, AppConfig};

pub fn render_transactions_page(transactions: &[Transaction], config: &AppConfig) -> String {
    let rows = render_transaction_rows(transactions);
    
    format!(
        include_str!("templates/transactions.html"),
        tx_display_count = config.tx_display_count,
        transaction_rows = rows,
        total_transactions = transactions.len(),
        tx_explorer_url = config.tx_explorer_url
    )
}

fn render_transaction_rows(transactions: &[Transaction]) -> String {
    transactions
        .iter()
        .map(|tx| {
            let time = tx
                .block_time
                .map(|t| t.format("%Y-%m-%d %H:%M:%S").to_string())
                .unwrap_or_else(|| "-".to_string());
            
            let status_class = if tx.status.as_deref() == Some("success") {
                "bg-green-100 text-green-800"
            } else {
                "bg-red-100 text-red-800"
            };
            
            let sig_short = if tx.signature.len() > 16 {
                format!("{}...{}", &tx.signature[..8], &tx.signature[tx.signature.len()-8..])
            } else {
                tx.signature.clone()
            };
            
            let signer_short = if tx.signer.len() > 16 {
                format!("{}...{}", &tx.signer[..8], &tx.signer[tx.signer.len()-8..])
            } else {
                tx.signer.clone()
            };
            
            format!(
                r#"<tr class="hover:bg-gray-50 border-b border-gray-100">
                    <td class="px-4 py-3 text-sm font-mono"><span class="tx-link text-indigo-600 hover:text-indigo-800 hover:underline cursor-pointer" data-sig="{}">{}</span></td>
                    <td class="px-4 py-3 text-sm text-gray-600">{}</td>
                    <td class="px-4 py-3 text-sm text-gray-900">{}</td>
                    <td class="px-4 py-3 text-sm text-gray-600">{}</td>
                    <td class="px-4 py-3"><span class="px-2 py-1 text-xs font-medium rounded-full {}">{}</span></td>
                    <td class="px-4 py-3 text-sm font-mono text-gray-500">{}</td>
                    <td class="px-4 py-3 text-sm text-center text-gray-600">{}</td>
                </tr>"#,
                tx.signature,
                sig_short,
                time,
                tx.slot,
                tx.fee.unwrap_or(0),
                status_class,
                tx.status.as_deref().unwrap_or("unknown"),
                signer_short,
                tx.instructions_count.unwrap_or(0)
            )
        })
        .collect()
}
