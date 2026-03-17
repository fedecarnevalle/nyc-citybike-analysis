# NYC Citi Bike Analysis | Executive Summary

## Dataset
NYC Citi Bike public trips data | July 2013 - May 2018  
Queries dynamically use most recent year — no hardcoded dates  
**Data quality note:** Trips over 4 hours excluded (`tripduration > 4 * 3600`) — affects 1.05% of records. Likely unreturned bikes or data errors.

---

## 1. Bike Maintenance Priority

Bikes ranked by usage hours across the last 3 months. `tripduration` converted from seconds to hours (`/ 3600`).

| Bike ID | Current Month (hs) | Previous Month (hs) | 2 Months Ago (hs) | Total (hs) |
|---------|-------------------|--------------------|--------------------|------------|
| 30929   | 90.4              | 33.4               | 11.3               | 135.1      |
| 32402   | 89.3              | 36.5               | 43.8               | 169.6      |
| 32143   | 87.1              | 48.7               | 19.3               | 155.1      |
| 33355   | 86.3              | 40.2               | 27.8               | 154.4      |
| 31202   | 84.8              | 30.9               | 26.0               | 141.7      |
| 30833   | 83.8              | 40.0               | 18.4               | 142.1      |
| 32576   | 83.6              | 35.9               | 38.5               | 158.0      |
| 33182   | 83.3              | 44.9               | 31.8               | 160.0      |
| 30042   | 82.4              | 34.2               | 11.0               | 127.6      |
| 33528   | 82.0              | 24.4               | 25.6               | 132.0      |

> Top bikes accumulate 80-90hs of usage per month consistently. Bike #32402 leads in total 3-month hours (169.6hs) while #30929 leads current month (90.4hs). Usage is stable across months with no extreme spikes, suggesting normal wear patterns across the fleet.

---

## 2. Peak Hours Demand

### Day of week
| Day       | Trips   | % Total |
|-----------|---------|---------|
| Thursday  | 926,668 | 16.4%   |
| Tuesday   | 924,184 | 16.3%   |
| Wednesday | 887,369 | 15.7%   |
| Monday    | 838,580 | 14.8%   |
| Friday    | 816,963 | 14.4%   |
| Saturday  | 703,135 | 12.4%   |
| Sunday    | 568,041 | 10.0%   |

> Weekdays concentrate ~87% of all trips. Sunday is the lowest demand day at 10%. No single weekday dominates — demand is evenly distributed Mon-Thu.

### Time slot
| Time Slot  | Trips     | % Total |
|------------|-----------|---------|
| 16-19      | 1,511,596 | 27%     |
| 7-10       | 1,115,791 | 20%     |
| 13-16      | 997,157   | 18%     |
| 10-13      | 818,418   | 14%     |
| 19-22      | 763,496   | 13%     |
| Other slot | 458,482   | 8%      |

> 16-19hs and 7-10hs combined concentrate 47% of all trips — a classic commuter pattern. Restocking and maintenance should be scheduled outside these two windows.

### Top departure stations — 16-19hs
| Station | Trips | % Slot |
|---------|-------|--------|
| Pershing Square North | 21,398 | 1.4% |
| Broadway & E 22 St | 15,286 | 1.0% |
| E 47 St & Park Ave | 13,860 | 0.9% |
| E 17 St & Broadway | 11,601 | 0.8% |
| W 21 St & 6 Ave | 11,453 | 0.8% |
| W 52 St & 6 Ave | 11,323 | 0.7% |
| Grand Army Plaza & Central Par.. | 9,620 | 0.6% |
| Broadway & W 25 St | 9,237 | 0.6% |
| West St & Chambers St | 9,204 | 0.6% |
| W 41 St & 8 Ave | 8,771 | 0.6% |

### Top departure stations — 7-10hs
| Station | Trips | % Slot |
|---------|-------|--------|
| Pershing Square North | 14,736 | 1.3% |
| 8 Ave & W 31 St | 9,298 | 0.8% |
| Broadway & W 41 St | 6,451 | 0.6% |
| Pershing Square South | 6,437 | 0.6% |
| E 7 St & Avenue A | 6,371 | 0.6% |
| Christopher St & Greenwich St | 6,352 | 0.6% |
| Columbus Ave & W 72 St | 6,346 | 0.6% |
| 8 Ave & W 33 St | 6,030 | 0.5% |
| E 13 St & Avenue A | 5,914 | 0.5% |
| W 31 St & 7 Ave | 5,899 | 0.5% |

> Pershing Square North is the only station appearing in top 10 for both peak slots — consistently highest demand location in the network. The 16-19hs top 10 is more concentrated (1.4% leader) than 7-10hs (1.3%), suggesting afternoon demand is slightly more station-specific.

---

## 3. Station Criticality During 16-19hs Peak

Stations ranked by avg daily balance (arrivals - departures) during peak hour. Negative balance means more arrivals than departures — overflow risk during evening commute.

| Station | Avg Departures | Avg Arrivals | Avg Balance | Capacity |
|---------|---------------|--------------|-------------|----------|
| 8 Ave & W 31 St | 29 | 133 | -104 | 96 |
| 12 Ave & W 40 St | 26 | 82 | -55 | 76 |
| W 31 St & 7 Ave | 37 | 91 | -54 | 84 |
| 8 Ave & W 33 St | 44 | 94 | -50 | 96 |
| W 41 St & 8 Ave | 35 | 86 | -50 | 105 |
| Central Park S & 6 Ave | 28 | 68 | -40 | 73 |
| FDR Drive & E 35 St | 24 | 62 | -39 | 123 |
| Christopher St & Greenwich St | 32 | 69 | -37 | 74 |
| 6 Ave & W 33 St | 35 | 70 | -35 | 78 |
| E 17 St & Broadway | 45 | 80 | -35 | 78 |

> 8 Ave & W 31 St is the most critical station: avg daily imbalance of -104 bikes against a capacity of 96 docks — arrivals consistently exceed departures by more than its full capacity. Stations around Penn Station area dominate the top 5, confirming a strong commuter destination cluster during evening peak.
>
> **Limitation:** negative balance indicates overflow risk (too many arrivals), not bike shortage. Bikes piling up at destination stations during 16-19hs means origin stations may face shortages simultaneously — a rebalancing operation rather than a simple restock.

---

## 4. Monthly User Trends

| Month | Total Trips | % Subscriber | % Customer | Subscriber Growth | Customer Growth |
|-------|-------------|-------------|------------|-------------------|-----------------|
| 5     | 1,822,092   | 86.8%       | 13.2%      | +36.6%            | +62.4%          |
| 4     | 1,306,078   | 88.6%       | 11.4%      | +26.2%            | +153.1%         |
| 3     | 975,823     | 94.0%       | 6.0%       | +13.3%            | +77.2%          |
| 2     | 842,457     | 96.1%       | 3.9%       | +16.2%            | +50.7%          |
| 1     | 718,490     | 96.9%       | 3.1%       | -                 | -               |

> Trip volume grows consistently month over month (+13% to +37% subscriber growth). Subscribers dominate at 87-97% but their share is declining as customer usage grows 3x faster. Customer share tripled from 3.1% in January to 13.2% in May, with growth rates (51-153%) consistently outpacing subscriber growth. This suggests growing tourist/casual usage that may require different station stocking strategies than commuter-focused planning.

---

## Overall Conclusions

1. **Restock Penn Station area first:** Stations around 8 Ave & W 31 St show imbalances exceeding their full capacity during 16-19hs — highest operational priority
2. **Two critical windows:** 16-19hs and 7-10hs concentrate 47% of all trips — restocking and maintenance should be scheduled outside these windows
3. **Pershing Square North needs special attention:** Only station appearing in top 10 for both peak slots simultaneously
4. **Growing casual segment requires different strategy:** Customer share growing 3x faster than subscribers — stations near tourist areas may need different stocking patterns than commuter hubs
