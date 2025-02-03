| #  | transaction_date | total_unrealized_fx_gains | total_unrealized_fx_losses | net_unrealized_fx_gain_loss | gain_loss_type  |
|----|------------------|----------------------------|-----------------------------|-----------------------------|-----------------|
| 1  | 2025-01-01       | 50.00                      | 0                           | 50.00                       | Gain            |
| 2  | 2025-01-02       | 0                          | -30.00                      | -30.00                      | Loss            |
| 3  | 2025-01-03       | 12.00                      | 0                           | 12.00                       | Gain            |
| 4  | 2025-01-04       | 26.00                      | 0                           | 26.00                       | Gain            |
| 5  | 2025-01-05       | 0                          | -60.00                      | -60.00                      | Loss            |
| 6  | 2025-01-06       | 0                          | -17.00                      | -17.00                      | Loss            |
| 7  | 2025-01-07       | 48.00                      | 0                           | 48.00                       | Gain            |
| 8  | 2025-01-08       | 36.00                      | 0                           | 36.00                       | Gain            |
| 9  | 2025-01-09       | 28.00                      | 0                           | 28.00                       | Gain            |
| 10 | 2025-01-10       | 0                          | 0                           | 0.00                        | No Gain/Loss    |
| 11 |                  | 200.00                     | -107.00                     | 93.00                       | Total Gain      |


Algorithm:
  
Unrealized_Currency_Gains_Losses(startDate, endDate):
  1. Retrieve all open FX positions (unsettled or pending transactions) for the specified date range (startDate to endDate):
     - These transactions represent foreign currency balances that have not yet been settled.
  2. For each open FX position, extract the following details:
     - Transaction date
     - Original amount in the foreign currency
     - Original exchange rate at the time of the transaction
     - Current exchange rate (as of the end of the reporting period)
  3. Calculate the unrealized FX gain or loss for each open position:
     - Unrealized Gain/Loss = (Current Exchange Rate - Original Exchange Rate) * Original Amount.
     - If the result is positive, it is a gain; if negative, it is a loss.
  4. Summarize the unrealized FX gains and losses for all open FX positions:
     - Total Unrealized FX Gains = Sum of all positive unrealized gains.
     - Total Unrealized FX Losses = Sum of all negative unrealized losses.
  5. Validate the data (ensure all positions have correct exchange rates and amounts).
  6. Store the Unrealized FX Gains/Losses report and return the results:
     - Include the unrealized gains and losses for each open FX position, along with the total unrealized FX gains and losses for the period.

SQL:       
-- Step 1: Generate a series of dates within the specified range
WITH DateSeries AS (
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-01-10'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),

-- Step 2: Retrieve all open FX positions (unsettled or pending transactions) within the specified date range
open_fx_positions AS (
    SELECT
        fx.position_id,
        fx.transaction_date,
        fx.original_amount,
        fx.original_exchange_rate,
        fx.current_exchange_rate
    FROM acc_open_fx_transactions fx
    WHERE fx.transaction_date BETWEEN '2025-01-01' AND '2025-01-10'
      AND fx.settlement_status = 'pending'  -- Only retrieve unsettled (open) positions
),

-- Step 3: Calculate the unrealized FX gain/loss for each open position
unrealized_gains_losses AS (
    SELECT
        position_id,
        transaction_date,
        original_amount,
        original_exchange_rate,
        current_exchange_rate,
        -- Unrealized Gain/Loss = (Current Exchange Rate - Original Exchange Rate) * Original Amount
        ROUND((current_exchange_rate - original_exchange_rate) * original_amount, 2) AS unrealized_fx_gain_loss
    FROM open_fx_positions
),

-- Step 4: Aggregate the daily unrealized FX gains and losses
daily_summary AS (
    SELECT 
        ds.transaction_date,
        COALESCE(SUM(CASE WHEN u.unrealized_fx_gain_loss > 0 THEN u.unrealized_fx_gain_loss ELSE 0 END), 0) AS total_unrealized_fx_gains,
        COALESCE(SUM(CASE WHEN u.unrealized_fx_gain_loss < 0 THEN u.unrealized_fx_gain_loss ELSE 0 END), 0) AS total_unrealized_fx_losses,
        COALESCE(SUM(u.unrealized_fx_gain_loss), 0) AS net_unrealized_fx_gain_loss
    FROM DateSeries ds
    LEFT JOIN unrealized_gains_losses u ON ds.transaction_date = u.transaction_date
    GROUP BY ds.transaction_date
),

-- Step 5: Compute total unrealized FX gains and losses across the period
summarized_results AS (
    SELECT 
        SUM(total_unrealized_fx_gains) AS total_unrealized_fx_gains,
        SUM(total_unrealized_fx_losses) AS total_unrealized_fx_losses,
        SUM(net_unrealized_fx_gain_loss) AS net_unrealized_fx_gain_loss
    FROM daily_summary
)

-- Step 6: Return detailed daily summary along with total summary
SELECT 
    transaction_date,
    total_unrealized_fx_gains,
    total_unrealized_fx_losses,
    net_unrealized_fx_gain_loss,
    CASE 
        WHEN net_unrealized_fx_gain_loss > 0 THEN 'Gain'
        WHEN net_unrealized_fx_gain_loss < 0 THEN 'Loss'
        ELSE 'No Gain/Loss'
    END AS gain_loss_type
FROM daily_summary

UNION ALL

-- Append the total unrealized FX gains and losses for the period
SELECT 
    NULL AS transaction_date,
    total_unrealized_fx_gains,
    total_unrealized_fx_losses,
    net_unrealized_fx_gain_loss,
    CASE 
        WHEN net_unrealized_fx_gain_loss > 0 THEN 'Total Gain'
        WHEN net_unrealized_fx_gain_loss < 0 THEN 'Total Loss'
        ELSE 'No Net Gain/Loss'
    END AS gain_loss_type
FROM summarized_results

ORDER BY transaction_date NULLS LAST;
