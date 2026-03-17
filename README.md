# NYC Citi Bike Analysis
**Tools:** SQL, BigQuery  
**Dataset:** NYC Citi Bike Trips | Public Dataset `bigquery-public-data.new_york_citibike`  
**Period:** July 2013 - May 2018 | Queries use most recent year dynamically (no hardcoded dates)  
**Source:** [BigQuery Public Datasets - NYC Citi Bike](https://console.cloud.google.com/marketplace/details/city-of-new-york/nyc-citi-bike)

## Business Problem
This analysis addresses four operational questions:
- Which bikes require priority maintenance based on usage hours?
- Which stations experience the highest demand during peak hours?
- Which stations are most critical due to supply-demand imbalance during peak hours?
- How is trip volume and user type evolving month over month?

## Key Findings

- **Maintenance priority:** Top bike (#24939) logged 2,891 hours in the last 3 months, with 2,861 hours in the current month alone — a significant spike suggesting urgent maintenance review

- **Peak hours:** The 16-19hs slot concentrates 27% of all trips, followed by 7-10hs with 20%. Weekdays drive ~87% of total usage — weekends show significantly lower demand (Saturday 12.4%, Sunday 10.0%)

- **Top departure stations at peak hours:**
  - 16-19hs: Pershing Square North leads with 21,403 trips (1.4% of slot total)
  - 7-10hs: Pershing Square North also leads with 14,741 trips (1.3% of slot total)

- **Most critical station:** 8 Ave & W 31 St shows the largest avg daily imbalance during 16-19hs (-104 bikes/day) against a capacity of 97 docks — meaning arrivals consistently exceed departures by more than its full capacity

- **User trends:** Subscribers dominate at 87-97% of trips across all months. However, customer (non-subscriber) share is growing — from 3.1% in January to 13.3% in May — with customer trip growth rates (63-153%) outpacing subscriber growth (13-37%)

## Results Preview

### Top Bikes by Usage Hours (Last 3 Months)
| Bike ID | Current Month (hs) | Previous Month (hs) | 2 Months Ago (hs) | Total (hs) |
|---------|-------------------|--------------------|--------------------|------------|
| 24939 | 2,860.7 | 27.5 | 3.1 | 2,891.2 |
| 27183 | 2,607.8 | 27.2 | 22.5 | 2,657.6 |
| 18565 | 1,904.4 | 26.5 | 18.3 | 1,949.2 |

### Most Critical Stations During 16-19hs Peak
| Station | Avg Departures | Avg Arrivals | Avg Balance | Capacity |
|---------|---------------|--------------|-------------|----------|
| 8 Ave & W 31 St | 29 | 133 | -104 | 97 |
| 12 Ave & W 40 St | 26 | 82 | -55 | 76 |
| W 31 St & 7 Ave | 37 | 91 | -54 | 84 |

### Monthly Trip Evolution by User Type
| Month | Total Trips | % Subscriber | % Customer | Subscriber Growth | Customer Growth |
|-------|-------------|-------------|------------|-------------------|-----------------|
| 5 | 1,824,710 | 86.7% | 13.3% | +36.6% | +62.5% |
| 4 | 1,307,543 | 88.6% | 11.4% | +26.2% | +152.9% |
| 3 | 976,672 | 94.0% | 6.0% | +13.3% | +77.0% |
| 2 | 843,114 | 96.0% | 4.0% | +16.2% | +50.9% |
| 1 | 718,994 | 96.9% | 3.1% | - | - |

## Conclusions

1. **Maintenance:** Bike #24939 shows an extreme usage spike (2,861hs current month vs 27hs previous) — likely a data anomaly worth investigating, but if accurate, represents urgent maintenance priority
2. **Peak hour restock:** 16-19hs is the critical window for bike availability — stations near Penn Station (8 Ave & W 31 St, W 41 St & 8 Ave) show the largest deficits
3. **Commuter pattern:** The dominance of weekday peak slots (7-10hs and 16-19hs) confirms the system is primarily used for work commuting
4. **Growing casual segment:** Customer share tripled from 3.1% to 13.3% in 5 months — signals growing tourist/casual usage that may require different station stocking strategies than commuter-focused planning

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
