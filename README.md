# NYC Citi Bike Analysis
**Tools:** SQL, BigQuery  
**Dataset:** NYC Citi Bike Trips | Public Dataset `bigquery-public-data.new_york_citibike`  
**Period:** July 2013 - May 2018 | Queries dynamically use most recent year — no hardcoded dates  
**Source:** [BigQuery Public Datasets - NYC Citi Bike](https://console.cloud.google.com/marketplace/details/city-of-new-york/nyc-citi-bike)

## Overview
SQL analysis of NYC Citi Bike public data exploring operational patterns to optimize bike availability, maintenance prioritization and station restocking strategies. Queries are fully dynamic — no hardcoded dates — making them reusable as new data becomes available.

**Data quality note:** The dataset contains trips with durations up to 225 days, likely unreturned bikes or data errors. All analyses exclude trips over 4 hours (`tripduration > 4 * 3600`), which affects 1.05% of records. This threshold aligns with Citi Bike's pricing structure where extended trips incur additional charges.

## Business Questions
- Which bikes require priority maintenance based on usage hours?
- Which stations experience the highest demand during peak hours?
- Which stations are most critical due to supply-demand imbalance during peak hours?
- How is trip volume and user type evolving month over month?

## Key Findings

- **Maintenance priority:** Top bike (#30929) logged 90.4hs in the current month and 135.1hs across the last 3 months — consistent usage pattern across top bikes (~80-90hs/month)

- **Peak hours:** The 16-19hs slot concentrates 27% of all trips, followed by 7-10hs with 20%. Combined, these two slots account for 47% of daily demand — a clear commuter pattern. Weekdays drive ~87% of total usage

- **Top departure station:** Pershing Square North leads demand in both peak slots (21,398 trips at 16-19hs and 14,736 trips at 7-10hs)

- **Most critical station:** 8 Ave & W 31 St shows the largest avg daily imbalance during 16-19hs (-104 bikes/day) against a capacity of 96 docks. Stations around Penn Station area dominate the top 5 most critical

- **Growing casual segment:** Customer share tripled from 3.1% in January to 13.2% in May, with growth rates (51-153%) consistently outpacing subscriber growth (13-37%)

## Results Preview

### Most Critical Stations During 16-19hs Peak
| Station | Avg Departures | Avg Arrivals | Avg Balance | Capacity |
|---------|---------------|--------------|-------------|----------|
| 8 Ave & W 31 St | 29 | 133 | -104 | 96 |
| 12 Ave & W 40 St | 26 | 82 | -55 | 76 |
| W 31 St & 7 Ave | 37 | 91 | -54 | 84 |

### Monthly Trip Evolution by User Type
| Month | Total Trips | % Subscriber | % Customer | Subscriber Growth | Customer Growth |
|-------|-------------|-------------|------------|-------------------|-----------------|
| 5 | 1,822,092 | 86.8% | 13.2% | +36.6% | +62.4% |
| 4 | 1,306,078 | 88.6% | 11.4% | +26.2% | +153.1% |
| 3 | 975,823 | 94.0% | 6.0% | +13.3% | +77.2% |
| 2 | 842,457 | 96.1% | 3.9% | +16.2% | +50.7% |
| 1 | 718,490 | 96.9% | 3.1% | - | - |

## Conclusions

1. **Restock Penn Station area first:** Stations around 8 Ave & W 31 St show imbalances exceeding their full capacity during 16-19hs — highest operational priority
2. **Two critical windows:** 16-19hs and 7-10hs concentrate 47% of all trips — restocking and maintenance should be scheduled outside these windows
3. **Pershing Square North needs special attention:** Only station appearing in top 10 for both peak slots simultaneously
4. **Growing casual segment requires different strategy:** Customer share growing 3x faster than subscribers — stations near tourist areas may need different stocking patterns than commuter hubs

→ [Full Executive Summary](results/executive_summary.md)

## Repository Structure
```
nyc-citibike-analysis/
│
├── README.md
├── queries/
│   ├── 01_bike_maintenance_priority.sql
│   ├── 02_peak_hours_demand.sql
│   ├── 03_station_criticality.sql
│   └── 04_monthly_user_trends.sql
└── results/
    └── executive_summary.md
```
