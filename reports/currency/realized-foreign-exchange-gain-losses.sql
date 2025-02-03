| #  | Transaction Date | Total Realized FX Gains | Total Realized FX Losses | Net Realized FX Gain/Loss | Gain/Loss Type       |
|----|----------------|----------------------|----------------------|----------------------|------------------|
| 1  | 2025-01-01     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 2  | 2025-01-02     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 3  | 2025-01-03     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 4  | 2025-01-04     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 5  | 2025-01-05     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 6  | 2025-01-06     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 7  | 2025-01-07     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 8  | 2025-01-08     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 9  | 2025-01-09     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 10 | 2025-01-10     | 0.00                 | 0.00                 | 0.00                 | No Gain/Loss     |
| 11 | —              | 0.00                 | 0.00                 | 0.00                 | No Net Gain/Loss |

Algorithm:
  
Realized_Foreign_Exchange_Gains_Losses(startDate, endDate):
  1. Retrieve all foreign exchange (FX) transactions within the specified date range (startDate to endDate):
     - These transactions could include payments, receipts, or conversions involving foreign currencies.
  2. For each FX transaction, extract the following details:
     - Transaction date
     - Original currency amount
     - Original currency exchange rate at the time of the transaction
     - Settlement amount (in local or functional currency)
     - Settlement exchange rate (when the transaction was closed or settled)
  3. Calculate the realized FX gain or loss for each transaction:
     - Realized Gain/Loss = (Settlement Amount - Original Amount) * (Settlement Exchange Rate - Original Exchange Rate).
     - If the result is positive, it is a gain; if negative, it is a loss.
  4. Summarize the realized FX gains and losses for all transactions within the specified period:
     - Total Realized FX Gains = Sum of all positive realized gains.
     - Total Realized FX Losses = Sum of all negative realized losses.
  5. Validate the data (ensure all transactions have correct exchange rates, amounts, and settlement details).
  6. Store the Realized FX Gains/Losses report and return the results:
     - Include the realized gains and losses for each transaction, along with the total realized FX gains and losses for the period.

 SQL:      
-- Step 1: Generate a series of dates within the specified range
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 2: Retrieve all FX transactions within the specified date range
fx_transactions AS (
    SELECT
        fx.transaction_id,
        fx.transaction_date,
        fx.original_currency_amount,
        fx.original_exchange_rate,
        fx.settlement_amount,
        fx.settlement_exchange_rate
    FROM acc_fx_transactions fx
    WHERE fx.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
),

-- Step 3: Compute the realized FX gain/loss per transaction (rounded to 2 decimal places)
fx_gains_losses AS (
    SELECT
        transaction_id,
        transaction_date,
        original_currency_amount,
        original_exchange_rate,
        settlement_amount,
        settlement_exchange_rate,
        ROUND(settlement_amount - (original_currency_amount * original_exchange_rate), 2) AS realized_fx_gain_loss
    FROM fx_transactions
),

-- Step 4: Aggregate the daily realized FX gains and losses (rounded to 2 decimal places)
daily_summary AS (
    SELECT 
        ds.transaction_date,
        ROUND(COALESCE(SUM(CASE WHEN f.realized_fx_gain_loss > 0 THEN f.realized_fx_gain_loss ELSE 0 END), 0), 2) AS total_realized_fx_gains,
        ROUND(COALESCE(SUM(CASE WHEN f.realized_fx_gain_loss < 0 THEN f.realized_fx_gain_loss ELSE 0 END), 0), 2) AS total_realized_fx_losses,
        ROUND(COALESCE(SUM(f.realized_fx_gain_loss), 0), 2) AS net_realized_fx_gain_loss
    FROM DateSeries ds
    LEFT JOIN fx_gains_losses f ON ds.transaction_date = f.transaction_date
    GROUP BY ds.transaction_date
),

-- Step 5: Compute total realized FX gains and losses across the period (rounded to 2 decimal places)
summarized_results AS (
    SELECT 
        ROUND(SUM(total_realized_fx_gains), 2) AS total_realized_fx_gains,
        ROUND(SUM(total_realized_fx_losses), 2) AS total_realized_fx_losses,
        ROUND(SUM(net_realized_fx_gain_loss), 2) AS net_realized_fx_gain_loss
    FROM daily_summary
)

-- Step 6: Return detailed daily summary along with total summary
SELECT 
    transaction_date,
    total_realized_fx_gains,
    total_realized_fx_losses,
    net_realized_fx_gain_loss,
    CASE 
        WHEN net_realized_fx_gain_loss > 0 THEN 'Gain'
        WHEN net_realized_fx_gain_loss < 0 THEN 'Loss'
        ELSE 'No Gain/Loss'
    END AS gain_loss_type
FROM daily_summary

UNION ALL  -- This adds a total row at the bottom

-- Append the total realized FX gains and losses for the period
SELECT 
    NULL AS transaction_date,
    total_realized_fx_gains,
    total_realized_fx_losses,
    net_realized_fx_gain_loss,
    CASE 
        WHEN net_realized_fx_gain_loss > 0 THEN 'Total Gain'
        WHEN net_realized_fx_gain_loss < 0 THEN 'Total Loss'
        ELSE 'No Net Gain/Loss'
    END AS gain_loss_type
FROM summarized_results

ORDER BY transaction_date NULLS LAST; -- Ensures total row is at the bottom
