| #   | transaction_date | tax_category | total_tax_collected | total_tax_paid | net_tax | num_transactions | entity_id | total_tax_collected_by_entity | total_tax_paid_by_entity |
|-----|------------------|--------------|----------------------|----------------|---------|-------------------|-----------|------------------------------|--------------------------|
| 1   | 2025-01-01       | Income Tax   | 480.00               | 350.00         | 130.00  | 4                 | 3         | 300.00                       | 200.00                   |
| 2   | 2025-01-01       | Income Tax   | 480.00               | 350.00         | 130.00  | 4                 | 6         | 180.00                       | 150.00                   |
| 3   | 2025-01-01       | Sales Tax    | 200.00               | 170.00         | 30.00   | 4                 | 1         | 150.00                       | 100.00                   |
| 4   | 2025-01-01       | Sales Tax    | 200.00               | 170.00         | 30.00   | 4                 | 4         | 50.00                        | 70.00                    |
| 5   | 2025-01-01       | VAT          | 320.00               | 150.00         | 170.00  | 4                 | 2         | 200.00                       | 50.00                    |
| 6   | 2025-01-01       | VAT          | 320.00               | 150.00         | 170.00  | 4                 | 5         | 120.00                       | 100.00                   |
| 7   | 2025-01-02       | Income Tax   | 480.00               | 350.00         | 130.00  | 4                 | 3         | 300.00                       | 200.00                   |
| 8   | 2025-01-02       | Income Tax   | 480.00               | 350.00         | 130.00  | 4                 | 6         | 180.00                       | 150.00                   |
| 9   | 2025-01-02       | Sales Tax    | 200.00               | 170.00         | 30.00   | 4                 | 1         | 150.00                       | 100.00                   |
| 10  | 2025-01-02       | Sales Tax    | 200.00               | 170.00         | 30.00   | 4                 | 4         | 50.00                        | 70.00                    |
| 11  | 2025-01-02       | VAT          | 320.00               | 150.00         | 170.00  | 4                 | 2         | 200.00                       | 50.00                    |
| 12  | 2025-01-02       | VAT          | 320.00               | 150.00         | 170.00  | 4                 | 5         | 120.00                       | 100.00                   |
| 13  | 2025-01-03       | Income Tax   | 480.00               | 350.00         | 130.00  | 4                 | 3         | 300.00                       | 200.00                   |
| 14  | 2025-01-03       | Income Tax   | 480.00               | 350.00         | 130.00  | 4                 | 6         | 180.00                       | 150.00                   |
| 15  | 2025-01-03       | Sales Tax    | 200.00               | 170.00         | 30.00   | 4                 | 1         | 150.00                       | 100.00                   |
| 16  | 2025-01-03       | Sales Tax    | 200.00               | 170.00         | 30.00   | 4                 | 4         | 50.00                        | 70.00                    |
| 17  | 2025-01-03       | VAT          | 320.00               | 150.00         | 170.00  | 4                 | 2         | 200.00                       | 50.00                    |
| 18  | 2025-01-03       | VAT          | 320.00               | 150.00         | 170.00  | 4                 | 5         | 120.00                       | 100.00                   |
| 19  | 2025-01-04       | Income Tax   | 480.00               | 350.00         | 130.00  | 4                 | 3         | 300.00                       | 200.00                   |
| 20  | 2025-01-04       | Income Tax   | 480.00               | 350.00         | 130.00  | 4                 | 6         | 180.00                       | 150.00                   |
| 21  | 2025-01-04       | Sales Tax    | 200.00               | 170.00         | 30.00   | 4                 | 1         | 150.00                       | 100.00                   |
| 22  | 2025-01-04       | Sales Tax    | 200.00               | 170.00         | 30.00   | 4                 | 4         | 50.00                        | 70.00                    |
| 23  | 2025-01-04       | VAT          | 320.00               | 150.00         | 170.00  | 4                 | 2         | 200.00                       | 50.00                    |
| 24  | 2025-01-04       | VAT          | 320.00               | 150.00         | 170.00  | 4                 | 5         | 120.00                       | 100.00                   |


Algorithm:
  
Comprehensive_Tax_Summary(startDate, endDate):
  1. Retrieve all tax-related transactions within the specified date range (startDate to endDate).
  2. Group the transactions by tax category (e.g., sales tax, VAT, income tax, etc.).
  3. For each tax category, calculate the total tax amount collected or paid:
     Total Tax Collected = Sum of all tax amounts collected for the category.
     Total Tax Paid = Sum of all tax amounts paid for the category.
  4. Optionally, group the tax transactions by entity (e.g., vendor, customer, project) to provide further breakdown.
  5. Calculate the net tax liability or refund for each tax category:
     Net Tax = Total Tax Collected - Total Tax Paid.
  6. Calculate the overall total tax collected and paid across all tax categories.
  7. Optionally, calculate the total tax per region or jurisdiction if applicable.
  8. Validate the tax amounts (ensure no invalid or negative tax values).
  9. Store the comprehensive tax summary data (tax category totals, liabilities, refunds, etc.) and return the results.

  SQL:
  WITH DateSeries AS (
    -- Generate a series of dates from startDate to endDate to ensure daily records
    SELECT generate_series(
        '2025-01-01'::DATE, 
        '2025-12-31'::DATE, 
        INTERVAL '1 day'
    )::DATE AS transaction_date
),
TaxTransactions AS (
    -- Retrieve all tax-related transactions within the specified date range
    SELECT
        tt.transaction_id,
        tt.tax_category,
        tt.tax_amount,
        tt.transaction_type,  -- 'collected' or 'paid'
        tt.entity_id,         -- vendor, customer, project, etc.
        tt.region,            -- if applicable, for region-specific taxes
        tt.transaction_date
    FROM acc_tax_transactions tt
    WHERE tt.transaction_date BETWEEN '2025-01-01' AND '2025-12-31'
      AND tt.tax_amount > 0  -- Ensure valid (positive) tax amounts
),
TaxSummary AS (
    -- Group transactions by tax category and calculate totals
    SELECT
        tt.tax_category,
        SUM(CASE WHEN tt.transaction_type = 'collected' THEN tt.tax_amount ELSE 0 END) AS total_tax_collected,
        SUM(CASE WHEN tt.transaction_type = 'paid' THEN tt.tax_amount ELSE 0 END) AS total_tax_paid,
        COUNT(tt.transaction_id) AS num_transactions,
        -- Calculate net tax liability (or refund) for each tax category
        SUM(CASE WHEN tt.transaction_type = 'collected' THEN tt.tax_amount ELSE 0 END) -
        SUM(CASE WHEN tt.transaction_type = 'paid' THEN tt.tax_amount ELSE 0 END) AS net_tax
    FROM TaxTransactions tt
    GROUP BY tt.tax_category
),
TaxEntityBreakdown AS (
    -- Optionally, group by entity (vendor, customer, project, etc.)
    SELECT
        tt.tax_category,
        tt.entity_id,
        SUM(CASE WHEN tt.transaction_type = 'collected' THEN tt.tax_amount ELSE 0 END) AS total_tax_collected_by_entity,
        SUM(CASE WHEN tt.transaction_type = 'paid' THEN tt.tax_amount ELSE 0 END) AS total_tax_paid_by_entity
    FROM TaxTransactions tt
    GROUP BY tt.tax_category, tt.entity_id
)
-- Join the DateSeries to ensure daily records and calculate the overall tax summary
SELECT
    ds.transaction_date,
    ts.tax_category,
    ts.total_tax_collected,
    ts.total_tax_paid,
    ts.net_tax,
    ts.num_transactions,
    -- Optional: Detailed breakdown of tax by entity
    teb.entity_id,
    teb.total_tax_collected_by_entity,
    teb.total_tax_paid_by_entity
FROM DateSeries ds
LEFT JOIN TaxSummary ts
    ON ds.transaction_date BETWEEN '2025-01-01' AND '2025-12-31'  -- Date range for tax transactions
LEFT JOIN TaxEntityBreakdown teb
    ON ts.tax_category = teb.tax_category
ORDER BY ds.transaction_date, ts.tax_category, teb.entity_id;  -- Optional ordering by date, tax category, and entity
