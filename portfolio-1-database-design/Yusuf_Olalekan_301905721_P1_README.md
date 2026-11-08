[Home](../Yusuf_Olalekan_301905721_README.md)
<div align="center">
  <br>
  <h1>Portfolio 1 Database Design and Modelling</h1>
</div>


<br />

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Case study](#case-study)
- [Users](#users)
- [Main operations](#main-operations)
- [Business rules](#business-rules)
- [Scope](#scope)
- [Implementation](#implementation)
- [Test results](#test-results)


<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Case study
A regional ride-hailing and logistics system tracks riders, corporate drivers, fleet vehicles, regional dispatch centers, and delivery trip history. The platform manages on-demand vehicle assignments, real-time cargo logistics tracking, and base fare generation. Corporate operators maintain infrastructure records, monitor driver utility states, and audit completed fulfillment logs.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Users
Riders request transport or dispatch cargo, track shipment progress, and execute payments. Drivers update their availability status, accept matching dispatch assignments, and complete assigned trips. Dispatch center operators manage localized driver profiles, add fleet vehicles, and audit regional logistics summaries.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Main operations
Register a new rider profile; provision a corporate dispatch center node; add a fleet vehicle with cargo classifications; initialize an on-demand delivery request; allocate an available regional driver to a cargo trip; record a delivery completion timestamp; view active localized dispatch centers, individual rider shipment histories, and unfulfilled logistics requests.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Business rules
1. Each rider must have a unique account number, verified email address, and distinct phone number.
2. Each dispatch center must have a unique operational code, a verified physical location, and complete administrative records.
3. Each registered vehicle must possess a unique license plate number and be explicitly classified by cargo volume limits.
4. Each driver must have a unique state license number and be assigned to exactly one regional dispatch center.
5. Each cargo item must have a documented weight value and a specified delivery type of express, standard, or fragile.
6. A driver can participate in at most one active delivery trip at any specific time.
7. A driver must be in an available status to accept a cargo assignment; accepting a dispatch automatically locks their status to unavailable.
8. The delivery dropoff timestamp must be later than or equal to the initial pickup timestamp.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Scope
The database is bounded to the operational management of one localized metropolitan city across distinct regional corporate dispatch centers using fictional cargo loads and transit histories. Dynamic map routing matrices, variable surge pricing models, cash on delivery (COD) floating balances, driver commission payouts, and security user authentication frameworks are excluded from this implementation.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Design and implementation files

| File / Component | Contents & Implementation Details |
| :--- | :--- |
| [ **Design** ](./Yusuf_Olalekan_301905721_P1_Design.md) | Define the data structure by mapping out entities, attributes, key identifiers, relationships, and business rules. |
| [ **ER diagram** ](./Yusuf_Olalekan_301905721_P1_ERDiagram.md) | Visual mapping of the four tables and their relationships. |
| [**Normalisation**](./Yusuf_Olalekan_301905721_P1_Normalisation.md) | Database Normalization Case Study: Tracking Data Evolution from 1NF through 3NF. |
| [**Schema**](./Yusuf_Olalekan_301905721_P1_Schema.sql) | PostgreSQL table definitions, keys, checks, and index. |
| [**Sample records**](./Yusuf_Olalekan_301905721_P1_SampleData.sql) | Valid baseline test dataset. |
| [**Constraint tests**](./Yusuf_Olalekan_301905721_P1_ConstraintTests.sql) | Failure testing suite and summary audit. |
| [**Evidence**](./Yusuf_Olalekan_301905721_P1_Evidence.md) | Documented links to execution screenshots stored in `screenshots/`. |

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Implementation
The database runs on PostgreSQL 15+ in a localized computing cluster. Its name is `cargo_ride_portfolio`. The schema creates `dispatch_centers`, `vehicles`, `drivers`, `riders`, `trips`, and `payments`. Each has an automatically generated primary key using secure UUID data types. Foreign keys link drivers to dispatch centers, trips to riders and drivers, and payments to trips.

Operational codes, license plates, driver licenses, rider account numbers, emails, phone numbers, and payment trip links are unique. Trip date checks prevent a dropoff timestamp before a pickup timestamp. The `uq_idx_active_driver_trip` partial unique index allows at most one active delivery assignment per driver while retaining completed transactional histories.

The schema and sample statements were executed in order and committed. The invalid inserts were then run separately, outside a transaction block, to check each rule independently.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Test results
All eight invalid inserts were rejected by the intended rule: a missing dispatch center physical location, missing trip cargo weight, repeated operational code, repeated rider email, duplicated vehicle assignment for a single driver, nonexistent dispatch center link for a driver, nonexistent trip link for a payment, invalid vehicle cargo volume class string, negative cargo weight value, dropoff timeline sequence violation, and a second active assignment for an occupied driver. The terminal logs show the corresponding errors.

After the tests, the database contains 2 dispatch centers, 3 fleet vehicles, 3 drivers, 3 riders, 3 trips, and 1 processed payment ledger entry. One trip is completed with a settled payment, one is requested, and one remains active in transit. The failed inserts added no rows.

These tests cover the listed constraints. The real-time driver allocation and automatic availability status update workflow still require procedural transaction logic and concurrency testing in Portfolio 3; the static table definitions alone do not enforce it.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

Reference: [PostgreSQL 16 constraints](https://www.postgresql.org/docs/16/ddl-constraints.html).