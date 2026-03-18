SELECT * FROM Loan_risk.loan_data_cleaned;

SELECT * FROM loan_data_cleaned;

-- Credit score vs approval (core risk insight)
SELECT COUNT(*) AS total_applicants, loan_approved_ AS approval_status,
ROUND(AVG(credit_score),2) AS avg_credit_score
FROM loan_data_cleaned
WHERE credit_score IS NOT NULL
group by loan_approved_
;
  
-- Approval rate by credit score ranges (great for bar charts and threshold discussion)
SELECT 
    CASE 
        WHEN credit_score >= 800 THEN '800+ (Exceptional)'
        WHEN credit_score >= 740 THEN '740-799 (Very Good)'
        WHEN credit_score >= 670 THEN '670-739 (Good)'
        WHEN credit_score >= 580 THEN '580-669 (Fair)'
        ELSE 'Below 580 (Poor)'
    END AS credit_range,
    COUNT(*) AS total_applicants,
    -- Since loan_approved is 0 or 1, SUM gives the count of approvals
    ROUND(100.0 * SUM(loan_approved) / COUNT(*), 2) AS approval_rate_pct
FROM loan_data_cleaned
WHERE credit_score IS NOT NULL
GROUP BY 1
ORDER BY MIN(credit_score) DESC;

-- Loan-to-income ratio vs approval
SELECT 
    CASE 
        WHEN (loan_amount / income) <= .50 THEN 'Low Risk'
        WHEN (loan_amount / income) <= .75 THEN 'Moderate Risk '
        WHEN (loan_amount / income) <= .85 THEN 'High Risk'
        ELSE 'Extreme Risk'
    END AS lti_category,
    COUNT(*) AS total_applicants,
    ROUND(100.0 * SUM(loan_approved) / COUNT(*), 2) AS approval_rate_pct
FROM loan_data_cleaned
WHERE income > 0 
GROUP BY 1
ORDER BY MIN(loan_amount / income) ASC;

-- Approval rate by employment type
SELECT 
    employment_type,
    COUNT(*) AS total_applicants,
    SUM(loan_approved) AS approved_count,
    ROUND(100.0 * SUM(loan_approved) / COUNT(*), 2) AS approval_rate_percent
FROM loan_data_cleaned
GROUP BY employment_type
ORDER BY approval_rate_percent DESC;

-- City-level loan-to-income + approval rate
SELECT 
    city,
    COUNT(*) AS total_applicants,
    -- Calculate Average Loan-to-Income Ratio
    ROUND(AVG(loan_amount / income), 2) AS avg_lti_ratio,
    -- Calculate Approval Rate using the 0/1 logic
    ROUND(100.0 * SUM(loan_approved) / COUNT(*), 2) AS approval_rate_percent
FROM loan_data_cleaned
WHERE income > 0 -- Avoid division by zero errors
GROUP BY city
ORDER BY approval_rate_percent DESC;