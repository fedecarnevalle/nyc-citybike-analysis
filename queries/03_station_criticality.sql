-- ================================================================
-- Station Criticality Analysis | Peak Hour 16-19hs
-- Objective: Identify stations with highest supply-demand imbalance
-- during afternoon peak to prioritize restocking operations
-- Analysis period: most recent year in dataset (dynamic, no hardcoded dates)
-- Note: trips > 4 hours filtered out as data errors or unreturned bikes
-- ================================================================

WITH max_date AS (
  SELECT MAX(DATE_TRUNC(starttime, YEAR)) AS max_year
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
),
departures AS (
  SELECT
      start_station_name,
      DATE(starttime) AS day,
      COUNT(*) AS daily_departures
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
  WHERE tripduration IS NOT NULL 
        AND tripduration <= 4 * 3600
        AND DATE_TRUNC(starttime, YEAR) = (SELECT max_year FROM max_date)
        AND EXTRACT(HOUR FROM starttime) BETWEEN 16 AND 18
  GROUP BY start_station_name, day
),
arrivals AS (
  SELECT
      end_station_name,
      DATE(stoptime) AS day,
      COUNT(*) AS daily_arrivals
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
  WHERE tripduration IS NOT NULL 
        AND tripduration <= 4 * 3600
        AND DATE_TRUNC(stoptime, YEAR) = (SELECT max_year FROM max_date)
        AND EXTRACT(HOUR FROM stoptime) BETWEEN 16 AND 18
  GROUP BY end_station_name, day
),
daily_balance AS (
  SELECT 
      COALESCE(d.start_station_name, a.end_station_name) AS station_name,
      COALESCE(d.day, a.day) AS day,
      d.daily_departures,
      a.daily_arrivals,
      d.daily_departures - a.daily_arrivals AS balance
  FROM departures AS d
  FULL OUTER JOIN arrivals AS a
  ON d.start_station_name = a.end_station_name
  WHERE d.daily_departures - a.daily_arrivals < 0
)
SELECT 
    db.station_name,
    ROUND(AVG(db.daily_departures),0) AS avg_departures,
    ROUND(AVG(db.daily_arrivals),0) AS avg_arrivals,
    ROUND(AVG(db.balance),0) AS avg_balance,
    MAX(s.capacity) AS capacity
FROM daily_balance AS db
LEFT JOIN `bigquery-public-data.new_york_citibike.citibike_stations` AS s
ON db.station_name = s.name
WHERE s.is_renting IS TRUE
GROUP BY db.station_name
ORDER BY avg_balance ASC
LIMIT 10;

/*
Results - Most Critical Stations During 16-19hs Peak (most recent year):

| Station                       | Avg Departures | Avg Arrivals | Avg Balance | Capacity |
|-------------------------------|---------------|--------------|-------------|----------|
| 8 Ave & W 31 St               | 29            | 133          | -104        | 96       |
| 12 Ave & W 40 St              | 26            | 82           | -55         | 76       |
| W 31 St & 7 Ave               | 37            | 91           | -54         | 84       |
| 8 Ave & W 33 St               | 44            | 94           | -50         | 96       |
| W 41 St & 8 Ave               | 35            | 86           | -50         | 105      |
| Central Park S & 6 Ave        | 28            | 68           | -40         | 73       |
| FDR Drive & E 35 St           | 24            | 62           | -39         | 123      |
| Christopher St & Greenwich St | 32            | 69           | -37         | 74       |
| 6 Ave & W 33 St               | 35            | 70           | -35         | 78       |
| E 17 St & Broadway            | 45            | 80           | -35         | 78       |

Key findings:
- 8 Ave & W 31 St is the most critical station: avg daily imbalance of -104 bikes 
  against a capacity of 96 docks — arrivals consistently exceed departures by more 
  than its full capacity during peak hours
- Stations around Penn Station area (8 Ave & W 31 St, W 31 St & 7 Ave, 8 Ave & W 33 St,
  W 41 St & 8 Ave) dominate the top 5, suggesting a strong commuter destination cluster
- Limitation: negative balance means more arrivals than departures during 16-19hs, 
  which could indicate overflow risk rather than shortage — capacity context is key
*/
