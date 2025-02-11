| #   | customer_id | total_quoted_amount | total_invoiced_amount | total_quotes | converted_quotes | conversion_percentage |
|-----|-------------|---------------------|------------------------|--------------|------------------|-----------------------|
| 1   | 101         | 35200.00            | 35200.00               | 16           | 16               | 100.00                |
| 2   | 102         | 6400.00             | 6400.00                | 4            | 4                | 100.00                |
| 3   | 103         | 8600.00             | 8600.00                | 4            | 4                | 100.00                |
| 4   | 104         | 6600.00             | 6600.00                | 4            | 4                | N/A                   |

Algorithm:

  Quote_Analysis_Report(startDate, endDate):
  1. Retrieve all quotes generated within the specified date range (startDate to endDate).
  2. Group the quotes by customer.
  3. For each quote, calculate the total quoted amount.
  4. Compare the quoted amounts with the actual sales invoices to determine the quote-to-invoice conversion rate.
  5. Calculate the percentage of quotes converted to invoices for each customer.
  6. Validate the amounts (ensure no invalid or negative values).
  7. Store the quote analysis data and return the results.

  SQL:

WITH DateSeries AS (
    -- Generate a series of dates from startDate to endDate to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
QuoteData AS (
    -- Step 1: Retrieve all quotes within the specified date range
    SELECT
        q.customer_id,
        q.quote_id,
        q.total_amount AS quoted_amount
    FROM acc_quotes q
    WHERE q.created_at BETWEEN '2025-01-01' AND '2025-12-31'
),
InvoiceData AS (
    -- Step 4: Retrieve sales invoices that are linked to quotes
    SELECT 
        i.customer_id,
        -- Add the correct field that links invoices to quotes
        i.total_amount AS invoiced_amount
    FROM acc_invoices i
    WHERE i.created_at BETWEEN '2025-01-01' AND '2025-12-31'
),
QuoteInvoiceComparison AS (
    -- Step 3: Compare quoted amounts with invoiced amounts and calculate the conversion rate
    SELECT 
        qd.customer_id,
        qd.quote_id,
        qd.quoted_amount,
        COALESCE(id.invoiced_amount, 0) AS invoiced_amount,
        CASE
            WHEN qd.quoted_amount > 0 THEN 
                ROUND(COALESCE(id.invoiced_amount, 0) * 100.0 / qd.quoted_amount, 2) 
            ELSE 0
        END AS conversion_rate -- Quote-to-Invoice conversion rate
    FROM QuoteData qd
    LEFT JOIN InvoiceData id ON qd.customer_id = id.customer_id -- Adjusted join condition
),
CustomerQuoteAnalysis AS (
    -- Step 5: Calculate the percentage of quotes converted to invoices for each customer
    SELECT 
        customer_id,
        SUM(quoted_amount) AS total_quoted_amount,
        SUM(invoiced_amount) AS total_invoiced_amount,
        COUNT(quote_id) AS total_quotes,
        COUNT(CASE WHEN invoiced_amount > 0 THEN 1 END) AS converted_quotes,
        CASE 
            WHEN SUM(quoted_amount) > 0 THEN 
                ROUND(SUM(invoiced_amount) * 100.0 / SUM(quoted_amount), 2)
            ELSE 0
        END AS conversion_percentage
    FROM QuoteInvoiceComparison
    GROUP BY customer_id
)
-- Step 7: Store and return the quote analysis report
SELECT 
    customer_id,
    total_quoted_amount,
    total_invoiced_amount,
    total_quotes,
    converted_quotes,
    conversion_percentage
FROM CustomerQuoteAnalysis
ORDER BY customer_id;

