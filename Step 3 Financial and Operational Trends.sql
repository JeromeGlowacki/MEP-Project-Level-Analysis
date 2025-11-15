USE MEP_Projects_Analytics; 

GO

/* Compare backlog vs recognized revenue annually */

WITH BacklogRevenue AS (
    SELECT
        year,
        SUM(backlog_begin) AS backlog_begin_usd,
        SUM(backlog_end) AS backlog_end_usd,
        SUM(recognized_revenue_year) AS recognized_revenue_usd
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY year
)
SELECT
    year,
    FORMAT(backlog_begin_usd, 'C', 'en-US') AS backlog_begin_usd,
    FORMAT(backlog_end_usd, 'C', 'en-US') AS backlog_end_usd,
    FORMAT(recognized_revenue_usd, 'C', 'en-US') AS recognized_revenue_usd
FROM BacklogRevenue
ORDER BY year DESC;

/* Backlog Growth by Year */

SELECT
    year,
    FORMAT(SUM(backlog_begin), 'C', 'en-US') AS backlog_begin_usd,
    FORMAT(SUM(backlog_end), 'C', 'en-US') AS backlog_end_usd,
    FORMAT(SUM(backlog_end) - SUM(backlog_begin), 'C', 'en-US') AS backlog_growth_usd,
    CAST((SUM(backlog_end) - SUM(backlog_begin)) * 100.0 / NULLIF(SUM(backlog_begin), 0) AS DECIMAL(5,2)) AS backlog_growth_pct
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY year
ORDER BY year DESC;


/* Analyze cost breakdown by company */

SELECT
    company_name,
    FORMAT(SUM(labor_cost_total), 'C', 'en-US') AS labor_cost_usd,
    FORMAT(SUM(material_cost_total), 'C', 'en-US') AS material_cost_usd,
    FORMAT(SUM(equipment_cost_total), 'C', 'en-US') AS equipment_cost_usd,
    FORMAT(SUM(subcontractor_cost_total), 'C', 'en-US') AS subcontractor_cost_usd,
    FORMAT(SUM(overhead_cost_total), 'C', 'en-US') AS overhead_cost_usd,
    FORMAT(SUM(sgna_cost), 'C', 'en-US') AS sgna_cost_usd,
    FORMAT(SUM(contingency_cost), 'C', 'en-US') AS contingency_cost_usd
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY company_name
ORDER BY SUM(labor_cost_total + material_cost_total + equipment_cost_total + subcontractor_cost_total) DESC;

/* Cost Structure as % of Total Costs by Company with Average */

WITH CompanyCosts AS (
    SELECT
        company_name,
        SUM(labor_cost_total) AS labor_cost,
        SUM(material_cost_total) AS material_cost,
        SUM(equipment_cost_total) AS equipment_cost,
        SUM(subcontractor_cost_total) AS subcontractor_cost,
        SUM(overhead_cost_total) AS overhead_cost,
        SUM(sgna_cost) AS sgna_cost,
        SUM(contingency_cost) AS contingency_cost,
        SUM(labor_cost_total + material_cost_total + equipment_cost_total +
            subcontractor_cost_total + overhead_cost_total + sgna_cost + contingency_cost) AS total_costs
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY company_name
)
SELECT
    CASE WHEN company_name IS NULL THEN 'AVERAGE' ELSE company_name END AS company_name,
    CAST(SUM(labor_cost) * 100.0 / SUM(total_costs) AS DECIMAL(5,2)) AS labor_pct,
    CAST(SUM(material_cost) * 100.0 / SUM(total_costs) AS DECIMAL(5,2)) AS material_pct,
    CAST(SUM(equipment_cost) * 100.0 / SUM(total_costs) AS DECIMAL(5,2)) AS equipment_pct,
    CAST(SUM(subcontractor_cost) * 100.0 / SUM(total_costs) AS DECIMAL(5,2)) AS subcontractor_pct,
    CAST(SUM(overhead_cost) * 100.0 / SUM(total_costs) AS DECIMAL(5,2)) AS overhead_pct,
    CAST(SUM(sgna_cost) * 100.0 / SUM(total_costs) AS DECIMAL(5,2)) AS sgna_pct,
    CAST(SUM(contingency_cost) * 100.0 / SUM(total_costs) AS DECIMAL(5,2)) AS contingency_pct,
    SUM(total_costs) AS total_costs  -- include for ordering
FROM CompanyCosts
GROUP BY company_name WITH ROLLUP
ORDER BY 
    CASE WHEN company_name IS NULL THEN 1 ELSE 0 END, 
    SUM(total_costs) DESC; 



/* Evaluate profitability trends by project type */

SELECT
    project_type,
    FORMAT(SUM(contract_value_total) - SUM(total_cost), 'C', 'en-US') AS gross_margin_usd,
    CAST(AVG(gross_margin_pct) AS DECIMAL(5,2)) AS avg_gross_margin_pct,
    CAST(AVG(ebitda_margin_pct) AS DECIMAL(5,2)) AS avg_ebitda_margin_pct,
    CAST(AVG(operating_margin_pct) AS DECIMAL(5,2)) AS avg_operating_margin_pct
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY project_type
ORDER BY SUM(contract_value_total) DESC;

/* Track revenue and operational performance over time */

SELECT
    year,
    FORMAT(SUM(contract_value_total), 'C', 'en-US') AS total_revenue_usd,
    FORMAT(SUM(contract_value_total) - SUM(total_cost), 'C', 'en-US') AS gross_margin_usd,
    CAST(AVG(gross_margin_pct) AS DECIMAL(5,2)) AS avg_gross_margin_pct,
    CAST(AVG(ebitda_margin_pct) AS DECIMAL(5,2)) AS avg_ebitda_margin_pct,
    CAST(AVG(operating_margin_pct) AS DECIMAL(5,2)) AS avg_operating_margin_pct
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY year
ORDER BY year DESC;

/* Headcount & Productivity Analysis by Company */

WITH CompanyLabor AS (
    SELECT
        company_name,
        SUM(headcount_total) AS total_headcount,
        SUM(headcount_field) AS field_headcount,
        SUM(headcount_office) AS office_headcount,
        AVG(avg_hourly_rate_field) AS avg_rate_field,
        AVG(avg_hourly_rate_office) AS avg_rate_office,
        SUM(labor_hours_total) AS total_labor_hours,
        SUM(contract_value_total) AS total_revenue,
        SUM(ebitda) AS total_ebitda
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY company_name
)
SELECT
    company_name,
    total_headcount,
    field_headcount,
    office_headcount,
    FORMAT(avg_rate_field, 'C', 'en-US') AS avg_rate_field_usd,
    FORMAT(avg_rate_office, 'C', 'en-US') AS avg_rate_office_usd,
    total_labor_hours,
    FORMAT(total_revenue, 'C', 'en-US') AS total_revenue_usd,
    FORMAT(total_revenue * 1.0 / NULLIF(total_headcount,0), 'C', 'en-US') AS revenue_per_headcount_usd,
    FORMAT(total_revenue * 1.0 / NULLIF(total_labor_hours,0), 'C', 'en-US') AS revenue_per_labor_hour_usd,
    FORMAT(total_ebitda, 'C', 'en-US') AS total_ebitda_usd,
    CAST(total_ebitda * 100.0 / NULLIF(total_revenue,0) AS DECIMAL(5,2)) AS ebitda_margin_pct,
    FORMAT(total_ebitda * 1.0 / NULLIF(total_headcount,0), 'C', 'en-US') AS ebitda_per_headcount_usd,
    CAST((total_ebitda * 1.0 / NULLIF(total_headcount,0)) * 100.0 / NULLIF(total_revenue * 1.0 / NULLIF(total_headcount,0),0) AS DECIMAL(5,2)) AS ebitda_margin_per_headcount_pct
FROM CompanyLabor
ORDER BY total_revenue * 1.0 / NULLIF(total_labor_hours,0) DESC;

/* Time Analysis: Contract Value & Duration by Quarter */

WITH QuarterAnalysis AS (
    SELECT
        year,
        quarter,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count,
        AVG(duration_months) AS avg_duration_months
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY year, quarter
)
SELECT
    year,
    quarter,
    FORMAT(total_revenue, 'C', 'en-US') AS total_revenue_usd,
    project_count,
    CAST(avg_duration_months AS DECIMAL(5,2)) AS avg_duration_months
FROM QuarterAnalysis
ORDER BY year DESC, quarter ASC;

/* Time Analysis: 10-Year Average by Quarter */

WITH QuarterAverages AS (
    SELECT
        quarter,
        AVG(contract_value_total) AS avg_revenue,
        AVG(duration_months) AS avg_duration_months,
        AVG(project_count) AS avg_project_count
    FROM (
        SELECT 
            year,
            quarter,
            SUM(contract_value_total) AS contract_value_total,
            COUNT(*) AS project_count,
            AVG(duration_months) AS duration_months
        FROM dbo.emcor_like_projects_noisy_extended
        GROUP BY year, quarter
    ) AS yearly_quarters
    GROUP BY quarter
)
SELECT
    quarter,
    FORMAT(avg_revenue, 'C', 'en-US') AS avg_revenue_usd,
    CAST(avg_project_count AS DECIMAL(5,2)) AS avg_project_count,
    CAST(avg_duration_months AS DECIMAL(5,2)) AS avg_duration_months
FROM QuarterAverages
ORDER BY quarter ASC;

/* Time Analysis: Annual Trends Over 10 Years */

WITH AnnualAnalysis AS (
    SELECT
        year,
        SUM(contract_value_total) AS total_revenue,
        COUNT(*) AS project_count,
        AVG(duration_months) AS avg_duration_months
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY year
)
SELECT
    year,
    FORMAT(total_revenue, 'C', 'en-US') AS total_revenue_usd,
    project_count,
    CAST(avg_duration_months AS DECIMAL(5,2)) AS avg_duration_months,
    FORMAT(total_revenue * 1.0 / project_count, 'C', 'en-US') AS revenue_per_project_usd
FROM AnnualAnalysis
ORDER BY year ASC;

/* Competition Analysis: Average Competitors and Margins by Company */

WITH CompetitionMetrics AS (
    SELECT
        company_name,
        AVG(num_competitors_bid) AS avg_competitors,
        AVG(gross_margin_pct) AS avg_gross_margin,
        AVG(ebitda_margin_pct) AS avg_ebitda_margin,
        COUNT(*) AS project_count
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY company_name
)
SELECT
    company_name,
    project_count,
    CAST(avg_competitors AS DECIMAL(4,2)) AS avg_competitors,
    CAST(avg_gross_margin AS DECIMAL(5,2)) AS avg_gross_margin_pct,
    CAST(avg_ebitda_margin AS DECIMAL(5,2)) AS avg_ebitda_margin_pct
FROM CompetitionMetrics
ORDER BY avg_competitors DESC, avg_ebitda_margin_pct DESC;

/* Joint Venture Analysis: Participation and Share */

WITH JVMetrics AS (
    SELECT
        company_name,
        COUNT(*) AS total_projects,
        SUM(CASE WHEN joint_venture_flag = 1 THEN 1 ELSE 0 END) AS jv_projects,
        AVG(CASE WHEN joint_venture_flag = 1 THEN company_share_in_jv_pct ELSE NULL END) AS avg_jv_share_pct
    FROM dbo.emcor_like_projects_noisy_extended
    GROUP BY company_name
)
SELECT
    company_name,
    total_projects,
    jv_projects,
    CAST(jv_projects * 100.0 / total_projects AS DECIMAL(5,2)) AS jv_project_share_pct,
    CAST(avg_jv_share_pct AS DECIMAL(5,2)) AS avg_jv_share_pct
FROM JVMetrics
ORDER BY jv_projects DESC, avg_jv_share_pct DESC;
