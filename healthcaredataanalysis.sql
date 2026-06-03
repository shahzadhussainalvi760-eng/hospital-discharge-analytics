/*
╔══════════════════════════════════════╗
║  METRIC: Total Discharged Patients   ║
║  FILTER: Outcome must = 'DISCHARGE'  ║
╚══════════════════════════════════════╝
*/
SELECT 
    COUNT(*) AS Total_Discharge      -- Counts every successfully discharged patient
FROM [dbo].[vw_AdmissionData]
WHERE OUTCOME = 'DISCHARGE';
/*
╔══════════════════════════════════════════════════════════════╗
║  METRIC: Average Daily Discharge Rate                        ║
║  METHOD: First count discharges per day, then average those  ║
║  WHY 2-STEP: Direct AVG would give wrong result              ║
╚══════════════════════════════════════════════════════════════╝
*/
SELECT 
    AVG(DailyDischarges) AS Avg_Daily_Discharge_Rate
FROM (
    -- STEP 1: Count how many patients were discharged each day
    SELECT 
        CAST(D_O_D AS DATE) AS DischargeDate,   -- Convert datetime to date only
        COUNT(*)            AS DailyDischarges   -- Count per day
    FROM [dbo].[vw_AdmissionData]
    WHERE D_O_D IS NOT NULL                      -- Exclude missing discharge dates
    GROUP BY CAST(D_O_D AS DATE)
) AS DailyStats;
-- STEP 2: Average across all days
/*
╔══════════════════════════════════════════════════════════════╗
║  METRIC: Average Length of Stay (LOS)                        ║
║  FILTERS: Only completed stays with valid, positive duration ║
╚══════════════════════════════════════════════════════════════╝
*/
SELECT 
    AVG(CAST(DURATION_OF_STAY AS FLOAT)) AS Avg_Length_of_Stay
FROM [HealthDB].[dbo].[vw_AdmissionData]
WHERE D_O_D IS NOT NULL              -- Must have a discharge date (stay completed)
  AND DURATION_OF_STAY IS NOT NULL   -- Duration must be recorded
  AND DURATION_OF_STAY >= 0;         -- Exclude data entry errors (negative days)
/*
╔══════════════════════════════════════════════════════════════╗
║  METRIC: Total Bed-Days Used Per Discharged Patient          ║
║  FORMULA: Total stay days ÷ Number of discharges             ║
║  NOTE: Includes ALL patients' stay days, not just discharged ║
╚══════════════════════════════════════════════════════════════╝
*/
SELECT 
    ROUND(
        SUM(DURATION_OF_STAY)   -- Total bed-days used by ALL patients
        /
        SUM(CASE 
                WHEN OUTCOME = 'DISCHARGE' THEN 1.0  -- Count only discharged patients
                ELSE 0 
            END),
    0) AS Bed_Days_Per_Discharge
FROM vw_AdmissionData;

/*
╔══════════════════════════════════════════════════════════════╗
║  ANALYSIS: Age Distribution of Discharged Patients           ║
║  GROUPS: 0-17 | 18-30 | 31-45 | 46-60 | 61-75 | 75+          ║
╚══════════════════════════════════════════════════════════════╝
*/
SELECT 
    AgeGroup,
    COUNT(*)    AS Discharged_Patients,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),  -- % of total discharges
    2) AS Percentage
FROM (
    -- STEP 1: Assign each patient to an age group
    SELECT 
        AGE,
        CASE 
            WHEN AGE < 18                  THEN '0-17'   -- Pediatric
            WHEN AGE BETWEEN 18 AND 30     THEN '18-30'  -- Young Adult
            WHEN AGE BETWEEN 31 AND 45     THEN '31-45'  -- Adult
            WHEN AGE BETWEEN 46 AND 60     THEN '46-60'  -- Middle Age
            WHEN AGE BETWEEN 61 AND 75     THEN '61-75'  -- Senior
            ELSE                                '75+'    -- Elderly
        END AS AgeGroup
    FROM [HealthDB].[dbo].[vw_AdmissionData]
    WHERE OUTCOME = 'DISCHARGE'
      AND AGE IS NOT NULL
) t
-- STEP 2: Group and summarize
GROUP BY AgeGroup
ORDER BY AgeGroup;

/*
╔══════════════════════════════════════════════════════════════╗
║  ANALYSIS: Gender Distribution of Discharged Patients        ║
║  NOTE: Raw codes (M/F) converted to readable labels          ║
╚══════════════════════════════════════════════════════════════╝
*/
WITH MappedPatients AS (
    -- STEP 1: Convert gender codes to readable labels
    SELECT 
        CASE GENDER 
            WHEN 'F' THEN 'Female' 
            WHEN 'M' THEN 'Male' 
            ELSE GENDER             -- Keep any unexpected values as-is
        END AS Gender,
        OUTCOME
    FROM [HealthDB].[dbo].[vw_AdmissionData]
    WHERE GENDER IS NOT NULL
)
-- STEP 2: Count and calculate percentages
SELECT 
    Gender,
    COUNT(*) AS Discharged_Patients,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER()  -- % share of total
    AS DECIMAL(5,2)) AS Percentage
FROM MappedPatients
WHERE OUTCOME = 'DISCHARGE'
GROUP BY Gender
ORDER BY Gender;
/*
╔══════════════════════════════════════════════════════════════╗
║  ANALYSIS: Which days of the week have the most discharges?  ║
║  USE CASE: Staffing, transport, and bed planning             ║
╚══════════════════════════════════════════════════════════════╝
*/
SELECT 
    DATENAME(WEEKDAY, D_O_D) AS Discharge_Day,   -- Convert date to day name
    COUNT(*)                 AS Total_Discharges,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),
    2) AS Percentage
FROM [HealthDB].[dbo].[vw_AdmissionData]
WHERE OUTCOME = 'DISCHARGE'
  AND D_O_D IS NOT NULL
GROUP BY DATENAME(WEEKDAY, D_O_D)
ORDER BY 
    -- Custom sort: Monday=1 through Sunday=7 (calendar order)
    CASE DATENAME(WEEKDAY, D_O_D)
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
    END;
/*
╔══════════════════════════════════════════════════════════════╗
║  FULL DATA EXTRACT: All deduplicated admission records       ║
║  ⚠️  WARNING: Use filters in production to limit row count   ║
╚══════════════════════════════════════════════════════════════╝
*/
SELECT * 
FROM [dbo].[vw_AdmissionData];

-- ✅ RECOMMENDED: Add filters for large datasets
-- WHERE D_O_A >= '2023-01-01'       -- Limit to recent records
--   AND OUTCOME = 'DISCHARGE'        -- Specific outcome only
-- ORDER BY D_O_D DESC;              -- Most recent first