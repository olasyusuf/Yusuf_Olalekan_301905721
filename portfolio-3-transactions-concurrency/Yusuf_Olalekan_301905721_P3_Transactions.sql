-- ============================================================================
-- MIT 8103 Advanced Database Systems: Practical Portfolio Blueprint
-- Case Study Focus: Ride-Hailing & Logistics System
-- Assessment Target: Portfolio 3 - Transaction Management Verification
-- Target Platform: PostgreSQL 16+
-- File: portfolio-3-transactions-concurrency/Yusuf_Olalekan_301905721_P3_Transactions.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STEP 1: STARTING-DATA CHECK
-- Verifies the initial baseline availability state for the target driver.
-- ----------------------------------------------------------------------------
SELECT driver_id, first_name || ' ' || last_name AS driver_name, availability_status 
FROM drivers 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4';


-- ----------------------------------------------------------------------------
-- STEP 2: VALID TRANSACTION WITH COMMIT
-- Modifies driver availability status and commits the change permanently.
-- Enforces a condition preventing concurrent repeated updates.
-- ----------------------------------------------------------------------------
BEGIN;

UPDATE drivers 
SET availability_status = 'UNAVAILABLE' 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4'
  AND availability_status = 'AVAILABLE';

COMMIT;

-- Repeat check to confirm the row no longer matches the 'AVAILABLE' criteria
SELECT driver_id, availability_status 
FROM drivers 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4'
  AND availability_status = 'AVAILABLE';


-- ----------------------------------------------------------------------------
-- STEP 3: INVALID TRANSACTION WITH ROLLBACK
-- Attempts an update followed by an intentional schema check constraint breach.
-- This forces an engine abort and a complete memory rollback.
-- ----------------------------------------------------------------------------
BEGIN;

UPDATE drivers 
SET availability_status = 'AVAILABLE' 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4';

-- Intentional failure: Violates 'valid_delivery_timeline' CHECK constraint (Rule 8)
-- The drop-off timestamp is deliberately configured to occur before the pickup time.
INSERT INTO trips (trip_id, rider_id, driver_id, cargo_weight_kg, delivery_type, trip_status, pickup_timestamp, dropoff_timestamp, calculated_fare) 
VALUES (
    '44444444-4444-4444-4444-444444444444', 
    '2852c716-0976-40df-949a-8a31fe073c32', 
    '2b123acd-30a1-4f72-92ff-774eb3b9e2b4', 
    25.00, 
    'STANDARD', 
    'COMPLETED', 
    '2026-11-10 09:00:00+01', 
    '2026-11-10 08:30:00+01', 
    1500.00
);

-- Transaction is automatically invalidated by the system error, prompting a rollback
ROLLBACK;


-- ----------------------------------------------------------------------------
-- STEP 4: POST-TRANSACTION VERIFICATION AUDIT
-- Proves that committed work remains while aborted work was completely discarded.
-- ----------------------------------------------------------------------------

-- 4.1 Confirm Chidi Okonkwo's committed status change remains fixed as 'UNAVAILABLE'
SELECT driver_id, first_name || ' ' || last_name AS driver_name, availability_status 
FROM drivers 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4';

-- 4.2 Confirm that the malformed, rolled-back trip record leaves no footprint
SELECT COUNT(*) AS total_failed_trips_found 
FROM trips 
WHERE trip_id = '44444444-4444-4444-4444-444444444444';
