-- ============================================================
-- Bellabeat Case Study - BigQuery SQL Queries
-- Google Data Analytics Certificate Capstone
-- Author: Peter Christopher Chester | November 2025
-- ============================================================


-- ── DATASET: dailyActivity ───────────────────────────────────

-- Remove duplicates
CREATE TABLE dailyActivity_clean AS
SELECT DISTINCT *
FROM dailyActivity;

-- Check for blank or null TotalSteps
SELECT *
FROM dailyActivity
WHERE TotalSteps IS NULL;

-- Check distinct date formats
SELECT DISTINCT ActivityDate
FROM dailyActivity
ORDER BY 1;

-- Add parsed date column
ALTER TABLE dailyActivity
ADD COLUMN ActivityDate_parsed DATE;

-- Standardise date format
UPDATE dailyActivity
SET ActivityDate_parsed = PARSE_DATE('%m/%d/%Y', ActivityDate);

-- Replace old column with parsed version
ALTER TABLE dailyActivity_clean DROP COLUMN ActivityDate;

ALTER TABLE dailyActivity_clean
RENAME COLUMN ActivityDate_parsed TO ActivityDate;


-- ── DATASET: heartrate_second ─────────────────────────────────

-- Remove duplicates
CREATE TABLE heartrate_second_clean AS
SELECT DISTINCT *
FROM heartrate_second;

-- Check for blank or null values
SELECT *
FROM heartrate_second
WHERE Value IS NULL;

-- Preview raw timestamp format
SELECT Time
FROM heartrate_second
LIMIT 100;

-- Add parsed timestamp column
ALTER TABLE heartrate_second
ADD COLUMN Time_parsed TIMESTAMP;

-- Standardise timestamp format
UPDATE heartrate_second
SET Time_parsed = PARSE_TIMESTAMP('%m/%d/%Y %H:%M:%S', Time);

-- Replace old column with parsed version
ALTER TABLE heartrate_second DROP COLUMN Time;
ALTER TABLE heartrate_second RENAME COLUMN Time_parsed TO Time;


-- ── DATASET: sleepDay ────────────────────────────────────────

-- Check total vs unique records
SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT Id, SleepDay) AS unique_records
FROM sleepDay;

-- Check for null sleep values
SELECT *
FROM sleepDay
WHERE TotalMinutesAsleep IS NULL;

-- Parse and extract date from sleepDay timestamp
SELECT
    Id,
    PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', SleepDay) AS SleepDayTS,
    EXTRACT(DATE FROM PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', SleepDay)) AS SleepDay,
    TotalMinutesAsleep,
    TotalTimeInBed
FROM sleepDay;


-- ── HEART RATE AGGREGATION (BigQuery) ────────────────────────
-- Aggregates second-by-second heart rate data to hourly averages
-- Output: hourly_heartrate_aggregated.csv

SELECT
  t1.Id,

  -- Truncate safe-cast timestamp to the start of the hour
  DATETIME_TRUNC(
      DATETIME(SAFE_CAST(t1.Time AS TIMESTAMP)),
      HOUR
  ) AS Hour_Timestamp,

  -- Calculate average heart rate for that hour
  AVG(t1.Value) AS Avg_Hourly_HeartRate,

  -- Count readings for quality check
  COUNT(t1.Value) AS Readings_Count

FROM
  `fitbit-data-project-112025.fitbit_raw_data.heartrate_seconds` AS t1

GROUP BY
  t1.Id,
  Hour_Timestamp

HAVING
  Hour_Timestamp IS NOT NULL

ORDER BY
  t1.Id,
  Hour_Timestamp;
