-- ================================================================
-- Monthly User Trends Analysis
-- Objective: Track trip volume growth and user type distribution
-- month over month to understand demand patterns and user mix
-- Analysis period: most recent year in dataset (dynamic, no hardcoded dates)
-- Note: trips > 4 hours filtered out as data errors or unreturned bikes
-- ================================================================

WITH max_date AS (
  SELECT MAX(DATE_TRUNC(starttime, YEAR)) AS max_year
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
),
monthly_trips AS (
  SELECT
      EXTRACT(MONTH FROM starttime) AS month,
      COUNT(*) AS total_trips,
      SUM(CASE WHEN usertype = 'Subscriber' THEN 1 ELSE 0 END) AS subscriber_trips,
      SUM(CASE WHEN usertype = 'Customer' THEN 1 ELSE 0 END) AS customer_trips
  FROM `bigquery-public-data.new_york_citibike.citibike_trips`
  WHERE tripduration IS NOT NULL 
        AND tripduration <= 4 * 3600
        AND DATE_TRUNC(starttime, YEAR) = (SELECT max_year FROM max_date)
  GROUP BY month
)
SELECT
    month,
    total_trips,
    ROUND(100 * subscriber_trips / total_trips, 1) AS pct_subscriber,
    ROUND(100 * customer_trips / total_trips, 1) AS pct_customer,
    ROUND(100 * (subscriber_trips - LAG(subscriber_trips) OVER(ORDER BY month)) 
          / LAG(subscriber_trips) OVER(ORDER BY month), 1) AS pct_variation_subscriber,
    ROUND(100 * (customer_trips - LAG(customer_trips) OVER(ORDER BY month)) 
          / LAG(customer_trips) OVER(ORDER BY month), 1) AS pct_variation_customer
FROM monthly_trips
ORDER BY month DESC;

/*
Results - Monthly Trip Evolution by User Type (most recent year):

| Month | Total Trips | % Subscriber | % Customer | Subscriber Growth | Customer Growth |
|-------|-------------|-------------|------------|-------------------|-----------------|
| 5     | 1,822,092   | 86.8%       | 13.2%      | +36.6%            | +62.4%          |
| 4     | 1,306,078   | 88.6%       | 11.4%      | +26.2%            | +153.1%         |
| 3     | 975,823     | 94.0%       | 6.0%       | +13.3%            | +77.2%          |
| 2     | 842,457     | 96.1%       | 3.9%       | +16.2%            | +50.7%          |
| 1     | 718,490     | 96.9%       | 3.1%       | -                 | -               |

Key findings:
- Trip volume grows consistently month over month (+13% to +37% subscriber growth)
- Subscribers dominate at 87-97% across all months but their share is declining
- Customer (non-subscriber) share tripled from 3.1% in January to 13.2% in May
- Customer growth rates (51-153%) consistently outpace subscriber growth (13-37%),
  suggesting growing tourist/casual usage — may require different stocking strategies
  than commuter-focused planning
*/
