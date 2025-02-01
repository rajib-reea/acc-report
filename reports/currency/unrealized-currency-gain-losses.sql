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
-- Step 1: Retrieve all open FX positions (unsettled or pending transactions) within the specified date range
WITH open_fx_positions AS (
    SELECT
        fx.position_id,
        fx.transaction_date,
        fx.original_amount,
        fx.original_exchange_rate,
        fx.current_exchange_rate
    FROM open_fx_positions_table fx
    WHERE fx.transaction_date >= :startDate
      AND fx.transaction_date <= :endDate
      AND fx.settlement_status = 'pending'  -- Only retrieve unsettled (open) positions
),

-- Step 2: Calculate the unrealized FX gain/loss for each open position
unrealized_gains_losses AS (
    SELECT
        position_id,
        transaction_date,
        original_amount,
        original_exchange_rate,
        current_exchange_rate,
        -- Unrealized Gain/Loss = (Current Exchange Rate - Original Exchange Rate) * Original Amount
        (current_exchange_rate - original_exchange_rate) * original_amount AS unrealized_fx_gain_loss
    FROM open_fx_positions
),

-- Step 3: Summarize the unrealized FX gains and losses for all open positions
summarized_results AS (
    SELECT
        SUM(CASE WHEN unrealized_fx_gain_loss > 0 THEN unrealized_fx_gain_loss ELSE 0 END) AS total_unrealized_fx_gains,
        SUM(CASE WHEN unrealized_fx_gain_loss < 0 THEN unrealized_fx_gain_loss ELSE 0 END) AS total_unrealized_fx_losses
    FROM unrealized_gains_losses
)

-- Step 4: Return the unrealized gains and losses for each open FX position, along with the summarized totals
SELECT
    f.position_id,
    f.transaction_date,
    f.original_amount,
    f.original_exchange_rate,
    f.current_exchange_rate,
    f.unrealized_fx_gain_loss,
    CASE
        WHEN f.unrealized_fx_gain_loss > 0 THEN 'Gain'
        WHEN f.unrealized_fx_gain_loss < 0 THEN 'Loss'
        ELSE 'No Gain/Loss'
    END AS gain_loss_type
FROM unrealized_gains_losses f

UNION ALL

-- Step 5: Return the total unrealized FX gains and losses for the period
SELECT
    'Total' AS position_id,
    NULL AS transaction_date,
    NULL AS original_amount,
    NULL AS original_exchange_rate,
    NULL AS current_exchange_rate,
    total_unrealized_fx_gains + total_unrealized_fx_losses AS unrealized_fx_gain_loss,
    CASE
        WHEN total_unrealized_fx_gains + total_unrealized_fx_losses > 0 THEN 'Total Gain'
        WHEN total_unrealized_fx_gains + total_unrealized_fx_losses < 0 THEN 'Total Loss'
        ELSE 'No Net Gain/Loss'
    END AS gain_loss_type
FROM summarized_results
ORDER BY position_id;
