-- ======================================================================
-- SQL Script for Bank Loan Data Analysis
-- Author: Binh Pham
-- Description: This script contains queries for analyzing bank loan data
-- to assess risk, support decision-making, and derive insights for portfolio
-- management. The results will be used to create visualizations in Power BI.
-- ======================================================================



-- ========================================================================================================================================================================================
-- SECTION 1: ENVIRONMENT SETUP
-- ========================================================================================================================================================================================
-- Description: Setting up the SQL environment, defining schema, and setting configurations.
-- ========================================================================================================================================================================================

-- Set the date format to ensure consistency in date handling
SET DATEFORMAT ymd;

-- Set the transaction isolation level to READ COMMITTED to avoid dirty reads
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Configure the lock timeout to avoid indefinite waiting times for blocked transactions
SET LOCK_TIMEOUT 10000;  -- This sets the lock timeout to 10 seconds

-- Set the arithmetic abort to ON to handle arithmetic overflow errors
SET ARITHABORT ON;

-- Ensure that any NULL values in comparisons evaluate to the lowest possible value
SET ANSI_NULLS ON;

-- Enable optimized joins to improve query performance
SET ANSI_WARNINGS ON;


-- ========================================================================================================================================================================================
-- SECTION 2: DATA OVERVIEW
-- ========================================================================================================================================================================================
-- Description: Initial exploration of the dataset to understand the structure and basic statistics.
-- ========================================================================================================================================================================================

-- Query to display the structure of the dataset 'bank_loan_data'
SELECT 
    COLUMN_NAME AS 'Column',
    DATA_TYPE AS 'Data Type',
    IS_NULLABLE AS 'Is Nullable?',
    CHARACTER_MAXIMUM_LENGTH AS 'Max Length'
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'bank_loan_data'
ORDER BY 
    ORDINAL_POSITION;

-- Basic statistics for 'bank_loan_data' showing total entries and basic counts for key columns
SELECT
    COUNT(*) AS 'Total Entries',
    COUNT(DISTINCT id) AS 'Unique IDs',
    COUNT(DISTINCT address_state) AS 'Unique States',
    COUNT(DISTINCT application_type) AS 'Application Types',
    AVG(annual_income) AS 'Average Annual Income',
    AVG(dti) AS 'Average DTI',
    MAX(loan_amount) AS 'Maximum Loan Amount',
    MIN(loan_amount) AS 'Minimum Loan Amount'
FROM
    bank_loan_data;


-- ========================================================================================================================================================================================
-- SECTION 3: SUMMARY ANALYSIS
-- ========================================================================================================================================================================================
-- Description: Detailed analysis of key performance indicators (KPIs) that measure the overall 
-- performance and health of the loan portfolio.
-- ========================================================================================================================================================================================

-- ---------------------------------------------------------------------
-- 3.1 Key Performance Indicators (KPIs)
-- ---------------------------------------------------------------------
-- Description: Calculation of total loan applications, funded amounts, received amounts,
-- average interest rates, and debt-to-income ratios.
-- ---------------------------------------------------------------------

-- What is the total number of loan applications?
SELECT COUNT(id) AS Total_Applications FROM bank_loan_data;

-- How many loan applications were there in the current month (December)?
SELECT COUNT(id) AS Total_Applications FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- How many loan applications were there in the previous month (November)?
SELECT COUNT(id) AS Total_Applications FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- What is the total funded amount?
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data;

-- What is the total funded amount in the current month (December)?
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- What is the total funded amount in the previous month (November)?
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- What is the total amount received from borrowers?
SELECT SUM(total_payment) AS Total_Amount_Collected FROM bank_loan_data;

-- What is the total amount received in the current month (December)?
SELECT SUM(total_payment) AS Total_Amount_Collected FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- What is the total amount received in the previous month (November)?
SELECT SUM(total_payment) AS Total_Amount_Collected FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- What is the average interest rate across all loans?
SELECT AVG(int_rate)*100 AS Avg_Int_Rate FROM bank_loan_data;

-- What is the average interest rate in the current month (December)?
SELECT AVG(int_rate)*100 AS MTD_Avg_Int_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- What is the average interest rate in the previous month (November)?
SELECT AVG(int_rate)*100 AS PMTD_Avg_Int_Rate FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

-- What is the average Debt-to-Income (DTI) ratio across all loans?
SELECT AVG(dti)*100 AS Avg_DTI FROM bank_loan_data;

-- What is the average Debt-to-Income (DTI) ratio in the current month (December)?
SELECT AVG(dti)*100 AS MTD_Avg_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

-- What is the average Debt-to-Income (DTI) ratio in the previous month (November)?
SELECT AVG(dti)*100 AS PMTD_Avg_DTI FROM bank_loan_data
WHERE MONTH(issue_date) = 11;


-- ---------------------------------------------------------------------
-- 3.2 Good Loan vs Bad Loan KPIs
-- ---------------------------------------------------------------------
-- Description: Analysis to distinguish between good and bad loans, including their amounts,
-- percentages, and impact on the overall portfolio.
-- ---------------------------------------------------------------------

-- What percentage of loans are in good standing ('Fully Paid' or 'Current')?
SELECT
    (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100.0) / 
    COUNT(id) AS Good_Loan_Percentage
FROM bank_loan_data;

-- How many applications are classified as good loans?
SELECT COUNT(id) AS Good_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- What is the total funded amount for good loans?
SELECT SUM(loan_amount) AS Good_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- What is the total amount received from good loans?
SELECT SUM(total_payment) AS Good_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current';

-- What percentage of loans are bad (i.e., 'Charged Off')?
SELECT
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0) / 
    COUNT(id) AS Bad_Loan_Percentage
FROM bank_loan_data;

-- How many applications are classified as bad loans?
SELECT COUNT(id) AS Bad_Loan_Applications FROM bank_loan_data
WHERE loan_status = 'Charged Off';

-- What is the total funded amount for bad loans?
SELECT SUM(loan_amount) AS Bad_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Charged Off';

-- What is the total amount received from bad loans?
SELECT SUM(total_payment) AS Bad_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Charged Off';


-- ---------------------------------------------------------------------
-- 3.3 Loan Status Grid View
-- ---------------------------------------------------------------------
-- Description: A grid view categorization of loans by their statuses to provide insights into
-- different operational metrics of the loan portfolio.
-- ---------------------------------------------------------------------

-- What are the totals and averages for each loan status category?
SELECT
    loan_status,
    COUNT(id) AS Total_Loan_Applications,
    SUM(total_payment) AS Total_Amount_Received,
    SUM(loan_amount) AS Total_Funded_Amount,
    AVG(int_rate * 100) AS Interest_Rate,
    AVG(dti * 100) AS DTI
FROM
    bank_loan_data
GROUP BY
    loan_status;

-- What are the monthly totals for amount received and funded by loan status for the current month (December)?
SELECT 
    loan_status, 
    SUM(total_payment) AS MTD_Total_Amount_Received, 
    SUM(loan_amount) AS MTD_Total_Funded_Amount 
FROM bank_loan_data
WHERE MONTH(issue_date) = 12 
GROUP BY loan_status;



-- ========================================================================================================================================================================================
-- SECTION 4: DETAILED OVERVIEW
-- ========================================================================================================================================================================================
-- Description: Advanced visual-oriented analyses intended for dashboard visualization in Power BI.
-- ========================================================================================================================================================================================

-- ---------------------------------------------------------------------
-- 4.1 Monthly Trends by Issue Date
-- ---------------------------------------------------------------------
-- Description: Analysis of monthly trends over time to identify seasonality and long-term trends.
-- ---------------------------------------------------------------------

-- What are the monthly trends in loan applications, amounts funded, and amounts received?
SELECT 
    MONTH(issue_date) AS Month_Number, 
    DATENAME(MONTH, issue_date) AS Month_name, 
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date);

-- ---------------------------------------------------------------------
-- 4.2 Regional Analysis by State
-- ---------------------------------------------------------------------
-- Description: Geographical analysis to assess regional lending disparities and activities.
-- ---------------------------------------------------------------------

-- What are the state-wise trends in loan applications, amounts funded, and amounts received?
SELECT 
    address_state AS State, 
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY address_state
ORDER BY address_state;

-- ---------------------------------------------------------------------
-- 4.3 Loan Term Analysis
-- ---------------------------------------------------------------------
-- Description: Distribution of loans across different term lengths.
-- ---------------------------------------------------------------------

-- How do different loan terms affect the total applications, funded amounts, and payments received?
SELECT 
    term AS Term, 
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY term
ORDER BY term;

-- ---------------------------------------------------------------------
-- 4.4 Employment Length Analysis
-- ---------------------------------------------------------------------
-- Description: Examination of how employment length influences lending metrics.
-- ---------------------------------------------------------------------

-- How does the length of employment impact loan applications, funding, and payments?
SELECT 
    emp_length AS Employee_Length, 
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY emp_length
ORDER BY emp_length;

-- ---------------------------------------------------------------------
-- 4.5 Loan Purpose Breakdown
-- ---------------------------------------------------------------------
-- Description: Analysis of the reasons borrowers apply for loans, categorized by loan purpose.
-- ---------------------------------------------------------------------

-- What are the loan application, funding, and payment trends by loan purpose?
SELECT 
    purpose AS Purpose, 
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY purpose
ORDER BY purpose;

-- ---------------------------------------------------------------------
-- 4.6 Home Ownership Analysis
-- ---------------------------------------------------------------------
-- Description: Hierarchical analysis of the impact of home ownership on loan applications and disbursements.
-- ---------------------------------------------------------------------

-- How does home ownership status impact loan applications, funded amounts, and payments received?
SELECT 
    home_ownership AS Home_Ownership, 
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data
GROUP BY home_ownership
ORDER BY home_ownership;

-- ======================================================================
-- END OF SCRIPT
-- ======================================================================
