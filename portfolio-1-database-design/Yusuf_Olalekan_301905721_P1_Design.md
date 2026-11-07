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

<div align="center">
  <br>
  <h1>Ride-Hailing & Logistics Database Design</h1>
</div>


<br />

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Entities](#entities)
- [Attributes and keys](#attributes-and-keys)
- [Relationships](#relationships)
- [Business rules and constraints](#business-rules-and-constraints)


<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Entities
The database stores operational and structural data using six distinct entities to support all core workflows:

*   **dispatch_center**: A corporate hub managing regional operations and assets.
*   **vehicle**: A physical fleet transport asset classified by its shipping capacity.
*   **driver**: A corporate contractor registered to transport passengers and cargo.
*   **rider**: A registered platform customer who requests transit or cargo shipments.
*   **trip**: A distinct on-demand assignment representing a ride or a freight delivery.
*   **payment**: A transactional record storing the specific settlement parameters for a completed trip.

I chose to separate the `trip` and `payment` entities into a one-to-one relationship. This isolates the volatile logistics tracking states from the permanent financial auditing data, ensuring that payment details are only generated upon successful trip completion.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Attributes and keys
The database uses automatically generated UUID fields for all surrogate primary keys to secure distributed identifiers.

| **Entity** | **Attributes and PostgreSQL Types** | **Keys and Constraints** |
| :--- | :--- | :--- |
| **dispatch_center** | center_id UUID; operational_code VARCHAR(30); physical_location VARCHAR(255) | PK: center_id. Unique: operational_code. All values are required. |
| **vehicle** | vehicle_id UUID; license_plate VARCHAR(20); cargo_volume_class VARCHAR(30); last_inspection_date DATE | PK: vehicle_id. Unique: license_plate. All values are required. |
| **driver** | driver_id UUID; first_name VARCHAR(50); last_name VARCHAR(50); license_number VARCHAR(50); dispatch_center_id UUID; current_vehicle_id UUID; availability_status VARCHAR(20) | PK: driver_id. FK: dispatch_center_id → dispatch_center.center_id. FK: current_vehicle_id → vehicle.vehicle_id. Unique: license_number, current_vehicle_id. All values required except current_vehicle_id. |
| **rider** | rider_id UUID; account_number VARCHAR(50); first_name VARCHAR(50); last_name VARCHAR(50); email VARCHAR(100); phone_number VARCHAR(20) | PK: rider_id. Unique: account_number, email, phone_number. All values are required. |
| **trip** | trip_id UUID; rider_id UUID; driver_id UUID; cargo_weight_kg NUMERIC(8,2); delivery_type VARCHAR(20); trip_status VARCHAR(20); pickup_timestamp TIMESTAMPTZ; dropoff_timestamp TIMESTAMPTZ; calculated_fare NUMERIC(10,2) | PK: trip_id. FK: rider_id → rider.rider_id. FK: driver_id → driver.driver_id. All values required except driver_id and dropoff_timestamp. |
| **payment** | payment_id UUID; trip_id UUID; transaction_amount NUMERIC(10,2); payment_status VARCHAR(20); settled_at TIMESTAMPTZ | PK: payment_id. FK: trip_id → trip.trip_id. Unique: trip_id. All values are required except settled_at. |

The `driver_id` and `dropoff_timestamp` in a trip remain empty when a rider first logs a request. The system sets the driver relationship when an available courier accepts the dispatch and records the dropoff time upon arrival.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Relationships
*   **dispatch_center → driver (One-to-Many):** A dispatch center manages zero or more drivers; each driver belongs to exactly one dispatch center.
*   **vehicle → driver (One-to-One):** A vehicle is assigned to zero or one active driver; an active driver is assigned to exactly one vehicle.
*   **rider → trip (One-to-Many):** A rider requests zero or more trips; each trip belongs to exactly one rider.
*   **driver → trip (One-to-Many over time):** An individual driver executes zero or more historical trips; each assigned trip belongs to exactly one driver.
*   **trip → payment (One-to-One):** A trip has zero or one payment record; a payment refers to exactly one unique trip.

A driver can handle multiple consecutive trips over a shift, creating many historical logs. However, concurrency constraints ensure that a driver can have at most one active trip at any single moment.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Business rules and constraints
*   **Rules 1 and 2:** Unique constraints on `rider.account_number`, `rider.email`, `rider.phone_number`, and `dispatch_center.operational_code` prevent duplicate entity registrations.
*   **Rules 3 and 5:** A check constraint verifies that `vehicle.cargo_volume_class` matches a specific value, while `trip.delivery_type` is validated to contain only 'EXPRESS', 'STANDARD', or 'FRAGILE'.
*   **Rules 2 and 4:** A database foreign key restricts `driver.dispatch_center_id` to values that match existing records in the dispatch center table.
*   **Rules 6 and 7:** A partial unique index on the trip table (`CREATE UNIQUE INDEX ON trips (driver_id) WHERE trip_status = 'EN_ROUTE'`) ensures a driver has at most one active delivery. A database key alone cannot verify if a driver is available; this requires an atomic transaction check to ensure a driver's `availability_status` is 'AVAILABLE' before assigning a trip.
*   **Rules 8:** A database table constraint (`CHECK (dropoff_timestamp >= pickup_timestamp)`) enforces the delivery time sequence.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>
