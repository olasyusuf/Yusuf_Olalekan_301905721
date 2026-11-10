-- ============================================================================
-- MIT 8103 Advanced Database Systems: Practical Portfolio Blueprint
-- Case Study Focus: Ride-Hailing & Logistics System
-- File: portfolio-2-query-optimisation/Yusuf_Olalekan_301905721_P2_Optimisation.sql
-- Target Platform: PostgreSQL 16
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STEP 1: PHYSICAL STORAGE OPTIMIZATION BLUEPRINTS
-- ----------------------------------------------------------------------------

-- 1.1 Composite Index for Query 1: Accelerates status filtering and table joins
CREATE INDEX IF NOT EXISTS idx_trips_en_route_covering 
ON trips (trip_status) 
INCLUDE (trip_id, rider_id, driver_id, cargo_weight_kg, delivery_type, pickup_timestamp);

-- 1.2 Partial Covering Index for Query 2: Only logs in-transit records [RENAMED]
-- This aligns cleanly with the partial structural rules from Portfolio 1
CREATE INDEX IF NOT EXISTS idx_active_driver_trip 
ON trips (driver_id) 
WHERE (trip_status = 'EN_ROUTE');

-- 1.3 Covering Index for Query 3: Enables Index-Only Scans over Rider joins
CREATE INDEX IF NOT EXISTS idx_trips_rider_ingestion_covering 
ON trips (rider_id) 
INCLUDE (trip_id);

-- 1.4 Partial B-Tree Index for Query 4: Tailored for Completed/Settled workflows
CREATE INDEX IF NOT EXISTS idx_trips_completed_fare_partial 
ON trips (calculated_fare) 
WHERE (trip_status = 'COMPLETED');

CREATE INDEX IF NOT EXISTS idx_payments_settled_amount_covering 
ON payments (payment_status, transaction_amount) 
INCLUDE (payment_id, trip_id, settled_at);

-- Refresh the planner's internal statistics engine
VACUUM ANALYZE dispatch_centers;
VACUUM ANALYZE vehicles;
VACUUM ANALYZE drivers;
VACUUM ANALYZE riders;
VACUUM ANALYZE trips;
VACUUM ANALYZE payments;


-- ----------------------------------------------------------------------------
-- STEP 2: TYPE-SAFE, HIGH-PERFORMANCE DECLARATIVE QUERIES
-- ----------------------------------------------------------------------------

-- [Query 1 Optimization]: Enforces strict type casting on literal string filters
EXPLAIN (ANALYZE, BUFFERS)
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


-- [Query 2 Optimization]: Keeps the subquery simple to match the partial index conditions
EXPLAIN (ANALYZE, BUFFERS)
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


-- [Query 3 Optimization]: Groups on the table primary key first to optimize grouping speeds
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    CAST(r.first_name || ' ' || r.last_name AS VARCHAR(101)) AS rider_name,
    COUNT(t.trip_id) AS total_trips_logged
FROM riders r
LEFT JOIN trips t USING (rider_id)
GROUP BY r.rider_id -- Sorting by primary key minimizes sorting overhead
ORDER BY total_trips_logged DESC, rider_name;


-- [Query 4 Optimization]: Aligns data types perfectly between the parent and subquery fields
EXPLAIN (ANALYZE, BUFFERS)
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
