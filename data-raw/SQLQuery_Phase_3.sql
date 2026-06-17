-- =========================================================================
-- PHASE 3: COLUMN ALTERS AND PRIMARY KEY CONSTRAINTS
-- DESCRIPTION: Enforces constraints on base columns to prepare for relational connections.
-- =========================================================================

-- -------------------------------------------------------------------------
-- 1. Configuration for [stg_Pollution]
-- -------------------------------------------------------------------------
-- Step A: Alter the target column to enforce NOT NULL integrity
ALTER TABLE dbo.stg_Pollution 
ALTER COLUMN [DATE] DATE NOT NULL;

-- Step B: Apply the Primary Key constraint
ALTER TABLE dbo.stg_Pollution 
ADD CONSTRAINT PK_Pollution PRIMARY KEY CLUSTERED ([DATE]);


-- -------------------------------------------------------------------------
-- 2. Configuration for [stg_Admissions]
-- -------------------------------------------------------------------------
-- Step A: Alter the target column to enforce NOT NULL integrity
ALTER TABLE dbo.stg_Admissions 
ALTER COLUMN [SNO] INT NOT NULL;

-- Step B: Apply the Primary Key constraint
ALTER TABLE dbo.stg_Admissions 
ADD CONSTRAINT PK_Admissions PRIMARY KEY CLUSTERED ([SNO]);


-- -------------------------------------------------------------------------
-- 3. Configuration for [stg_Mortality]
-- -------------------------------------------------------------------------

--Cleaning before alter checking for null

SELECT * 
FROM dbo.stg_Mortality 
WHERE [MRD] IS NULL OR [MRD] = '';

DELETE FROM dbo.stg_Mortality 
WHERE [MRD] IS NULL OR [MRD] = '';

--cleaning to remove duplicates

WITH CleanMortalityCTE AS (
    SELECT [MRD],
           ROW_NUMBER() OVER (PARTITION BY [MRD] ORDER BY [MRD]) AS RowNum
    FROM dbo.stg_Mortality
)
--Delete rows where the row number is greater than 1
DELETE FROM CleanMortalityCTE WHERE RowNum > 1;



-- Step A: Alter the target column to enforce NOT NULL integrity
ALTER TABLE dbo.stg_Mortality 
ALTER COLUMN [MRD] VARCHAR(50) NOT NULL;

-- Step B: Apply the Primary Key constraint
ALTER TABLE dbo.stg_Mortality 
ADD CONSTRAINT PK_Mortality PRIMARY KEY CLUSTERED ([MRD]);

-- =========================================================================
-- PHASE 3B: ENFORCING FOREIGN KEY CONSTRAINTS
-- DESCRIPTION: Links tables together to build the official relational schema.
-- =========================================================================

-- 1. Link Admissions to Pollution via the Date
--Clean the records from admission that dont have matching environmental pollution records.
SELECT DISTINCT a.D_O_A 
FROM dbo.stg_Admissions a
LEFT JOIN dbo.stg_Pollution p ON a.D_O_A = p.[DATE]
WHERE p.[DATE] IS NULL;

DELETE FROM dbo.stg_Admissions
WHERE D_O_A NOT IN (SELECT [DATE] FROM dbo.stg_Pollution);

-- This connects [stg_Admissions.Admission_Date] to [stg_Pollution.DATE]
ALTER TABLE dbo.stg_Admissions
ADD CONSTRAINT FK_Admissions_Pollution 
FOREIGN KEY (D_O_A) REFERENCES dbo.stg_Pollution([DATE]);

-- 2.Link Admissions to Mortality via the unique Patient ID (SNO)
ALTER TABLE dbo.stg_Mortality 
ALTER COLUMN [S_NO] INT NOT NULL;

--delete any records from the mortality table whose serial numbers cannot be found in the admissions table:
DELETE FROM dbo.stg_Mortality 
WHERE [S_NO] NOT IN (SELECT [SNO] FROM dbo.stg_Admissions);

ALTER TABLE dbo.stg_Mortality
ADD CONSTRAINT FK_Mortality_Admissions 
FOREIGN KEY ([S_NO]) REFERENCES dbo.stg_Admissions([SNO]);

--Phase 4 Building the Staging Reporting Layer (SQL View)
--Once the data constraints were fully locked into the base database tables, a specialized virtual staging layer (v_HospitalAdmission) was created to prepare the data for Power BI import.
--Simple Step-by-Step Breakdown of the View Code:

--Point the script to the right Database.
USE AutoCareDB;
GO

CREATE OR ALTER VIEW v_HospitalAdmission AS
-- The semicolon ensures SQL reads the CTE cleanly
WITH CleanData AS (
    SELECT *, 
        ROW_NUMBER() OVER(PARTITION BY MRD_No, D_O_A, D_O_D ORDER BY MRD_No) AS Dup_No
    FROM dbo.stg_Admissions
)
SELECT 
    -- Clean Admissions Data
    c.SNO,
    c.MRD_No,
    c.D_O_A AS Admission_Date,
    c.D_O_D AS Discharge_Date,
    c.Age,
    c.Gender,
    c.Outcome,
    
    -- Linked Pollution Data (Many-to-One)
    p.AQI,
    p.PM2_5_AVG,
    p.MAX_TEMP,
    p.HUMIDITY,
    
    -- Linked Mortality Data (One-to-One)
    CASE 
        WHEN m.S_NO IS NOT NULL THEN 'Deceased' 
        ELSE 'Survived' 
    END AS Mortality_Status,
    m.DATE_OF_BROUGHT_DEAD

FROM CleanData c
LEFT JOIN dbo.stg_Pollution p ON c.D_O_A = p.[DATE]
LEFT JOIN dbo.stg_Mortality m ON c.SNO = m.S_NO
WHERE c.Dup_No = 1 AND c.MRD_No IS NOT NULL;
GO