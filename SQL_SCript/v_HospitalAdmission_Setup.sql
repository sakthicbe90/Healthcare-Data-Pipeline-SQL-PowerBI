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
