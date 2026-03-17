-- ================================================================
-- Peak Hours Demand Analysis
-- Objective: Identify highest demand days, time slots and stations
-- to optimize bike availability and restocking
-- Note: trips > 4 hours filtered out as data errors or unreturned bikes
-- ================================================================

-- Step 1: Trip distribution by day of week
-- Finding: Weekdays concentrate 87% of trips. Sunday is the lowest demand day (10%)
WITH max_date AS (
  SELECT MAX(DATE_TRUNC(starttime, YEAR)) AS max_year
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
)
SELECT 
    FORMAT_DATE('%A', DATE(starttime)) AS dow,
    COUNT(*) AS qty_trips,
    ROUND(100 * (COUNT(*) / (SELECT COUNT(*) 
                              FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
                              CROSS JOIN max_date
                              WHERE DATE_TRUNC(starttime, YEAR) = max_year
                              AND tripduration IS NOT NULL
                              AND tripduration <= 4 * 3600)),1) AS pct_qty
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
CROSS JOIN max_date
WHERE DATE_TRUNC(starttime, YEAR) = max_year
      AND tripduration IS NOT NULL
      AND tripduration <= 4 * 3600
GROUP BY dow
ORDER BY qty_trips DESC;

/*
| Day       | Trips   | % Total |
|-----------|---------|---------|
| Thursday  | 926,668 | 16.4%   |
| Tuesday   | 924,184 | 16.3%   |
| Wednesday | 887,369 | 15.7%   |
| Monday    | 838,580 | 14.8%   |
| Friday    | 816,963 | 14.4%   |
| Saturday  | 703,135 | 12.4%   |
| Sunday    | 568,041 | 10.0%   |
*/


-- Step 2: Trip distribution by time slot
-- Finding: 16-19hs and 7-10hs concentrate 47% of all trips — classic commuter pattern
WITH max_date AS (
  SELECT MAX(DATE_TRUNC(starttime, YEAR)) AS max_year
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
),
trips_per_time_slots AS (
  SELECT
      COUNT(*) AS trips,
      CASE WHEN EXTRACT(HOUR FROM starttime) BETWEEN 7 AND 9 THEN '7-10'
           WHEN EXTRACT(HOUR FROM starttime) BETWEEN 10 AND 12 THEN '10-13'
           WHEN EXTRACT(HOUR FROM starttime) BETWEEN 13 AND 15 THEN '13-16'
           WHEN EXTRACT(HOUR FROM starttime) BETWEEN 16 AND 18 THEN '16-19'
           WHEN EXTRACT(HOUR FROM starttime) BETWEEN 19 AND 21 THEN '19-22'
      ELSE 'Other slot'
      END AS time_slots
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
  WHERE tripduration IS NOT NULL 
        AND tripduration <= 4 * 3600
        AND DATE_TRUNC(starttime, YEAR) = (SELECT max_year FROM max_date)
  GROUP BY time_slots
)
SELECT 
    time_slots,
    trips,
    ROUND(100*(trips/SUM(trips) OVER()),0) AS pct_trips
FROM trips_per_time_slots
ORDER BY trips DESC;

/*
| Time Slot  | Trips     | % Total |
|------------|-----------|---------|
| 16-19      | 1,511,596 | 27%     |
| 7-10       | 1,115,791 | 20%     |
| 13-16      | 997,157   | 18%     |
| 10-13      | 818,418   | 14%     |
| 19-22      | 763,496   | 13%     |
| Other slot | 458,482   | 8%      |
*/


-- Step 3: Top 10 departure stations during 16-19hs peak
-- Finding: Pershing Square North leads with 1.4% of all afternoon peak trips
WITH max_date AS (
  SELECT MAX(DATE_TRUNC(starttime, YEAR)) AS max_year
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
)
SELECT 
    start_station_name,
    COUNT(*) AS trips,
    ROUND(100 * SAFE_DIVIDE(CAST(COUNT(*) AS FLOAT64), SUM(COUNT(*)) OVER()), 1) AS pct_trips
FROM `bigquery-public-data.new_york_citibike.citibike_trips`  
WHERE EXTRACT(HOUR FROM starttime) BETWEEN 16 AND 18
      AND tripduration IS NOT NULL
      AND tripduration <= 4 * 3600
      AND DATE_TRUNC(starttime, YEAR) = (SELECT max_year FROM max_date)
GROUP BY start_station_name
ORDER BY trips DESC
LIMIT 10;

/*
| Station                          | Trips  | % Slot |
|----------------------------------|--------|--------|
| Pershing Square North            | 21,398 | 1.4%   |
| Broadway & E 22 St               | 15,286 | 1.0%   |
| E 47 St & Park Ave               | 13,860 | 0.9%   |
| E 17 St & Broadway               | 11,601 | 0.8%   |
| W 21 St & 6 Ave                  | 11,453 | 0.8%   |
| W 52 St & 6 Ave                  | 11,323 | 0.7%   |
| Grand Army Plaza & Central Par.. | 9,620  | 0.6%   |
| Broadway & W 25 St               | 9,237  | 0.6%   |
| West St & Chambers St            | 9,204  | 0.6%   |
| W 41 St & 8 Ave                  | 8,771  | 0.6%   |
*/


-- Step 4: Top 10 departure stations during 7-10hs peak
-- Finding: Pershing Square North also leads morning peak — consistent high-demand station
WITH max_date AS (
  SELECT MAX(DATE_TRUNC(starttime, YEAR)) AS max_year
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
)
SELECT 
    start_station_name,
    COUNT(*) AS trips,
    ROUND(100 * SAFE_DIVIDE(CAST(COUNT(*) AS FLOAT64), SUM(COUNT(*)) OVER()), 1) AS pct_trips
FROM `bigquery-public-data.new_york_citibike.citibike_trips`  
WHERE EXTRACT(HOUR FROM starttime) BETWEEN 7 AND 9
      AND tripduration IS NOT NULL
      AND tripduration <= 4 * 3600
      AND DATE_TRUNC(starttime, YEAR) = (SELECT max_year FROM max_date)
GROUP BY start_station_name
ORDER BY trips DESC
LIMIT 10;

/*
| Station                       | Trips  | % Slot |
|-------------------------------|--------|--------|
| Pershing Square North         | 14,736 | 1.3%   |
| 8 Ave & W 31 St               | 9,298  | 0.8%   |
| Broadway & W 41 St            | 6,451  | 0.6%   |
| Pershing Square South         | 6,437  | 0.6%   |
| E 7 St & Avenue A             | 6,371  | 0.6%   |
| Christopher St & Greenwich St | 6,352  | 0.6%   |
| Columbus Ave & W 72 St        | 6,346  | 0.6%   |
| 8 Ave & W 33 St               | 6,030  | 0.5%   |
| E 13 St & Avenue A            | 5,914  | 0.5%   |
| W 31 St & 7 Ave               | 5,899  | 0.5%   |
*/
