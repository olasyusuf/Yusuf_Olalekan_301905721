-- ============================================================================
-- MIT 8103 Advanced Database Systems: Practical Portfolio Blueprint
-- Case Study Focus: Ride-Hailing & Logistics System (Core Database Architecture)
-- Target Platform: PostgreSQL 16
-- ============================================================================
-- File: portfolio-1-database-design/Yusuf_Olalekan_301905721_P1_SampleData.sql
-- Run in the empty cargo_ride_portfolio database.
-- ============================================================================

BEGIN;

-- 1. Populate Independent Infrastructure Core Tables
INSERT INTO dispatch_centers (operational_code, physical_location) VALUES
('ABJ-CENTRAL', 'Plot 1024, Constitution Avenue, Central Business District, Abuja'),
('LOS-MAINLAND', '45, Isaac John Street, Ikeja GRA, Lagos');

INSERT INTO vehicles (license_plate, cargo_volume_class, last_inspection_date) VALUES
('ABJ-884-XA', 'HEAVY_FREIGHT', '2026-09-15'),
('LOS-112-BY', 'LIGHT_COURIER', '2026-10-01'),
('LOS-905-KT', 'MID_VAN',       '2026-10-10');

-- 2. Populate Dependent Participant Tables (Looking up generated parent IDs dynamically)
INSERT INTO drivers (first_name, last_name, license_number, dispatch_center_id, current_vehicle_id, availability_status) VALUES
('Chidi', 'Okonkwo', 'DRV-NGA-99218-A', (SELECT center_id FROM dispatch_centers WHERE operational_code = 'ABJ-CENTRAL'), (SELECT vehicle_id FROM vehicles WHERE license_plate = 'ABJ-884-XA'), 'AVAILABLE'),
('Amina', 'Yusuf',    'DRV-NGA-10492-B', (SELECT center_id FROM dispatch_centers WHERE operational_code = 'LOS-MAINLAND'), (SELECT vehicle_id FROM vehicles WHERE license_plate = 'LOS-112-BY'), 'UNAVAILABLE'),
('Tunde', 'Balogun',  'DRV-NGA-55210-C', (SELECT center_id FROM dispatch_centers WHERE operational_code = 'LOS-MAINLAND'), NULL, 'AVAILABLE');

INSERT INTO riders (account_number, first_name, last_name, email, phone_number) VALUES
('ACC-RIDER-001', 'Emeka', 'Nwachukwu', 'emeka.nwa@example.com', '+2348011122233'),
('ACC-RIDER-002', 'Funmi', 'Adeoti',    'funmi.ade@example.com', '+2348022233344'),
('ACC-RIDER-003', 'Zainab', 'Ibrahim',  'zainab.ib@example.com', '+2348033344455');

-- 3. Populate Operational Logging and Financial Ledger Tables
-- Scenario 1: A historically completed trip with its associated settled payment transaction
INSERT INTO trips (trip_id, rider_id, driver_id, cargo_weight_kg, delivery_type, trip_status, pickup_timestamp, dropoff_timestamp, calculated_fare) VALUES
('11111111-1111-1111-1111-111111111111', 
 (SELECT rider_id FROM riders WHERE account_number = 'ACC-RIDER-001'),
 (SELECT driver_id FROM drivers WHERE license_number = 'DRV-NGA-99218-A'),
 15.50, 'EXPRESS', 'COMPLETED', '2026-11-08 08:00:00+01', '2026-11-08 08:45:00+01', 4500.00);

INSERT INTO payments (trip_id, transaction_amount, payment_status, settled_at) VALUES
('11111111-1111-1111-1111-111111111111', 4500.00, 'SETTLED', '2026-11-08 08:46:00+01');

-- Scenario 2: An active, unfulfilled delivery request currently seeking a courier match
INSERT INTO trips (trip_id, rider_id, driver_id, cargo_weight_kg, delivery_type, trip_status, pickup_timestamp, dropoff_timestamp, calculated_fare) VALUES
('22222222-2222-2222-2222-222222222222', 
 (SELECT rider_id FROM riders WHERE account_number = 'ACC-RIDER-002'),
 NULL, -- Explicitly null because no driver has claimed it yet
 5.25, 'STANDARD', 'REQUESTED', '2026-11-08 17:30:00+01', NULL, 1200.00);

-- Scenario 3: An ongoing transit assignment currently active on the road ('EN_ROUTE')
INSERT INTO trips (trip_id, rider_id, driver_id, cargo_weight_kg, delivery_type, trip_status, pickup_timestamp, dropoff_timestamp, calculated_fare) VALUES
('32323232-3232-3232-3232-323232323232', 
 (SELECT rider_id FROM riders WHERE account_number = 'ACC-RIDER-003'),
 (SELECT driver_id FROM drivers WHERE license_number = 'DRV-NGA-10492-B'),
 120.00, 'FRAGILE', 'EN_ROUTE', '2026-11-08 16:00:00+01', NULL, 9500.00);

COMMIT;
