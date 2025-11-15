USE MEP_Projects_Analytics;
GO

SELECT 
    company_name,
    COUNT(*) AS project_count
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY company_name
WITH ROLLUP
ORDER BY 
    CASE WHEN company_name IS NULL THEN 1 ELSE 0 END,  -- Puts total at bottom
    company_name ASC;

SELECT *
INTO dbo.emcor_like_projects_noisy_extended_backup
FROM dbo.emcor_like_projects_noisy_extended;

ALTER TABLE dbo.emcor_like_projects_noisy_extended
ADD company_name_original NVARCHAR(255);

INSERT INTO dbo.company_name_mapping (raw_name, standardized_name)
VALUES
-- ABM
('ABM Tech Solns', 'ABM Technical Solutions'),
('ABM technical solutions', 'ABM Technical Solutions'),
('ABM Technical Solutions, LLC', 'ABM Technical Solutions'),
('ABM TECHNICAL SOLUTIONS.', 'ABM Technical Solutions'),

-- AECOM
('AECOM BLDG SRVCS', 'AECOM Building Services'),
('AECOM Bldg Svs', 'AECOM Building Services'),
('Aecom building services', 'AECOM Building Services'),
('AECOM Building Services.', 'AECOM Building Services'),

-- Atlantic Facility Works
('Atlantic Facility Works', 'Atlantic Facility Works'),
('Atlantic Facility Works, Inc.', 'Atlantic Facility Works'),
('ATLANTIC FACILITY WORKS.', 'Atlantic Facility Works'),
('Atlantic Facility Wrks', 'Atlantic Facility Works'),

-- Coastal Energy Systems
('Coastal Energy Sys', 'Coastal Energy Systems'),
('Coastal energy systems', 'Coastal Energy Systems'),
('Coastal Energy Systems, Ltd.', 'Coastal Energy Systems'),
('COASTAL ENERGY SYSTEMS.', 'Coastal Energy Systems'),

-- Comfort Systems USA
('Comfort Sys USA', 'Comfort Systems USA'),
('COMFORT SYSTEMS U.S.A.', 'Comfort Systems USA'),
('Comfort Systems USA', 'Comfort Systems USA'),
('Comfort Systems USA, Inc.', 'Comfort Systems USA'),

-- EMCOR Group
('EMCOR Group', 'EMCOR Group'),
('EMCOR GROUP.', 'EMCOR Group'),
('Emcor Grp', 'EMCOR Group'),

-- Fluor Services
('Fluor services', 'Fluor Services'),
('FLUOR SERVICES.', 'Fluor Services'),
('Fluor Srvs', 'Fluor Services'),
('Fluor-Services', 'Fluor Services'),

-- Heartland Building Services
('Heartland Bldg Services', 'Heartland Building Services'),
('Heartland building services', 'Heartland Building Services'),
('HEARTLAND BUILDING SERVICES.', 'Heartland Building Services'),
('Heartland Building Svcs', 'Heartland Building Services'),

-- I.E.S. Holdings
('I.E.S. Holdings', 'IES Holdings'),
('IES Hldgs', 'IES Holdings'),
('IES holdings', 'IES Holdings'),
('IES HOLDINGS.', 'IES Holdings'),

-- Jacobs Mission Critical
('JACOBS mission critical', 'Jacobs Mission Critical'),
('Jacobs Mission Critical.', 'Jacobs Mission Critical'),
('Jacobs Mission-Critical', 'Jacobs Mission Critical'),

-- Mastec
('Mastec', 'Mastec'),
('MAS-TEC', 'Mastec'),
('MasTec.', 'Mastec'),

-- Midwest Industrial Services
('Midwest Ind. Services', 'Midwest Industrial Services'),
('Midwest Industrial Services', 'Midwest Industrial Services'),
('Midwest Industrial Services.', 'Midwest Industrial Services'),
('MIDWEST INDUSTRIAL SVCS', 'Midwest Industrial Services'),

-- Mountain View FM
('MOUNTAIN VIEW F.M.', 'Mountain View FM'),
('Mountain View Facilities Mgmt', 'Mountain View FM'),
('Mountain view fm', 'Mountain View FM'),
('Mt View FM', 'Mountain View FM'),

-- Northeast Plant Services
('N.E. Plant Services', 'Northeast Plant Services'),
('Northeast Plant Services', 'Northeast Plant Services'),
('NORTHEAST PLANT SERVICES.', 'Northeast Plant Services'),
('Northeast Plant Svcs', 'Northeast Plant Services'),

-- Pacific Tech Contractors
('Pacific Tech Contractors', 'Pacific Tech Contractors'),
('PACIFIC TECH CONTRACTORS.', 'Pacific Tech Contractors'),
('Pacific Tech Contrs', 'Pacific Tech Contractors'),
('Pacific-Tech Contractors', 'Pacific Tech Contractors'),

-- Precision Electrical Contractors
('Precision Elec. Contractors', 'Precision Electrical Contractors'),
('Precision Electrical Contractors', 'Precision Electrical Contractors'),
('PRECISION ELECTRICAL CONTRACTORS.', 'Precision Electrical Contractors'),
('Precision Electrical Contrs', 'Precision Electrical Contractors'),

-- Quanta Services
('Quanta Services', 'Quanta Services'),
('Quanta Services, Inc.', 'Quanta Services'),
('QUANTA SERVICES.', 'Quanta Services'),
('Quanta Svcs', 'Quanta Services'),

-- Regional MEP Solutions
('REGIONAL M.E.P. SOLUTIONS', 'Regional MEP Solutions'),
('Regional MEP Solns', 'Regional MEP Solutions'),
('Regional MEP Solutions', 'Regional MEP Solutions'),
('Regional MEP Solutions.', 'Regional MEP Solutions'),

-- Southwest Mechanical
('Southwest Mech.', 'Southwest Mechanical'),
('Southwest mechanical', 'Southwest Mechanical'),
('Southwest Mechanical LLC', 'Southwest Mechanical'),
('SOUTHWEST MECHANICAL.', 'Southwest Mechanical'),

-- TD Industries
('TD Industries', 'TD Industries'),
('TDIndustries', 'TD Industries'),
('TD-Industries', 'TD Industries'),
('TDINDUSTRIES.', 'TD Industries');

UPDATE p
SET p.company_name = m.standardized_name
FROM dbo.emcor_like_projects_noisy_extended p
INNER JOIN dbo.company_name_mapping m
    ON p.company_name = m.raw_name;

SELECT company_name, COUNT(*) AS project_count
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY company_name
ORDER BY company_name;

SELECT 'company_name' AS column_name, company_name AS value, COUNT(*) AS project_count
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY company_name

UNION ALL

SELECT 'client_name', client_name, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY client_name

UNION ALL

SELECT 'client_industry', client_industry, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY client_industry

UNION ALL

SELECT 'sector', sector, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY sector

UNION ALL

SELECT 'subsector', subsector, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY subsector

UNION ALL

SELECT 'project_type', project_type, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY project_type

UNION ALL

SELECT 'delivery_method', delivery_method, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY delivery_method

UNION ALL

SELECT 'project_status', project_status, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY project_status

UNION ALL

SELECT 'country', country, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY country

UNION ALL

SELECT 'state', state, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY state

UNION ALL

SELECT 'city', city, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY city

UNION ALL

SELECT 'location_region', location_region, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY location_region

UNION ALL

SELECT 'joint_venture_flag', CAST(joint_venture_flag AS NVARCHAR(10)), COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY joint_venture_flag

UPDATE dbo.emcor_like_projects_noisy_extended
SET client_name = CASE 
    -- Amazon Web Services
    WHEN client_name IN ('Amazon Web Services', 'Amazon Web Services.') THEN 'Amazon Web Services'
    
    -- City of Chicago Water
    WHEN client_name IN (
        'Chicago - Water', 
        'Chicago city water dept.', 
        'City of Chicago - Water', 
        'City of CHICAGO / Water', 
        'City of Chicago Water'
    ) THEN 'City of Chicago Water'
    
    -- Commercial REIT Client
    WHEN client_name IN ('Commercial REIT Client', 'Commercial REIT Client.') THEN 'Commercial REIT Client'
    
    -- Dominion Energy
    WHEN client_name IN ('Dominion Energy', 'Dominion Energy.') THEN 'Dominion Energy'
    
    -- Duke Energy
    WHEN client_name IN ('Duke Energy', 'Duke Energy.') THEN 'Duke Energy'
    
    -- Kaiser Permanente
    WHEN client_name IN ('Kaiser Permanente', 'Kaiser Permanente.') THEN 'Kaiser Permanente'
    
    -- Local University
    WHEN client_name IN ('Local Univ.', 'LOCAL UNIVERSITY', 'Univ. (local)') THEN 'Local University'
    
    -- Meta Platforms
    WHEN client_name IN ('Meta Platforms', 'Meta Platforms.') THEN 'Meta Platforms'
    
    -- Microsoft Data Center
    WHEN client_name = 'Microsoft Data Center' THEN 'Microsoft Data Center'
    
    -- Midwest Manufacturing Co.
    WHEN client_name = 'MIDWEST MANUFACTURING CO.' THEN 'Midwest Manufacturing Co.'
    
    -- Municipal Client - Small
    WHEN client_name = 'Municipal Client - Small' THEN 'Municipal Client - Small'
    
    -- NYC Health + Hospitals
    WHEN client_name IN ('NYC Health + Hospitals', 'NYC Health + Hospitals.') THEN 'NYC Health + Hospitals'
    
    -- Regional School District
    WHEN client_name IN ('Regional School District', 'Regional School District.') THEN 'Regional School District'
    
    -- Small Municipal Client
    WHEN client_name IN ('Small muni client', 'Small municipal authority', 'Small Municipal Client') THEN 'Small Municipal Client'
    
    -- Texas Department of Transportation
    WHEN client_name IN (
        'State of Texas - DOT', 
        'State of Texas DOT', 
        'Texas - Department of Transportation', 
        'Texas DOT', 
        'TX Dept. of Transportation'
    ) THEN 'Texas Department of Transportation'
    
    -- U.S. General Services Administration
    WHEN client_name IN (
        'U.S. G.S.A.', 
        'U.S. General Services Administration', 
        'US General Services Administration', 
        'US GSA'
    ) THEN 'U.S. General Services Administration'
    
    -- Default: keep original
    ELSE client_name
END;

UPDATE dbo.emcor_like_projects_noisy_extended
SET client_name = CASE 
    -- Microsoft Data Center
    WHEN client_name IN ('Microsoft Data Center','Microsoft Data Center.') THEN 'Microsoft Data Center'
    ELSE client_name
END;


SELECT 'client_name', client_name, COUNT(*)
FROM dbo.emcor_like_projects_noisy_extended
GROUP BY client_name

UPDATE dbo.emcor_like_projects_noisy_extended
SET
    contract_value_total = CASE WHEN currency = 'CAD' THEN contract_value_total * 1.4 ELSE contract_value_total END,
    recognized_revenue_year = CASE WHEN currency = 'CAD' THEN recognized_revenue_year * 1.4 ELSE recognized_revenue_year END,
    backlog_begin = CASE WHEN currency = 'CAD' THEN backlog_begin * 1.4 ELSE backlog_begin END,
    backlog_end = CASE WHEN currency = 'CAD' THEN backlog_end * 1.4 ELSE backlog_end END,
    total_cost = CASE WHEN currency = 'CAD' THEN total_cost * 1.4 ELSE total_cost END,
    labor_cost_total = CASE WHEN currency = 'CAD' THEN labor_cost_total * 1.4 ELSE labor_cost_total END,
    material_cost_total = CASE WHEN currency = 'CAD' THEN material_cost_total * 1.4 ELSE material_cost_total END,
    equipment_cost_total = CASE WHEN currency = 'CAD' THEN equipment_cost_total * 1.4 ELSE equipment_cost_total END,
    subcontractor_cost_total = CASE WHEN currency = 'CAD' THEN subcontractor_cost_total * 1.4 ELSE subcontractor_cost_total END,
    overhead_cost_total = CASE WHEN currency = 'CAD' THEN overhead_cost_total * 1.4 ELSE overhead_cost_total END,
    sgna_cost = CASE WHEN currency = 'CAD' THEN sgna_cost * 1.4 ELSE sgna_cost END,
    contingency_cost = CASE WHEN currency = 'CAD' THEN contingency_cost * 1.4 ELSE contingency_cost END,
    avg_hourly_rate_field = CASE WHEN currency = 'CAD' THEN avg_hourly_rate_field * 1.4 ELSE avg_hourly_rate_field END,
    avg_hourly_rate_office = CASE WHEN currency = 'CAD' THEN avg_hourly_rate_office * 1.4 ELSE avg_hourly_rate_office END,
    gross_margin = CASE WHEN currency = 'CAD' THEN gross_margin * 1.4 ELSE gross_margin END,
    ebitda = CASE WHEN currency = 'CAD' THEN ebitda * 1.4 ELSE ebitda END,
    operating_income = CASE WHEN currency = 'CAD' THEN operating_income * 1.4 ELSE operating_income END
WHERE currency = 'CAD';
