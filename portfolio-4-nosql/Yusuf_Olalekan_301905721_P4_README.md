[Home](../Yusuf_Olalekan_301905721_README.md)
<div align="center">
  <br>
  <h1>Portfolio 4 NoSQL and Advanced Data Models</h1>
</div>


<br />

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Document model](#document-model)
- [Implementation and results](#implementation-and-results)
- [Why MongoDB fits](#why-mongodb-fits)
- [Files](#files)


<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Document model

The MongoDB implementation uses a single database (`cargo_ride_portfolio`) and one collection (`delivery_events`) to store operational logistics activity logs. These documents are separate NoSQL examples modelled after the ride-hailing domain identifiers rather than exported SQL rows.

Each document shares top-level tracking fields (`_id`, `event_type`, `occurred_at`, `trip_ref`), an embedded `actor` sub-document, and a flexible `details` object whose fields adapt to the event type (`DISPATCH_ASSIGNED` or `DELIVERY_COMPLETED`).

### Document Model Overview (`delivery_events` Collection)

* **Database Name:** `cargo_ride_portfolio`
* **Collection Name:** `delivery_events`

| Field | Type | Description |
| :--- | :--- | :--- |
| `_id` | String | Unique fixed event identifier (e.g., `"EVT-2026-1108-001"`). |
| `event_type` | String | Event category: `"DISPATCH_ASSIGNED"` or `"DELIVERY_COMPLETED"`. |
| `occurred_at` | Date | Fixed ISO-8601 timestamp when the activity occurred. |
| `trip_ref` | String | Reference ID linking to the trip (e.g., `"11111111-1111-1111-1111-111111111111"`). |
| `actor` | Object | Embedded summary of the driver or rider involved in the event. |
| `details` | Object | Polymorphic sub-document that changes structure based on `event_type`. |

### Example Document (`DELIVERY_COMPLETED`)

```json
{
  "_id": "EVT-2026-1108-002",
  "event_type": "DELIVERY_COMPLETED",
  "occurred_at": "2026-11-08T08:45:00Z",
  "trip_ref": "11111111-1111-1111-1111-111111111111",
  "actor": {
    "driver_license": "DRV-NGA-99218-A",
    "rider_account": "ACC-RIDER-001"
  },
  "details": {
    "cargo_weight_kg": 15.5,
    "settled_fare": 4500.00,
    "payment_status": "SETTLED",
    "recipient_verified": true
  }
}
```

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Implementation and results

The database runs locally on Windows using **MongoDB Community Server 9.0.8** and **MongoDB Shell (`mongosh`) 2.14.2** at `127.0.0.1:27017` with access kept strictly local.

1. **Database Selection and Empty Check:** Switched to `cargo_ride_portfolio` and ran `db.delivery_events.countDocuments()`, which returned `0` to confirm an empty starting state.
2. **Batch Insertion:** Executed `insertMany()` with four fixed-date event documents (`EVT-2026-1108-001` through `EVT-2026-1109-004`). MongoDB returned `acknowledged: true` with all four string `_id` keys confirmed.
3. **Total Count Query:** Running `db.delivery_events.countDocuments()` returned `4`, verifying that all documents were persisted.
4. **Ordered History Query:** Filtering by `trip_ref: "11111111-1111-1111-1111-111111111111"` and sorting ascending by `occurred_at` returned `EVT-2026-1108-001` (`DISPATCH_ASSIGNED` at `07:55:00.000Z`) followed by `EVT-2026-1108-002` (`DELIVERY_COMPLETED` at `08:45:00.000Z`).
5. **Nested-Field Filter Query:** Querying `event_type: "DELIVERY_COMPLETED"` with `"details.cargo_weight_kg": { $gt: 10 }` matched one document (`EVT-2026-1108-002`) with `cargo_weight_kg: 15.5` and `settled_fare: 4500`.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Why MongoDB fits

* **Suitability for Variable Event Logs:** Logistics lifecycle events carry different attributes depending on the stage—dispatch assignments record vehicle classes and fragile handling notes, whereas delivery completions record settled fares and recipient verification. MongoDB's flexible document schema stores both event types cleanly in one collection without sparse `NULL` columns or extra join tables.
* **Key Limitation:** MongoDB does not enforce cross-collection foreign key constraints natively at the storage layer. Referential checks—such as verifying that `driver_license` (`DRV-NGA-99218-A`) or `trip_ref` actually exists before logging an event—must be handled by application logic or kept inside the relational PostgreSQL database.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Files

* [Setup and connection check](./Yusuf_Olalekan_301905721_P4_Setup.md)
* [MongoDB Script](./Yusuf_Olalekan_301905721_P4_MongoDB.js) — Contains database selection, `insertMany` batch load, and verification queries.
* [Query Execution Evidence 1](./screenshots/Yusuf_Olalekan_301905721_P4_queries_1.png), [2](./screenshots/Yusuf_Olalekan_301905721_P4_queries_2.png), [3](./screenshots/Yusuf_Olalekan_301905721_P4_queries_3.png) — Terminal screenshot capturing the insert confirmation and three verification query outputs.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>


## References

* MongoDB, Inc. (2026). *MongoDB Shell (`mongosh`) Documentation*. Available at: https://www.mongodb.com/docs/mongodb-shell/
* MongoDB, Inc. (2026). *Data Modeling: Polymorphic Pattern*. Available at: https://mongodb.com
