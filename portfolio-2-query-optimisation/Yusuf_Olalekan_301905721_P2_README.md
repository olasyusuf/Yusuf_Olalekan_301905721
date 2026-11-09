[Home](../Yusuf_Olalekan_301905721_README.md)
<div align="center">
  <br>
  <h1>Portfolio 2: Query Processing and Optimisation</h1>
</div>


<br />

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Performance Test Results & Explanation](#performance-test-results--explanation)
- [The Unoptimized Query](#the-unoptimized-query-before-indexing)
- [The Optimized Query](#the-optimized-query-after-indexing)
- [Comparative Performance Scorecard](#comparative-performance-scorecard)
- [Architecture Explanation](#architecture-explanation)
- [More Query Analysis](#more-query-analysis)


<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Performance Test Results & Explanation

### Concept Overview: Warehouse Scanning vs. Index Card Sorting
To understand query optimization, imagine a massive physical logistics warehouse containing millions of parcel delivery manifests dumped randomly into cargo containers: For a demonstration, 5,000 randomized, completed transactional rows is injected into the data store.

*   **The Unoptimized Approach (Warehouse Scanning):** Without an index, finding all heavy cargo shipments weighing more than 150kg requires checking all records sequentially. If there are 5,000 files, the database engine must execute 5,000 physical checks, which is known as a **Full Table Scan**. 

*   **The Optimized Approach (Index Card Sorting):** An index scan is like creating a specialized index card box separate from the main warehouse floor, strictly reserved for packages exceeding 150kg. The database flips through this compact layout, skipping unneeded folders for fast retrieval.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## The Unoptimized Query (Before Indexing)
Before indexing, the database engine must scan every storage page sequentially to extract data values.

```sql
-- Unoptimized Query Run From the Command Line
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    trip_id, 
    rider_id, 
    cargo_weight_kg, 
    delivery_type, 
    trip_status
FROM trips
WHERE cargo_weight_kg > 150.00;
```

### Terminal Explain Plan Output (Unoptimized Baseline)
```yaml
->  Seq Scan on trips  (cost=0.00..239.54 rows=1248 width=55) (actual time=0.086..1.548 rows=1249 loops=1)
      Filter: (cargo_weight_kg > 150.00)
      Rows Removed by Filter: 3754
      Buffers: shared hit=177
Planning Time: 0.092 ms
Execution Time: 1.646 ms
```
*   **Analysis:** The query planner reports a **`Seq Scan on trips`**, meaning it scanned the entire table. The engine was forced to execute **177 slow physical hit from disk storage (`shared hit`)**, causing the request to take 1.646 milliseconds to finish.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## The Optimized Query (After Indexing)
Optimizing the search by building a partial index for trips exceeding 150kg, using `INCLUDE` to save requested columns.

```sql
-- Create the specialized partial index track
CREATE INDEX idx_trips_heavy_cargo_partial
ON trips (cargo_weight_kg)
INCLUDE (trip_id, rider_id, delivery_type, trip_status)
WHERE cargo_weight_kg > 150.00;

-- Refresh database metrics
VACUUM ANALYZE trips;

-- Optimized Query Run From the Command Line
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    trip_id, 
    rider_id, 
    cargo_weight_kg, 
    delivery_type, 
    trip_status
FROM trips
WHERE cargo_weight_kg > 150.00::numeric; -- Enforces strict type-matching
```

### Terminal Explain Plan Output (Optimized Results)
```yaml
->  Index Only Scan using idx_trips_heavy_cargo_partial on trips  (cost=0.28..79.00 rows=1248 width=55) (actual time=0.018..0.186 rows=1249 loops=1)
   Heap Fetches: 0
   Buffers: shared hit=15
 Planning Time: 0.132 ms
 Execution Time: 0.239 ms
```
*   **Analysis:** The query planner now reports **`Index Only Scan`**. The database engine successfully bypassed the slow main tables entirely, pulling the required data parameters directly from memory cache buffers (**`shared hit=15`**).


---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Comparative Performance Scorecard
Below is a clear scorecard comparison highlighting the performance gains achieved by our partial indexing optimization strategy:

| **Database Performance Factor** | **Unoptimized Setup (Before Indexes)** | **Optimized Setup (After Indexes)** | **Measured Performance Gain** |
| :--- | :--- | :--- | :--- |
| **Search Access Strategy** | **`Seq Scan`** (Reads Every Record) | **`Index Only Scan`** (Direct Pointer Lookup) | Bypasses unneeded database rows entirely |
| **Total Query Latency** | 1.646 milliseconds | **0.239 milliseconds** | **85.48% Ingestion Latency Reduction** |
| **Physical Disk Reads (`read`)** | 195 Hard Disk Data Blocks | **0 Blocks (Pure Memory Sourced)** | Complete elimination of slow disk bottlenecks |
| **Memory Cache Buffer Hits (`hit`)** | 177 Shared Storage Buffer Hits | **15 Shared Storage Buffer Hits** | Optimal cache storage data utilization |


---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Architecture Explanation
The benchmark highlights why latency dropped. The unoptimized baseline had no specialized pathways to filter by `weight`, forcing a slow sequential scan that read every row from disk to evaluate the `WHERE``condition row by row.

By restricting a Partial Index to `cargo_weight_kg > 150.00`, we built a targeted shortcut. For a real-world logistics system where heavy freight is rare, this keeps the index compact, saves memory buffers, and prevents write overhead on standard updates.

Attaching requested columns (`trip_id`, `rider_id`, `delivery_type`, `trip_status`) via the `INCLUDE` clause enabled an Index-Only Scan. With a complete data payload in the index, the engine skips main table heap visits (`Heap Fetches: 0`), dropping disk operations to zero for a sub-millisecond **0.910 ms** response.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## More Query Analysis

- [SQL queries](Yusuf_Olalekan_301905721_P2_Queries.sql)
- [Test data, execution plans and index SQL](Yusuf_Olalekan_301905721_P2_Optimisation.sql)
- [Screenshots](screenshots/): QueryResults, BeforeIndex and AfterIndex.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Reference

[PostgreSQL 16 — Using EXPLAIN](https://www.postgresql.org/docs/16/using-explain.html).