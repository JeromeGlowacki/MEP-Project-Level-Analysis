USE MEP_Projects_Analytics;
GO

/* Top 3 Companies by Annual Revenue and Market Share */

WITH RevenueByCompany AS (
    SELECT 
        year,
        company_name,
        SUM(contract_value_total) AS revenue,
        SUM(contract_value_total) * 100.0 / SUM(SUM(contract_value_total)) OVER (PARTITION BY year) AS market_share_pct,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY SUM(contract_value_total) DESC) AS rn
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY year, company_name
)
SELECT 
    year,
    company_name,
    FORMAT(revenue, 'C', 'en-US') AS revenue_currency,
    CAST(market_share_pct AS DECIMAL(5,2)) AS market_share_pct
FROM RevenueByCompany
WHERE rn <= 3
ORDER BY year DESC, market_share_pct DESC;

/* Top 1 Company Count by Year (How many times each company led in revenue annually) */

WITH RevenueByCompany AS (
    SELECT 
        year,
        company_name,
        SUM(contract_value_total) AS revenue,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY SUM(contract_value_total) DESC) AS rn
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY year, company_name
)
SELECT 
    company_name,
    COUNT(*) AS top1_years_count
FROM RevenueByCompany
WHERE rn <= 1
GROUP BY company_name
ORDER BY top1_years_count DESC;

/* Top 3 Companies by Cumulative Revenue over 10 Years */

SELECT TOP 3
    company_name,
    FORMAT(SUM(contract_value_total), 'C', 'en-US') AS total_revenue_currency,
    CAST(SUM(contract_value_total) * 100.0 / SUM(SUM(contract_value_total)) OVER () AS DECIMAL(5,2)) AS market_share_pct_10yr
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY company_name
ORDER BY SUM(contract_value_total) DESC;

/* Revenue by Project Type Annually */

WITH RevenueByProjectType AS (
    SELECT 
        year,
        project_type,
        SUM(contract_value_total) AS revenue,
        SUM(contract_value_total) * 100.0 / SUM(SUM(contract_value_total)) OVER (PARTITION BY year) AS share_pct,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY SUM(contract_value_total) DESC) AS rn
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY year, project_type
)
SELECT 
    year,
    project_type,
    FORMAT(revenue, 'C', 'en-US') AS revenue_currency,
    CAST(share_pct AS DECIMAL(5,2)) AS market_share_pct
FROM RevenueByProjectType
ORDER BY year DESC, market_share_pct DESC;

/* Revenue by Project Type Across Multi-Year Periods */

WITH RevenueByProjectTypePeriod AS (
    SELECT 
        CASE 
            WHEN year BETWEEN 2016 AND 2018 THEN '2016-2018'
            WHEN year BETWEEN 2019 AND 2020 THEN '2019-2020'
            WHEN year BETWEEN 2021 AND 2022 THEN '2021-2022'
            WHEN year BETWEEN 2023 AND 2024 THEN '2023-2024'
            ELSE 'Other'
        END AS period,
        project_type,
        SUM(contract_value_total) AS revenue
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY 
        CASE 
            WHEN year BETWEEN 2016 AND 2018 THEN '2016-2018'
            WHEN year BETWEEN 2019 AND 2020 THEN '2019-2020'
            WHEN year BETWEEN 2021 AND 2022 THEN '2021-2022'
            WHEN year BETWEEN 2023 AND 2024 THEN '2023-2024'
            ELSE 'Other'
        END,
        project_type
)
SELECT
    period,
    project_type,
    FORMAT(revenue, 'C', 'en-US') AS revenue_currency,
    CAST(revenue * 100.0 / SUM(revenue) OVER (PARTITION BY period) AS DECIMAL(5,2)) AS share_pct
FROM RevenueByProjectTypePeriod
ORDER BY period DESC, share_pct DESC;

/* Revenue Trend for New Build Projects Across Multi-Year Periods */

WITH RevenueByNewBuildPeriod AS (
    SELECT 
        CASE 
            WHEN year BETWEEN 2016 AND 2018 THEN '2016-2018'
            WHEN year BETWEEN 2019 AND 2020 THEN '2019-2020'
            WHEN year BETWEEN 2021 AND 2022 THEN '2021-2022'
            WHEN year BETWEEN 2023 AND 2024 THEN '2023-2024'
            ELSE 'Other'
        END AS period,
        SUM(contract_value_total) AS revenue
    FROM dbo.emcor_like_projects_noisy_extended
    WHERE project_type = 'New Build'
    GROUP BY 
        CASE 
            WHEN year BETWEEN 2016 AND 2018 THEN '2016-2018'
            WHEN year BETWEEN 2019 AND 2020 THEN '2019-2020'
            WHEN year BETWEEN 2021 AND 2022 THEN '2021-2022'
            WHEN year BETWEEN 2023 AND 2024 THEN '2023-2024'
            ELSE 'Other'
        END
)
SELECT
    period,
    FORMAT(revenue, 'C', 'en-US') AS revenue_currency,
    CAST(revenue * 100.0 / SUM(revenue) OVER () AS DECIMAL(5,2)) AS share_pct
FROM RevenueByNewBuildPeriod
ORDER BY period DESC;

/* Revenue Trend for Maintenance Projects Across Multi-Year Periods */

WITH RevenueByMaintenancePeriod AS (
    SELECT 
        CASE 
            WHEN year BETWEEN 2016 AND 2018 THEN '2016-2018'
            WHEN year BETWEEN 2019 AND 2020 THEN '2019-2020'
            WHEN year BETWEEN 2021 AND 2022 THEN '2021-2022'
            WHEN year BETWEEN 2023 AND 2024 THEN '2023-2024'
            ELSE 'Other'
        END AS period,
        SUM(contract_value_total) AS revenue
    FROM dbo.emcor_like_projects_noisy_extended
    WHERE project_type = 'Maintenance'
    GROUP BY 
        CASE 
            WHEN year BETWEEN 2016 AND 2018 THEN '2016-2018'
            WHEN year BETWEEN 2019 AND 2020 THEN '2019-2020'
            WHEN year BETWEEN 2021 AND 2022 THEN '2021-2022'
            WHEN year BETWEEN 2023 AND 2024 THEN '2023-2024'
            ELSE 'Other'
        END
)
SELECT
    period,
    FORMAT(revenue, 'C', 'en-US') AS revenue_currency,
    CAST(revenue * 100.0 / SUM(revenue) OVER () AS DECIMAL(5,2)) AS share_pct
FROM RevenueByMaintenancePeriod
ORDER BY period DESC;

/* Revenue Trend for Retrofit Projects Across Multi-Year Periods */

WITH RevenueByRetrofitPeriod AS (
    SELECT 
        CASE 
            WHEN year BETWEEN 2016 AND 2018 THEN '2016-2018'
            WHEN year BETWEEN 2019 AND 2020 THEN '2019-2020'
            WHEN year BETWEEN 2021 AND 2022 THEN '2021-2022'
            WHEN year BETWEEN 2023 AND 2024 THEN '2023-2024'
            ELSE 'Other'
        END AS period,
        SUM(contract_value_total) AS revenue
    FROM dbo.emcor_like_projects_noisy_extended
    WHERE project_type = 'Retrofit'
    GROUP BY 
        CASE 
            WHEN year BETWEEN 2016 AND 2018 THEN '2016-2018'
            WHEN year BETWEEN 2019 AND 2020 THEN '2019-2020'
            WHEN year BETWEEN 2021 AND 2022 THEN '2021-2022'
            WHEN year BETWEEN 2023 AND 2024 THEN '2023-2024'
            ELSE 'Other'
        END
)
SELECT
    period,
    FORMAT(revenue, 'C', 'en-US') AS revenue_currency,
    CAST(revenue * 100.0 / SUM(revenue) OVER () AS DECIMAL(5,2)) AS share_pct
FROM RevenueByRetrofitPeriod
ORDER BY period DESC;

/* Cumulative Revenue by Project Type Over 10 Years */

WITH CumulativeRevenueAll AS (
    SELECT 
        project_type,
        SUM(contract_value_total) AS total_revenue
    FROM dbo.emcor_like_projects_noisy_extended
    WHERE year BETWEEN 2016 AND 2024
    GROUP BY project_type
)
SELECT
    project_type,
    FORMAT(total_revenue, 'C', 'en-US') AS revenue_currency,
    CAST(total_revenue * 100.0 / SUM(total_revenue) OVER () AS DECIMAL(5,2)) AS share_pct
FROM CumulativeRevenueAll
ORDER BY total_revenue DESC;

/* Revenue by Industry with Project Counts, Avg Project Size, and Margins */

WITH RevenueByIndustry AS (
    SELECT 
        client_industry,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count,
        AVG(contract_value_total) AS avg_revenue_per_project,
        AVG(gross_margin_pct) AS avg_gross_margin_pct,
        AVG(ebitda_margin_pct) AS avg_ebitda_margin_pct,
        AVG(duration_months) AS avg_duration_months
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY client_industry
)
SELECT
    client_industry,
    FORMAT(total_revenue, 'C', 'en-US') AS revenue_currency,
    CAST(total_revenue * 100.0 / SUM(total_revenue) OVER () AS DECIMAL(5,2)) AS share_pct_revenue,
    project_count,
    CAST(project_count * 100.0 / SUM(project_count) OVER () AS DECIMAL(5,2)) AS share_pct_count,
    FORMAT(avg_revenue_per_project, 'C', 'en-US') AS avg_revenue_currency,
    CAST(avg_gross_margin_pct AS DECIMAL(5,2)) AS avg_gross_margin_pct,
    CAST(avg_ebitda_margin_pct AS DECIMAL(5,2)) AS avg_ebitda_margin_pct,
    CAST(avg_duration_months AS DECIMAL(5,1)) AS avg_duration_months
FROM RevenueByIndustry
ORDER BY total_revenue DESC;

/* Revenue by Industry with Project Counts, Avg Project Size, and Margins */

WITH RevenueByClient AS (
    SELECT 
        client_name,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count,
        AVG(contract_value_total) AS avg_revenue_per_project,
        AVG(gross_margin_pct) AS avg_gross_margin_pct,
        AVG(ebitda_margin_pct) AS avg_ebitda_margin_pct,
        AVG(duration_months) AS avg_duration_months
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY client_name
)
SELECT
    client_name,
    FORMAT(total_revenue, 'C', 'en-US') AS revenue_currency,
    CAST(total_revenue * 100.0 / SUM(total_revenue) OVER () AS DECIMAL(5,2)) AS share_pct_revenue,
    project_count,
    CAST(project_count * 100.0 / SUM(project_count) OVER () AS DECIMAL(5,2)) AS share_pct_count,
    FORMAT(avg_revenue_per_project, 'C', 'en-US') AS avg_revenue_currency,
    CAST(avg_gross_margin_pct AS DECIMAL(5,2)) AS avg_gross_margin_pct,
    CAST(avg_ebitda_margin_pct AS DECIMAL(5,2)) AS avg_ebitda_margin_pct,
    CAST(avg_duration_months AS DECIMAL(5,1)) AS avg_duration_months
FROM RevenueByClient
ORDER BY total_revenue DESC;

/* Revenue by Subsector with Project Counts, Avg Project Size, and Margins */

WITH RevenueBySubsector AS (
    SELECT 
        subsector,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count,
        AVG(contract_value_total) AS avg_revenue_per_project,
        AVG(gross_margin_pct) AS avg_gross_margin_pct,
        AVG(ebitda_margin_pct) AS avg_ebitda_margin_pct,
        AVG(duration_months) AS avg_duration_months
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY subsector
)
SELECT
    subsector,
    FORMAT(total_revenue, 'C', 'en-US') AS revenue_currency,
    CAST(total_revenue * 100.0 / SUM(total_revenue) OVER () AS DECIMAL(5,2)) AS share_pct_revenue,
    project_count,
    CAST(project_count * 100.0 / SUM(project_count) OVER () AS DECIMAL(5,2)) AS share_pct_count,
    FORMAT(avg_revenue_per_project, 'C', 'en-US') AS avg_revenue_currency,
    CAST(avg_gross_margin_pct AS DECIMAL(5,2)) AS avg_gross_margin_pct,
    CAST(avg_ebitda_margin_pct AS DECIMAL(5,2)) AS avg_ebitda_margin_pct,
    CAST(avg_duration_months AS DECIMAL(5,1)) AS avg_duration_months
FROM RevenueBySubsector
ORDER BY total_revenue DESC;

/* Revenue by State with Project Counts and Share Percentages */

WITH RevenueByState AS (
    SELECT
        state,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY state
)
SELECT
    state,
    FORMAT(total_revenue, 'C', 'en-US') AS total_revenue_usd,
    project_count,
    CAST(total_revenue * 100.0 / SUM(total_revenue) OVER () AS DECIMAL(5,2)) AS share_pct_revenue,
    CAST(project_count * 100.0 / SUM(project_count) OVER () AS DECIMAL(5,2)) AS share_pct_projects
FROM RevenueByState
ORDER BY total_revenue DESC;

/* Revenue by City with Project Counts and Share Percentages */

WITH RevenueByCity AS (
    SELECT
        city,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY city
)
SELECT
    city,
    FORMAT(total_revenue, 'C', 'en-US') AS total_revenue_usd,
    project_count,
    CAST(total_revenue * 100.0 / SUM(total_revenue) OVER () AS DECIMAL(5,2)) AS share_pct_revenue,
    CAST(project_count * 100.0 / SUM(project_count) OVER () AS DECIMAL(5,2)) AS share_pct_projects
FROM RevenueByCity
ORDER BY total_revenue DESC;

/* Top 3 Companies by Revenue per State */

WITH CompanyRevenueByState AS (
    SELECT
        state,
        company_name,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count,
        ROW_NUMBER() OVER (PARTITION BY state ORDER BY SUM(contract_value_total) DESC) AS rn
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY state, company_name
)
SELECT
    state,
    company_name,
    FORMAT(total_revenue, 'C', 'en-US') AS total_revenue_usd,
    project_count,
    CAST(total_revenue * 100.0 / SUM(total_revenue) OVER (PARTITION BY state) AS DECIMAL(5,2)) AS share_pct_revenue,
    CAST(project_count * 100.0 / SUM(project_count) OVER (PARTITION BY state) AS DECIMAL(5,2)) AS share_pct_projects
FROM CompanyRevenueByState
WHERE rn <= 3
ORDER BY state, total_revenue DESC;

/* Revenue by Region Over Two Multi-Year Periods with Project Counts and Share Percentages */

WITH RevenueByRegionPeriod AS (
    SELECT
        CASE 
            WHEN year BETWEEN 2016 AND 2020 THEN '2016-2020'
            WHEN year BETWEEN 2021 AND 2025 THEN '2021-2025'
            ELSE 'Other'
        END AS period,
        state,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY 
        CASE 
            WHEN year BETWEEN 2016 AND 2020 THEN '2016-2020'
            WHEN year BETWEEN 2021 AND 2025 THEN '2021-2025'
            ELSE 'Other'
        END,
        state
)
SELECT
    period,
    state,
    FORMAT(total_revenue, 'C', 'en-US') AS total_revenue_usd,
    project_count,
    CAST(total_revenue * 100.0 / SUM(total_revenue) OVER (PARTITION BY period) AS DECIMAL(5,2)) AS share_pct_revenue,
    CAST(project_count * 100.0 / SUM(project_count) OVER (PARTITION BY period) AS DECIMAL(5,2)) AS share_pct_projects
FROM RevenueByRegionPeriod
ORDER BY period DESC, total_revenue DESC;

/* 
*Top 3 Clients by Revenue Annually*
Identifies the top 3 revenue-generating clients per year, 
along with their share (%) of yearly revenue.
*/

WITH ClientRevenue AS (
    SELECT 
        year,
        client_name,
        SUM(contract_value_total) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY year 
            ORDER BY SUM(contract_value_total) DESC
        ) AS rn,
        SUM(contract_value_total) * 100.0
            / SUM(SUM(contract_value_total)) OVER (PARTITION BY year) AS share_pct
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY year, client_name
)
SELECT 
    year,
    client_name,
    FORMAT(revenue, 'C', 'en-US') AS revenue_usd,
    CAST(share_pct AS DECIMAL(5,2)) AS share_pct
FROM ClientRevenue
WHERE rn <= 3
ORDER BY year DESC, revenue DESC;

/*
*Top Clients Over 10-Year Period — Expanded Version*
Includes total revenue, share %, project count, average project size,
and average EBITDA margin across the full dataset.
*/

WITH TenYearClientStats AS (
    SELECT 
        client_name,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count,
        AVG(contract_value_total) AS avg_project_value,
        AVG(ebitda_margin_pct) AS avg_ebitda_margin,
        SUM(contract_value_total) * 100.0 
            / SUM(SUM(contract_value_total)) OVER () AS share_pct
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY client_name
)
SELECT 
    TOP 10
    client_name,
    FORMAT(total_revenue, 'C', 'en-US') AS total_revenue_usd,
    CAST(share_pct AS DECIMAL(5,2)) AS share_pct,
    project_count,
    FORMAT(avg_project_value, 'C', 'en-US') AS avg_project_value_usd,
    CAST(avg_ebitda_margin AS DECIMAL(5,2)) AS avg_ebitda_margin_pct
FROM TenYearClientStats
ORDER BY total_revenue DESC;

/* 
Top Customer Concentration per Company (10-Year Average)

This query:
1. Calculates company → client revenue by year.
2. Finds each company’s #1 client per year by revenue.
3. Computes the % of the company’s total annual revenue that went to that top client.
4. Averages that percentage over the full dataset period.
*/

WITH CompanyClientYearly AS (
    SELECT
        year,
        company_name,
        client_name,
        SUM(contract_value_total) AS client_revenue
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY year, company_name, client_name
),
CompanyYearTotals AS (
    SELECT
        year,
        company_name,
        SUM(client_revenue) AS total_company_revenue
    FROM CompanyClientYearly
    GROUP BY year, company_name
),
RankedClients AS (
    SELECT
        ccy.year,
        ccy.company_name,
        ccy.client_name,
        ccy.client_revenue,
        cyt.total_company_revenue,
        ccy.client_revenue * 100.0 / cyt.total_company_revenue AS share_pct,
        ROW_NUMBER() OVER (
            PARTITION BY ccy.year, ccy.company_name
            ORDER BY ccy.client_revenue DESC
        ) AS rn
    FROM CompanyClientYearly ccy
    JOIN CompanyYearTotals cyt
        ON ccy.year = cyt.year
        AND ccy.company_name = cyt.company_name
)
SELECT
    company_name,
    CAST(AVG(share_pct) AS DECIMAL(5,2)) AS avg_top_customer_concentration_pct,
    COUNT(*) AS years_analyzed
FROM RankedClients
WHERE rn = 1   -- top customer per company per year
GROUP BY company_name
ORDER BY avg_top_customer_concentration_pct DESC;
