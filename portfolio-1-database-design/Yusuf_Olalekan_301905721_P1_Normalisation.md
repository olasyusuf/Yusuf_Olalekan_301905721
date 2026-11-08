<div style="display: flex; gap: 1rem;">
  <div  style="flex: 1;">

   [Home](../Yusuf_Olalekan_301905721_README.md)
 </div>
<div style="flex: 1;">

   <div align="right">

  [ Back ](./Yusuf_Olalekan_301905721_P1_README.md) 
   </div>
  </div>
</div>


<br />

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
- [Starting trip list](#starting-trip-list)
- [1NF: One value per cell](#1nf-one-value-per-cell)
- [2NF: Details depend on the whole key](#2nf-details-depend-on-the-whole-key)
- [3NF: Details depend only on the key](#3nf-details-depend-only-on-the-key)
- [Unified Identification Architecture](#unified-identification-architecture)


<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>


# Introduction

Normalisation separates information into related tables to reduce repeated details and avoid inconsistent updates. The same three logistics records are used below. Only the fields needed to explain the changes are shown for readability; the final database layout retains the remaining fields from the design document. Timestamps are shortened for clarity. Names and emails are fictional.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Starting trip list

| **rider_id** | **first_name** | **email** | **Requested Trips** |
| :--- | :--- | :--- | :--- |
| 1001 | Alice Ama | alice@example.com | Trip A: driver 501, Chidi O., plate ABC-123, center C01, Abuja Hub, weight 15kg, express, pickup 2026-11-01; Trip B: driver 502, Amina Y., plate XYZ-789, center C01, Abuja Hub, weight 5kg, standard, pickup 2026-11-01 |
| 1002 | Bob Bello | bob@example.com | Trip C: driver 501, Chidi O., plate ABC-123, center C01, Abuja Hub, weight 50kg, fragile, pickup 2026-11-05 |

The first row contains a repeated list of two completely separate trips inside one cell. Finding an individual trip record, updating its status, or logging a parcel delivery completion timestamp is highly awkward.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## 1NF: One value per cell

First Normal Form (1NF) requires that every cell contains exactly one single, indivisible value, eliminating the repeated list.

| **driver_id** | **pickup_timestamp** | **rider_id** | **first_name** | **email** | **driver_name** | **license_plate** | **center_code** | **center_name** | **cargo_weight_kg** | **delivery_type** |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 501 | 2026-11-01 08:00 | 1001 | Alice Ama | alice@example.com | Chidi O. | ABC-123 | C01 | Abuja Hub | 15.00 | EXPRESS |
| 502 | 2026-11-01 10:00 | 1001 | Alice Ama | alice@example.com | Amina Y. | XYZ-789 | C01 | Abuja Hub | 5.00 | STANDARD |
| 501 | 2026-11-05 14:00 | 1002 | Bob Bello | bob@example.com | Chidi O. | ABC-123 | C01 | Abuja Hub | 50.00 | FRAGILE |

For this combined temporary example, the key is the combination of (`driver_id`, `pickup_timestamp`). Both values together identify one specific trip, assuming an individual driver cannot start two separate deliveries at the exact same instant. `driver_id` alone is not enough because driver 501 appears twice.

While the rows are now in 1NF, several structural issues remain. The rider details, driver names, license plates, and dispatch center descriptions are repeatedly typed across rows. If a rider changes their email address, or if a dispatch center name needs a spelling correction, the system must update multiple rows, creating a major risk of inconsistent updates.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## 2NF: Details depend on the whole key

Second Normal Form (2NF) includes 1NF and requires that every non-key field must depend on the *whole* combined primary key. A functional dependency where a field depends on only a partial piece of a combined key violates 2NF and must be split into a separate table.

In the 1NF table, the key is (`driver_id`, `pickup_timestamp`). The attributes `driver_name`, `license_plate`, `center_code`, and `center_name` depend entirely on `driver_id` alone. They have no relationship to the `pickup_timestamp`. Because these fields depend on only part of the combined key, they violate 2NF.

To achieve 2NF, these fields move into a separate driver registry table where `driver_id` acts as the single primary key. The remaining attributes (`cargo_weight_kg`, `delivery_type`, and `rider_id` fields) stay in the trip table because they require the whole combined key to identify a specific parcel assignment.

**Driver Registry Table** (Key: driver_id)

| **driver_id** | **driver_name** | **license_plate** | **center_code** | **center_name** |
| :--- | :--- | :--- | :--- | :--- |
| 501 | Chidi O. | ABC-123 | C01 | Abuja Hub |
| 502 | Amina Y. | XYZ-789 | C01 | Abuja Hub |

**Trip Table** (Key: driver_id, pickup_timestamp)

| **driver_id** | **pickup_timestamp** | **rider_id** | **first_name** | **email** | **cargo_weight_kg** | **delivery_type** |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 501 | 2026-11-01 08:00 | 1001 | Alice Ama | alice@example.com | 15.00 | EXPRESS |
| 502 | 2026-11-01 10:00 | 1001 | Alice Ama | alice@example.com | 5.00 | STANDARD |
| 501 | 2026-11-05 14:00 | 1002 | Bob Bello | bob@example.com | 50.00 | FRAGILE |

The tables are now in 2NF, but transitive dependencies still exist. In the Driver Registry table, the dispatch `center_name` depends directly on `center_code`, which is a non-key field. In the Trip table, `first_name` and `email` depend directly on `rider_id`.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## 3NF: Details depend only on the key

Third Normal Form (3NF) includes 2NF and requires that non-key fields must depend only on the primary key, removing dependencies between non-key attributes.

To reach 3NF, the fields are separated into distinct tables. `center_name` moves to a `dispatch_center` table, linked back via `center_code`. Rider details move to a `rider` table, linked via `rider_id`. The vehicle details (`license_plate`) are isolated into a `vehicle` table. This removes all data repetition and update conflicts.

The individual generated identification keys (IDs) keep the separate tables safely linked together as foreign keys.

**dispatch_center** (Key: center_id)

| **center_id (PK)** | **operational_code (UK)** | **physical_location** |
| :--- | :--- | :--- |
| C01 | C01 | Abuja Hub |

**vehicle** (Key: vehicle_id)

| **vehicle_id (PK)** | **license_plate (UK)** |
| :--- | :--- |
| V101 | ABC-123 |
| V102 | XYZ-789 |

**driver** (Key: driver_id)

| **driver_id (PK)** | **first_name** | **last_name** | **dispatch_center_id (FK)** | **current_vehicle_id (FK)** |
| :--- | :--- | :--- | :--- | :--- |
| 501 | Chidi | Okonkwo | C01 | V101 |
| 502 | Amina | Yusuf | C01 | V102 |

**rider** (Key: rider_id)

| **rider_id (PK)** | **first_name** | **last_name** | **email (UK)** |
| :--- | :--- | :--- | :--- |
| 1001 | Alice | Ama | alice@example.com |
| 1002 | Bob | Bello | bob@example.com |

**trip** (Key: trip_id)

| **trip_id (PK)** | **rider_id (FK)** | **driver_id (FK)** | **pickup_timestamp** | **cargo_weight_kg** | **delivery_type** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| T801 | 1001 | 501 | 2026-11-01 08:00 | 15.00 | EXPRESS |
| T802 | 1001 | 502 | 2026-11-01 10:00 | 5.00 | STANDARD |
| T803 | 1002 | 501 | 2026-11-05 14:00 | 50.00 | FRAGILE |

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Unified Identification Architecture

The final design replaces the temporary combined example keys (`driver_id`, `pickup_timestamp`) with automatically generated, system-wide unique identifiers (`trip_id`).

An automatically generated surrogate ID alone does not prove a table is in 3NF format. Rather, the layout achieves 3NF because every single remaining non-key attribute in the final `trip` table—such as the actual package `cargo_weight_kg` or the specific `pickup_timestamp`—describes a fact that depends solely and directly on that unique `trip_id`.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>