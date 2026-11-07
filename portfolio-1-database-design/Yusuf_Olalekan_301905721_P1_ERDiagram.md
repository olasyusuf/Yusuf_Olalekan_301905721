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
- [Ride-Hailing & Logistics System ER Diagram](#ride-hailing--logistics-system-er-diagram)
- [Key and Symbol Explanations](#key-and-symbol-explanations)
- [Optional Fields](#optional-fields)


<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Ride-Hailing & Logistics System ER Diagram

<!-- ![Ride-Hailing & Logistics System ER Diagram](./screenshots/Yusuf_Olalekan_301905721_P1_ERDiagram.png) -->

```mermaid
erDiagram
    direction LR
    dispatch_center {
        UUID center_id PK
        VARCHAR operational_code UK
        VARCHAR physical_location
    }
    vehicle {
        UUID vehicle_id PK
        VARCHAR license_plate UK
        VARCHAR cargo_volume_class
        DATE last_inspection_date
    }
    driver {
        UUID driver_id PK
        VARCHAR first_name
        VARCHAR last_name
        VARCHAR license_number UK
        UUID dispatch_center_id FK
        UUID current_vehicle_id FK
        VARCHAR availability_status
    }
    rider {
        UUID rider_id PK
        VARCHAR account_number UK
        VARCHAR first_name
        VARCHAR last_name
        VARCHAR email UK
        VARCHAR phone_number UK
    }
    trip {
        UUID trip_id PK
        UUID rider_id FK
        UUID driver_id FK
        NUMERIC cargo_weight_kg
        VARCHAR delivery_type
        VARCHAR trip_status
        TIMESTAMPTZ pickup_timestamp
        TIMESTAMPTZ dropoff_timestamp
        NUMERIC calculated_fare
    }
    payment {
        UUID payment_id PK
        UUID trip_id FK
        NUMERIC transaction_amount
        VARCHAR payment_status
        TIMESTAMPTZ settled_at
    }

    dispatch_center ||--o{ driver : "manages"
    vehicle |o--|| driver : "assigned_to"
    rider ||--o{ trip : "requests"
    driver |o--o{ trip : "executes"
    trip ||--o| payment : "settles"

```

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>



## Key and Symbol Explanations

- PK (Primary Key): A field that Uniquely identifies a single record within a table. For example, center_id uniquely identifies a specific corporate dispatch center.

- FK (Foreign Key): A field that establishes a link between tables by referencing the primary key of another table. For example, the rider_id in the trip table connects each trip to the specific customer record who requested it.

- UK (Unique Key): A constraint that ensures values in a field are distinct across the table. For example, license_plate prevents multiple vehicles from sharing the same registration string.

- Relationship Symbols: The diagram uses line ends to show cardinality constraints. The line || represents exactly one, |o represents zero or one, and o{ represents zero or many records. For instance, the notation between rider and trip indicates that exactly one rider (||) can request zero or more historical trips (o{).

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>


## Optional Fields

- driver.current_vehicle_id: This field is optional because a driver can be off-duty or unassigned to a fleet asset.

- trip.driver_id: This remains empty when a request is initialized and is only filled once a courier accepts the dispatch.

- trip.dropoff_timestamp: This field is optional and remains null until the driver successfully completes the delivery.
- payment.settled_at: This remains empty while the transaction status is pending or failed.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

