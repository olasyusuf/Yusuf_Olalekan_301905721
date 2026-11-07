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

## Entity Relationship Diagram

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


---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>
