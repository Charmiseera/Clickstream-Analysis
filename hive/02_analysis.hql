-- Phase 4 - Analysis queries (terminal / Hive View version)
-- Run:  hive -f hive/02_analysis.hql
-- The same queries, without the trailing semicolons, are in
-- zeppelin/Clickstream_Analysis.md for charting.
--
-- All six queries read the raw log table directly. The geo and URL
-- columns are cleaned inline (TRIM / LOWER / empty-value filter)
-- instead of through a separate staging table.

USE clickstream;

-- Figure 1. State-wise website traffic in USA
-- COUNT(col_8) counts hits that carry a visitor IP.
SELECT
    LOWER(TRIM(col_53)) AS state,
    COUNT(col_8) AS total_visits
FROM clickstream.omnitureweblogs
WHERE LOWER(TRIM(col_51)) = 'usa'
  AND col_53 IS NOT NULL
  AND TRIM(col_53) <> ''
GROUP BY LOWER(TRIM(col_53))
ORDER BY total_visits DESC
LIMIT 10;

-- Figure 2. City-wise website traffic in California
-- Drill-down from Figure 1 into the busiest state.
SELECT
    LOWER(TRIM(col_50)) AS city,
    COUNT(col_8) AS total_visits
FROM clickstream.omnitureweblogs
WHERE LOWER(TRIM(col_51)) = 'usa'
  AND UPPER(TRIM(col_53)) = 'CA'
  AND col_50 IS NOT NULL
  AND TRIM(col_50) <> ''
GROUP BY LOWER(TRIM(col_50))
ORDER BY total_visits DESC
LIMIT 10;

-- Figure 3. Country-wise website traffic
SELECT
    LOWER(TRIM(col_51)) AS country,
    COUNT(*) AS total_visits
FROM clickstream.omnitureweblogs
WHERE col_51 IS NOT NULL
  AND TRIM(col_51) <> ''
GROUP BY LOWER(TRIM(col_51))
ORDER BY total_visits DESC
LIMIT 10;

-- Figure 4. City-wise website traffic
SELECT
    LOWER(TRIM(col_50)) AS city,
    COUNT(*) AS total_visits
FROM clickstream.omnitureweblogs
WHERE col_50 IS NOT NULL
  AND TRIM(col_50) <> ''
GROUP BY LOWER(TRIM(col_50))
ORDER BY total_visits DESC
LIMIT 10;

-- Figure 5. Top 10 most visited webpages
SELECT
    col_13 AS webpage,
    COUNT(*) AS total_visits
FROM clickstream.omnitureweblogs
WHERE col_13 IS NOT NULL
  AND TRIM(col_13) <> ''
GROUP BY col_13
ORDER BY total_visits DESC
LIMIT 10;

-- Figure 6. Website activity by hour of day
-- col_2 looks like '2012-03-15 01:17:06'; characters 12-13 are the hour.
-- The RLIKE filter drops any row whose timestamp is malformed so the
-- CAST never produces NULL hours.
SELECT
    CAST(SUBSTR(col_2, 12, 2) AS INT) AS hour_of_day,
    COUNT(*) AS total_visits
FROM clickstream.omnitureweblogs
WHERE col_2 RLIKE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
GROUP BY CAST(SUBSTR(col_2, 12, 2) AS INT)
ORDER BY hour_of_day;
