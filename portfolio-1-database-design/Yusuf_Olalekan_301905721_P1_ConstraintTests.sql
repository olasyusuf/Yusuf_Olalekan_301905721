-- ============================================================================
-- MIT 8103 Advanced Database Systems: Practical Portfolio Blueprint
-- Case Study Focus: Ride-Hailing & Logistics System (Core Database Architecture)
-- Target Platform: PostgreSQL 16
-- ============================================================================
-- File: portfolio-1-database-design/Yusuf_Olalekan_301905721_P1_ConstraintTests.sql
-- Run in the empty cargo_ride_portfolio database.
-- ============================================================================
-- Executed outside of an open transaction block.
-- Each query is designed to deliberately fail and verify a specific system rule.

-- ============================================================================
-- TEST SET 1: REQUIRED FIELDS (NOT NULL CONSTRAINTS)
-- ============================================================================

-- Expected Error: null value in column "physical_location" of relation "dispatch_centers" violates not-null constraint
INSERT INTO dispatch_centers (operational_code, physical_location) VALUES
('KNL-CENTRAL', NULL);

-- Expected Error: null value in column "cargo_weight_kg" of relation "trips" violates not-null constraint
INSERT INTO trips (rider_id, driver_id, cargo_weight_kg, delivery_type, trip_status, pickup_timestamp, calculated_fare) VALUES
((SELECT rider_id FROM riders WHERE account_number = 'ACC-RIDER-001'), NULL, NULL, 'STANDARD', 'REQUESTED', '2026-11-08 10:00:00+01', 1000.00);


-- ============================================================================
-- TEST SET 2: UNIQUE CONSTRAINTS (DUPLICATE VALUE PROTECTION)
-- ============================================================================

-- Expected Error: duplicate key value violates unique constraint "dispatch_centers_operational_code_key"
INSERT INTO dispatch_centers (operational_code, physical_location) VALUES
('ABJ-CENTRAL', 'Plot 55, Herbert Macaulay Way, Wuse, Abuja');

-- Expected Error: duplicate key value violates unique constraint "riders_email_key"
INSERT INTO riders (account_number, first_name, last_name, email, phone_number) VALUES
('ACC-RIDER-999', 'John', 'Sani', 'emeka.nwa@example.com', '+2348099988877');

-- Expected Error: duplicate key value violates unique constraint "drivers_current_vehicle_id_key"
-- Reason: Enforces that a specific fleet vehicle cannot be split across multiple concurrent drivers
INSERT INTO drivers (first_name, last_name, license_number, dispatch_center_id, current_vehicle_id, availability_status) VALUES
('Musa', 'Ibrahim', 'DRV-NGA-00001-X', 
 (SELECT center_id FROM dispatch_centers WHERE operational_code = 'ABJ-CENTRAL'), 
 (SELECT vehicle_id FROM vehicles WHERE license_plate = 'ABJ-884-XA'), 'AVAILABLE');


-- ============================================================================
-- TEST SET 3: FOREIGN KEYS (REFERENTIAL INTEGRITY CHECKS)
-- ============================================================================

-- Expected Error: insert or update on table "drivers" violates foreign key constraint "drivers_dispatch_center_id_fkey"
INSERT INTO drivers (first_name, last_name, license_number, dispatch_center_id, current_vehicle_id, availability_status) VALUES
('Sani', 'Aliyu', 'DRV-NGA-88371-D', '00000000-0000-0000-0000-000000000000', NULL, 'AVAILABLE');

-- Expected Error: insert or update on table "payments" violates foreign key constraint "payments_trip_id_fkey"
INSERT INTO payments (trip_id, transaction_amount, payment_status) VALUES
('00000000-0000-0000-0000-000000000000', 2500.00, 'PENDING');


-- ============================================================================
-- TEST SET 4: CHECK CONSTRAINTS (VALID RANGE & VALUE CHECKS)
-- ============================================================================

-- Expected Error: new row for relation "vehicles" violates check constraint "vehicles_cargo_volume_class_check"
INSERT INTO vehicles (license_plate, cargo_volume_class, last_inspection_date) VALUES
('PHC-441-ZZ', 'INVALID_CARGO_CLASS_TYPE', '2026-11-01');

-- Expected Error: new row for relation "trips" violates check constraint "trips_cargo_weight_kg_check"
INSERT INTO trips (rider_id, driver_id, cargo_weight_kg, delivery_type, trip_status, pickup_timestamp, calculated_fare) VALUES
((SELECT rider_id FROM riders WHERE account_number = 'ACC-RIDER-001'), NULL, -15.50, 'STANDARD', 'REQUESTED', '2026-11-08 10:00:00+01', 1000.00);

-- Expected Error: new row for relation "trips" violates check constraint "valid_delivery_timeline"
-- Reason: Protects the system from logical errors where a delivery finishes before it starts
INSERT INTO trips (rider_id, driver_id, cargo_weight_kg, delivery_type, trip_status, pickup_timestamp, dropoff_timestamp, calculated_fare) VALUES
((SELECT rider_id FROM riders WHERE account_number = 'ACC-RIDER-001'), NULL, 10.00, 'STANDARD', 'COMPLETED', '2026-11-08 12:00:00+01', '2026-11-08 11:30:00+01', 1500.00);


-- ============================================================================
-- TEST SET 5: CONDITIONAL UNIQUENESS (PARTIAL UNIQUE INDEX)
-- ============================================================================

-- Expected Error: duplicate key value violates unique constraint "trips_driver_id_idx"
-- Reason: Enforces Business Rule 6 & 7: A driver can participate in at most ONE active delivery ('EN_ROUTE') at any specific time.
-- Note: Amina Yusuf (Driver 10492-B) already has an active trip ('32323232-3232-3232-3232-323232323232') in the baseline dataset.
INSERT INTO trips (rider_id, driver_id, cargo_weight_kg, delivery_type, trip_status, pickup_timestamp, dropoff_timestamp, calculated_fare) VALUES
((SELECT rider_id FROM riders WHERE account_number = 'ACC-RIDER-001'), 
 (SELECT driver_id FROM drivers WHERE license_number = 'DRV-NGA-10492-B'), 
 8.00, 'EXPRESS', 'EN_ROUTE', '2026-11-08 17:00:00+01', NULL, 2200.00);


-- ============================================================================
-- 5. FINAL MASTER RECONCILIATION SUMMARY AUDIT
-- ============================================================================

SELECT 'dispatch_centers' table_name, COUNT(*) FROM dispatch_centers record_count UNION ALL
SELECT 'vehicles' table_name, COUNT(*) FROM vehicles UNION ALL
SELECT 'drivers' table_name, COUNT(*) FROM drivers UNION ALL
SELECT 'riders' table_name, COUNT(*) FROM riders UNION ALL
SELECT 'trips' table_name, COUNT(*) FROM trips UNION ALL
SELECT 'payments' table_name, COUNT(*) FROM payments;