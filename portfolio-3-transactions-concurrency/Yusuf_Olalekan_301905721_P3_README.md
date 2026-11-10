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

#### Expected Result
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

#### Expected Result
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

#### Expected Result
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

#### Expected Result
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


## Files

- [Commit and rollback SQL](Yusuf_Olalekan_301905721_P3_Transactions.sql)
- [Screenshots](screenshots/)


---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>


Reference: 
- [PostgreSQL 16 — Transactions](https://www.postgresql.org/docs/16/tutorial-transactions.html)
- [PostgreSQL 16 — Transaction Isolation](https://www.postgresql.org/docs/16/transaction-iso.html)