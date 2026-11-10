-- ============================================================================
-- MIT 8103 Advanced Database Systems: Practical Portfolio Blueprint
-- Case Study Focus: Ride-Hailing & Logistics System
-- Assessment Target: Portfolio 3 - Two-Session Concurrency & Locking Script
-- Target Platform: PostgreSQL 16
-- File: portfolio-3-transactions-concurrency/Yusuf_Olalekan_301905721_P3_Concurrency.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STEP 1: BASELINE RECORD VERIFICATION
-- Run this initial verification query in either terminal window session 
-- to confirm the target trip record is unassigned and open for acquisition.
-- ----------------------------------------------------------------------------
SELECT trip_id, driver_id, trip_status 
FROM trips 
WHERE trip_id = '22222222-2222-2222-2222-222222222222';


-- ----------------------------------------------------------------------------
-- STEP 2: THE PARALLEL EXECUTION TIMELINE DEMONSTRATION
-- Follow these instructions sequentially across two distinct psql CLI sessions.
-- ----------------------------------------------------------------------------

-- [TIMELINE STEP 2.1]: RUN IN SESSION 1 TERMINAL WINDOW
-- Session 1 opens a transaction and acquires an exclusive row-level write lock.
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT trip_id, trip_status 
FROM trips 
WHERE trip_id = '22222222-2222-2222-2222-222222222222' 
FOR UPDATE;

-- Result: Session 1 successfully locks the record. Keep this terminal open.


-- [TIMELINE STEP 2.2]: RUN IN SESSION 2 TERMINAL WINDOW
-- Session 2 concurrently attempts to select and lock the exact same row.
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT trip_id, trip_status 
FROM trips 
WHERE trip_id = '22222222-2222-2222-2222-222222222222' 
FOR UPDATE;

-- Result: Session 2 prompt freezes instantly. It is blocked by Session 1.


-- [TIMELINE STEP 2.3]: SWITCH BACK AND RUN IN SESSION 1 TERMINAL WINDOW
-- Session 1 performs the atomic state update and commits, releasing its lock.
UPDATE trips 
SET driver_id = '3077e208-e9e2-4a31-a67a-c403af0a5472', 
    trip_status = 'ACCEPTED' 
WHERE trip_id = '22222222-2222-2222-2222-222222222222';

COMMIT;

-- Result: Session 1 commits. At this exact moment, Session 2 automatically
-- unfreezes in its window, re-reads the committed state, and returns 'ACCEPTED'.


-- [TIMELINE STEP 2.4]: SWITCH BACK AND RUN IN SESSION 2 TERMINAL WINDOW
-- Session 2 safely steps down its transaction since the trip was already claimed.
ROLLBACK;


-- ----------------------------------------------------------------------------
-- STEP 3: POST-CONCURRENCY FINAL SYSTEM AUDIT
-- Execute this script in either window to verify that the row state is preserved 
-- and data anomalies (such as Lost Updates or double-allocations) were avoided.
-- ----------------------------------------------------------------------------
SELECT trip_id, driver_id, trip_status 
FROM trips 
WHERE trip_id = '22222222-2222-2222-2222-222222222222';
