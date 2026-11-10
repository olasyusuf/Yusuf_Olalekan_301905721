[Home](../Yusuf_Olalekan_301905721_README.md)
<div align="center">
  <br>
  <h1>Portfolio 3 Transactions and Concurrency</h1>
</div>


<br />

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Transaction Management](#transaction-management)
  - [1. Starting-Data Check](#1-starting-data-check)
  - [2. Valid Transaction with COMMIT](#2-valid-transaction-with-commit)
  - [3. Invalid Transaction with ROLLBACK](#3-invalid-transaction-with-rollback)
  - [4. Post-Transaction Verification Audit](#4-post-transaction-verification-audit)
- [Two-Session Concurrency and Locking](#two-session-concurrency-and-locking)
  - [Step 1: Baseline Record Verification](#step-1-baseline-record-verification)
  - [Step 2: The Parallel Execution Timeline](#step-2-the-parallel-execution-timeline)
  - [Step 3: Post-Concurrency Final System Audit](#step-3-post-concurrency-final-system-audit)
- [Test Results](#test-results)
  

  

    
    

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Transaction Management

This demonstrates how transaction boundaries and database constraints protect data integrity in the `cargo_ride_portfolio` system, ensuring changes process in a safe, predictable order.

<br />

### 1. Starting-Data Check
Before executing any state modifications, the system state is checked to identify the exact records available for this exercise. Based on the active database logs, driver **Chidi Okonkwo** (`2b123acd-30a1-4f72-92ff-774eb3b9e2b4`) is currently unengaged with his availability status set to `AVAILABLE`.

```sql
-- Check the baseline availability status for Chidi Okonkwo
SELECT driver_id, first_name || ' ' || last_name AS driver_name, availability_status 
FROM drivers 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4';
```

#### Result
```text
              driver_id               |  driver_name   | availability_status 
──────────────────────────────────────+────────────────+─────────────────────
 2b123acd-30a1-4f72-92ff-774eb3b9e2b4 | Chidi Okonkwo  | AVAILABLE
```

*Explanation:* This query confirms that the target driver record is in the correct initial state to be safely assigned to a dispatch operation.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

### 2. Valid Transaction with COMMIT
This block opens a transaction, updates the driver's duty status to prevent duplicate dispatch assignments, and permanently saves the modification using `COMMIT`. The query uses a conditional clause (`WHERE availability_status = 'AVAILABLE'`) to ensure the status change cannot be repeated if another parallel process modifies the row first.

```sql
-- Begin the block, assign the driver to a trip, and lock the row state
BEGIN;

UPDATE drivers 
SET availability_status = 'UNAVAILABLE' 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4'
  AND availability_status = 'AVAILABLE';

COMMIT;

-- Repeat check to prove the operation cannot be duplicated
SELECT driver_id, availability_status 
FROM drivers 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4'
  AND availability_status = 'AVAILABLE';
```

#### Result
```text
BEGIN
UPDATE 1
COMMIT

 driver_id | availability_status 
───────────+─────────────────────
(0 rows)
```

*Explanation:* The transaction successfully alters the state from available to unavailable, and the repeat check returns zero rows, proving that the operation cannot run a second time.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

### 3. Invalid Transaction with ROLLBACK
This block demonstrates how the database engine handles a data validation error by rolling back an entire transaction, ensuring that a partial or invalid change never corrupts the database. The statement is intentionally run outside of the previous block so that this specific constraint check can be evaluated independently.

```sql
-- Begin a new block, attempt a valid update, then cause an intentional sequence breach
BEGIN;

UPDATE drivers 
SET availability_status = 'AVAILABLE' 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4';

-- Intentional failure: Violating the valid_delivery_timeline CHECK constraint (Rule 8)
-- The dropoff_timestamp is deliberately configured to occur before the pickup_timestamp
INSERT INTO trips (trip_id, rider_id, driver_id, cargo_weight_kg, delivery_type, trip_status, pickup_timestamp, dropoff_timestamp, calculated_fare) VALUES
('44444444-4444-4444-4444-444444444444', 
 '2852c716-0976-40df-949a-8a31fe073c32', 
 '2b123acd-30a1-4f72-92ff-774eb3b9e2b4', 
 25.00, 'STANDARD', 'COMPLETED', '2026-11-10 09:00:00+01', '2026-11-10 08:30:00+01', 1500.00);

-- The transaction is aborted by the system due to the error, forcing a rollback
ROLLBACK;
```

#### Result
```text
BEGIN
UPDATE 1
ERROR:  new row for relation "trips" violates check constraint "valid_delivery_timeline"
DETAIL:  Failing row contains (44444444-4444-4444-4444-444444444444, 2852c716-0976-40df-949a-8a31fe073c32, 2b123acd-30a1-4f72-92ff-774eb3b9e2b4, 25.00, STANDARD, COMPLETED, 2026-11-10 09:00:00+01, 2026-11-10 08:30:00+01, 1500.00, 2026-11-10 03:32:00+01).
ROLLBACK
```

*Explanation:* The database engine catches the timeline violation, rejects the invalid trip entry, and invokes `ROLLBACK` to completely discard the driver status update from memory.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

### 4. Post-Transaction Verification Audit
A final audit check is executed to prove that the committed data was written permanently to storage, while the uncommitted updates from the failed transaction were completely removed.

```sql
-- 4.1 Verify that the committed update to Chidi Okonkwo's record remains permanent
SELECT driver_id, first_name || ' ' || last_name AS driver_name, availability_status 
FROM drivers 
WHERE driver_id = '2b123acd-30a1-4f72-92ff-774eb3b9e2b4';

-- 4.2 Verify that the rolled-back trip record was completely discarded
SELECT COUNT(*) AS total_failed_trips_found 
FROM trips 
WHERE trip_id = '44444444-4444-4444-4444-444444444444';
```

#### Result
```text
              driver_id               |  driver_name   | availability_status 
──────────────────────────────────────+────────────────+─────────────────────
 2b123acd-30a1-4f72-92ff-774eb3b9e2b4 | Chidi Okonkwo  | UNAVAILABLE

 total_failed_trips_found 
──────────────────────────
                        0
```

*Explanation:* This audit confirms the transaction safety guarantees: Chidi Okonkwo's status remains permanently saved as `UNAVAILABLE`, while the malformed trip log was rejected, leaving zero rows in the system database.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Two-Session Concurrency and Locking

This practical exercise evaluates how the database engine handles high-concurrency race conditions using **two parallel database sessions (Session 1 and Session 2)** running simultaneously at the default `READ COMMITTED` isolation level.

### Operational Scenario
Two separate drivers concurrently attempt to claim the identical requested cargo trip (`22222222-2222-2222-2222-222222222222`). This exercise proves how row-level locks protect the platform against a **Lost Update** anomaly, ensuring a delivery assignment is never double-allocated.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

### Step 1: Baseline Record Verification
Before opening parallel transaction blocks, a query is executed to verify the starting state of the target trip record.

```sql
-- Executed in either session to establish the starting state
SELECT trip_id, driver_id, trip_status 
FROM trips 
WHERE trip_id = '22222222-2222-2222-2222-222222222222';
```

#### Result
```text
               trip_id                | driver_id | trip_status 
──────────────────────────────────────+───────────+─────────────
 22222222-2222-2222-2222-222222222222 | NULL      | REQUESTED
```

*Explanation:* The target trip is currently unassigned (`driver_id IS NULL`) and in a `REQUESTED` status, making it open for courier acquisition.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

### Step 2: The Parallel Execution Timeline
Follow this explicit sequence step-by-step across two separate command-line terminal windows (`psql` sessions) to observe the locking behavior.

#### Timeline Step 2.1: Session 1 Opens a Transaction and Locks the Target Row
Driver 1 (Session 1) selects the trip and applies an explicit pessimistic row-level lock using the `FOR UPDATE` clause.

```sql
-- SESSION 1 Terminal Window
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT trip_id, trip_status 
FROM trips 
WHERE trip_id = '22222222-2222-2222-2222-222222222222' 
FOR UPDATE;
```

#### Result (Session 1)
```text
BEGIN
               trip_id                | trip_status 
──────────────────────────────────────+─────────────
 22222222-2222-2222-2222-222222222222 | REQUESTED
```

*Explanation:* Session 1 successfully acquires a row-level write lock (`ExclusiveLock`) on this specific trip record.

#### Timeline Step 2.2: Session 2 Attempts to Claim the Locked Row (The Block)
Driver 2 (Session 2) tries to claim the identical trip record while Session 1's transaction remains uncommitted.

```sql
-- SESSION 2 Terminal Window
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT trip_id, trip_status 
FROM trips 
WHERE trip_id = '22222222-2222-2222-2222-222222222222' 
FOR UPDATE;
```

#### Result (Session 2)
```text
BEGIN
... [The terminal prompt freezes instantly; cursor blinks on a blank line, waiting]
```

*Explanation:* Because Session 1 holds an active write lock, **Session 2 is instantly forced into a blocked state**. The database engine suspends Session 2's execution thread, protecting the row from data modification until Session 1 completes.

#### Timeline Step 2.3: Session 1 Updates the Status and Commits
Session 1 assigns the trip to driver Tunde Balogun (`3077e208-e9e2-4a31-a67a-c403af0a5472`) and releases the lock via a `COMMIT`.

```sql
-- SESSION 1 Terminal Window
UPDATE trips 
SET driver_id = '3077e208-e9e2-4a31-a67a-c403af0a5472', 
    trip_status = 'ACCEPTED' 
WHERE trip_id = '22222222-2222-2222-2222-222222222222';

COMMIT;
```

#### Result (Session 1)
```text
UPDATE 1
COMMIT
```

*Explanation:* Session 1 commits successfully. The moment `COMMIT` executes, Session 1's row lock is officially dropped.

#### Timeline Step 2.4: Session 2 Awakes and Reads the Committed State
The exact millisecond Session 1 commits, **Session 2 instantly unfreezes** and displays its query output. Under the rules of `READ COMMITTED`, Session 2 re-evaluates the row and reads the newly committed data state.

```text
-- SESSION 2 Terminal Window (Automatically unblocks and outputs right now)
               trip_id                | trip_status 
──────────────────────────────────────+─────────────
 22222222-2222-2222-2222-222222222222 | ACCEPTED
```

*Explanation:* Session 2 awakens and detects that the trip status has changed to `ACCEPTED`. Driver 2's application logic can now see the trip is unavailable, safely aborting their attempt. Session 2 concludes cleanly by closing its block:

```sql
-- SESSION 2 Terminal Window
ROLLBACK; -- Bypasses further changes since the trip is captured
```

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>


### Step 3: Post-Concurrency Final System Audit
To prove that data integrity was maintained across the parallel runtime layers, run a final validation lookup query.

```sql
-- Executed in either terminal window
SELECT trip_id, driver_id, trip_status 
FROM trips 
WHERE trip_id = '22222222-2222-2222-2222-222222222222';
```

#### Result
```text
               trip_id                |              driver_id               | trip_status 
──────────────────────────────────────+──────────────────────────────────────+─────────────
 22222222-2222-2222-2222-222222222222 | 3077e208-e9e2-4a31-a67a-c403af0a5472 | ACCEPTED
```

*Explanation:* The final check proves that **Driver 1 (Tunde Balogun) remains safely assigned to the trip**. The transaction locks successfully isolated the overlapping update attempts, preventing data overwrites and eliminating any chance of a double-allocation anomaly.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Test Results

- [Commit and rollback SQL](Yusuf_Olalekan_301905721_P3_Transactions.sql)
- [Two-Session Concurrency and Locking](Yusuf_Olalekan_301905721_P3_Concurrency.sql)
- [Screenshots](screenshots/)


---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>


Reference: 
- [PostgreSQL 16 — Transactions](https://www.postgresql.org/docs/16/tutorial-transactions.html)
- [PostgreSQL 16 — Transaction Isolation](https://www.postgresql.org/docs/16/transaction-iso.html)