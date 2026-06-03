USE HealthDB;
GO

/*
╔══════════════════════════════════════════════════════════════╗
║  VIEW: vw_AdmissionData                                      ║
║  PURPOSE: Creates a deduplicated, clean version of raw       ║
║           admission data for reliable reporting              ║
║  DEDUP KEY: MRD_NO + Admission Date + Discharge Date         ║
╚══════════════════════════════════════════════════════════════╝
*/
CREATE OR ALTER VIEW vw_AdmissionData AS
WITH RankedAdmissions AS (
    SELECT 
        *,
        /*
        ┌─────────────────────────────────────────────────────┐
        │ ROW_NUMBER assigns 1 to the first occurrence of     │
        │ each unique patient visit (same MRD + same dates).  │
        │ All duplicates get numbers 2, 3, etc. and are       │
        │ filtered out in the final SELECT below.             │
        └─────────────────────────────────────────────────────┘
        */
        ROW_NUMBER() OVER (
            PARTITION BY MRD_NO,    -- Patient Medical Record Number
                         D_O_A,     -- Date of Admission
                         D_O_D      -- Date of Discharge
            ORDER BY MRD_NO
        ) AS Dup_NO

    FROM [HDHI Admission data]

    WHERE MRD_NO IS NOT NULL        -- Exclude records with no patient ID
)
SELECT *
FROM RankedAdmissions
WHERE Dup_NO = 1;                   -- Keep ONLY the first record per visit
GO