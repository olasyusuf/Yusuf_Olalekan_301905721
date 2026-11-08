-- ============================================================================
-- MIT 8103 Advanced Database Systems: Practical Portfolio Blueprint
-- Case Study Focus: Ride-Hailing & Logistics System (Core Database Architecture)
-- Target Platform: PostgreSQL 15+
-- File: portfolio-1-database-design/Yusuf_Olalekan_301905721_P1_Schema.sql
-- Run in the empty cargo_ride_portfolio database.
-- ============================================================================


-- Activate the cryptographic (secured) UUID generation extension within the transaction boundary
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. INFRASTRUCTURE & ASSET TABLES (Independent Core Tables)
-- ============================================================================

-- 1.1 Corporate Dispatch Centers Master Store
CREATE TABLE dispatch_centers (
    center_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    operational_code VARCHAR(30) NOT NULL UNIQUE,
    physical_location VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 1.2 Fleet Logistics Vehicles Master Store
CREATE TABLE vehicles (
    vehicle_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    cargo_volume_class VARCHAR(30) NOT NULL CHECK (cargo_volume_class IN ('LIGHT_COURIER', 'MID_VAN', 'HEAVY_FREIGHT')),
    last_inspection_date DATE NOT NULL
);

-- ============================================================================
-- 2. PARTICIPANT & PROFILE TABLES (Dependent Core Tables)
-- ============================================================================

-- 2.1 Corporate Drivers Master Store
CREATE TABLE drivers (
    driver_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    dispatch_center_id UUID NOT NULL REFERENCES dispatch_centers(center_id) ON DELETE RESTRICT,
    current_vehicle_id UUID UNIQUE REFERENCES vehicles(vehicle_id) ON DELETE SET NULL,
    availability_status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE' CHECK (availability_status IN ('AVAILABLE', 'UNAVAILABLE')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2.2 Registered Riders / Customers Master Store
CREATE TABLE riders (
    rider_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_number VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. OPERATIONAL TRANSACTIONAL TABLES (Operational Logs & Financial Ledgers)
-- ============================================================================

-- 3.1 Logistics, Ride-Hailing, & Freight Trips Store
CREATE TABLE trips (
    trip_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rider_id UUID NOT NULL REFERENCES riders(rider_id) ON DELETE RESTRICT,
    driver_id UUID REFERENCES drivers(driver_id) ON DELETE RESTRICT,
    cargo_weight_kg NUMERIC(8, 2) NOT NULL CHECK (cargo_weight_kg > 0.00),
    delivery_type VARCHAR(20) NOT NULL CHECK (delivery_type IN ('EXPRESS', 'STANDARD', 'FRAGILE')),
    trip_status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED' CHECK (trip_status IN ('REQUESTED', 'ACCEPTED', 'EN_ROUTE', 'COMPLETED', 'CANCELLED')),
    pickup_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    dropoff_timestamp TIMESTAMP WITH TIME ZONE,
    calculated_fare NUMERIC(10, 2) NOT NULL CHECK (calculated_fare >= 0.00),
    CONSTRAINT valid_delivery_timeline CHECK (dropoff_timestamp IS NULL OR dropoff_timestamp >= pickup_timestamp)
);

-- 3.2 Transactional Settlement & Payment Store (Strict 1:1 Relationship with Trips)
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL UNIQUE REFERENCES trips(trip_id) ON DELETE RESTRICT,
    transaction_amount NUMERIC(10, 2) NOT NULL CHECK (transaction_amount >= 0.00),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'SETTLED', 'FAILED')),
    settled_at TIMESTAMP WITH TIME ZONE
);