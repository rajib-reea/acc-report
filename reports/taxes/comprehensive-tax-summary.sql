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
-- Define the date parameters
\set startDate '2025-01-01'
\set endDate '2025-12-31'

WITH TaxTransactions AS (
    -- Step 1: Retrieve all tax-related transactions within the specified date range
    SELECT
        tt.transaction_id,
        tt.tax_category,
        tt.tax_amount,
        tt.transaction_type,  -- 'collected' or 'paid'
        tt.entity_id,         -- vendor, customer, project, etc.
        tt.region,            -- if applicable, for region-specific taxes
        tt.transaction_date
    FROM tax_transactions tt
    WHERE tt.transaction_date BETWEEN :startDate AND :endDate
      AND tt.tax_amount > 0 -- Ensure valid tax amounts (non-negative)
),
TaxSummary AS (
    -- Step 2 & 3: Group transactions by tax category and calculate totals
    -- Calculate the total tax collected and paid for each tax category
    SELECT
        tt.tax_category,
        SUM(CASE WHEN tt.transaction_type = 'collected' THEN tt.tax_amount ELSE 0 END) AS total_tax_collected,
        SUM(CASE WHEN tt.transaction_type = 'paid' THEN tt.tax_amount ELSE 0 END) AS total_tax_paid,
        COUNT(tt.transaction_id) AS num_transactions,
        -- Step 5: Calculate net tax liability (or refund) for each tax category
        SUM(CASE WHEN tt.transaction_type = 'collected' THEN tt.tax_amount ELSE 0 END) -
        SUM(CASE WHEN tt.transaction_type = 'paid' THEN tt.tax_amount ELSE 0 END) AS net_tax
    FROM TaxTransactions tt
    GROUP BY tt.tax_category
),
TaxEntityBreakdown AS (
    -- Step 4: Optionally, group by entity (e.g., vendor, customer, project)
    SELECT
        tt.tax_category,
        tt.entity_id,
        SUM(CASE WHEN tt.transaction_type = 'collected' THEN tt.tax_amount ELSE 0 END) AS total_tax_collected_by_entity,
        SUM(CASE WHEN tt.transaction_type = 'paid' THEN tt.tax_amount ELSE 0 END) AS total_tax_paid_by_entity
    FROM TaxTransactions tt
    GROUP BY tt.tax_category, tt.entity_id
)
-- Step 6: Calculate the overall total tax collected and paid
SELECT
    ts.tax_category,
    ts.total_tax_collected,
    ts.total_tax_paid,
    ts.net_tax,
    ts.num_transactions,
    -- Optional: Get detailed breakdown of tax by entities
    teb.entity_id,
    teb.total_tax_collected_by_entity,
    teb.total_tax_paid_by_entity
FROM TaxSummary ts
LEFT JOIN TaxEntityBreakdown teb ON ts.tax_category = teb.tax_category
ORDER BY ts.tax_category, teb.entity_id;  -- Optional ordering by tax category and entity
