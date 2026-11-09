-- ============================================================================
-- MIT 8103 Advanced Database Systems: Practical Portfolio Blueprint
-- Case Study Focus: Ride-Hailing & Logistics System
-- Assessment Target: Portfolio 2 - Queries and Data Retrieval Engine
-- Target Platform: PostgreSQL 16
-- ============================================================================
-- File: portfolio-2-query-optimisation/Yusuf_Olalekan_301905721_P2_Queries.sql
-- ============================================================================


-- ============================================================================
-- CORE REPORTING QUERIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 1: Active Ongoing Transits
-- Short Heading: Active Multi-Table Join Log
-- Explanation: Fetches customer, driver, and cargo metrics for in-transit entries.
-- Expected Baseline Rows: 1 row (Zainab Ibrahim matching Aliyu/Yusuf)
-- ----------------------------------------------------------------------------
SELECT 
    CAST(r.first_name || ' ' || r.last_name AS VARCHAR(101)) AS rider_name,
    CAST(d.first_name || ' ' || d.last_name AS VARCHAR(101)) AS driver_name,
    t.cargo_weight_kg,
    t.delivery_type,
    t.pickup_timestamp
FROM trips t
JOIN riders r USING (rider_id)
JOIN drivers d USING (driver_id)
WHERE t.trip_status = 'EN_ROUTE'::varchar
ORDER BY t.pickup_timestamp;


-- ----------------------------------------------------------------------------
-- QUERY 2: Available Vehicles Not Engaged in Active In-Transit Assignments
-- Short Heading: Equipment Availability Correlated Check
-- Explanation: Employs a NOT EXISTS subquery to isolate unengaged asset blocks.
-- Expected Baseline Rows: 2 rows (ABJ-884-XA and LOS-905-KT)
-- ----------------------------------------------------------------------------
SELECT v.license_plate, v.cargo_volume_class
FROM vehicles v
WHERE NOT EXISTS (
    SELECT 1 
    FROM trips t
    JOIN drivers d USING (driver_id)
    WHERE d.current_vehicle_id = v.vehicle_id 
      AND t.trip_status = 'EN_ROUTE'::varchar
)
ORDER BY v.license_plate;


-- ----------------------------------------------------------------------------
-- QUERY 3: Cumulative Trip Ingestion Audit by Customer
-- Short Heading: Outer Aggregation Record Metrics
-- Explanation: Uses a LEFT JOIN to count all platform logs without dropping zero-activity users.
-- Expected Baseline Rows: 3 rows (Zainab Ibrahim: 5001, Emeka: 1, Funmi: 1)
-- ----------------------------------------------------------------------------
SELECT 
    CAST(r.first_name || ' ' || r.last_name AS VARCHAR(101)) AS rider_name,
    COUNT(t.trip_id) AS total_trips_logged
FROM riders r
LEFT JOIN trips t USING (rider_id)
GROUP BY r.rider_id, r.first_name, r.last_name
ORDER BY total_trips_logged DESC, rider_name;


-- ----------------------------------------------------------------------------
-- QUERY 4: Revenue Generation Threshold Evaluation
-- Short Heading: Scalar Nested Subquery Analysis
-- Explanation: Identifies payments exceeding the general system averages.
-- Expected Baseline Rows: 1 row (Trip ID ending in 111111111111)
-- ----------------------------------------------------------------------------
SELECT 
    payment_id,
    trip_id,
    transaction_amount,
    settled_at
FROM payments
WHERE payment_status = 'SETTLED'::varchar
  AND transaction_amount > (
      SELECT CAST(AVG(calculated_fare) AS NUMERIC(10,2))
      FROM trips 
      WHERE trip_status = 'COMPLETED'::varchar
  )
ORDER BY transaction_amount DESC, settled_at;
