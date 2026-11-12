[Home](../Yusuf_Olalekan_301905721_README.md)
<div align="center">
  <br>
  <h1>Portfolio 5 Distributed and Cloud Database</h1>
</div>


<br />

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Current setup](#current-setup)
- [Proposed replication](#proposed-replication)
- [Failure and consistency](#failure-and-consistency)
- [Sharding and cloud deployment](#sharding-and-cloud-deployment)


<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Current setup
Based on the project files, the current implementation runs locally on Windows using standalone instances. PostgreSQL 15+ hosts the relational `cargo_ride_portfolio` database, while MongoDB Community Server 9.0.8 runs locally at `127.0.0.1:27017` to store `delivery_events`. Both databases run on a single host without distributed clusters, replication, or sharding configured. Exact production topology details are not verified beyond this local setup.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Proposed replication
To improve availability for `delivery_events` logs, a future production deployment could use a three-member [MongoDB replica set](https://mongodb.com). All three members hold full copies of the data and vote in elections across separate failure zones. When the system logs a `DISPATCH_ASSIGNED` event, the primary receives the write and replicates it asynchronously to the secondaries.

| Member | Starting role | Location |
| :--- | :--- | :--- |
| Member 1 | Primary | Availability Zone A (Local Primary Host) |
| Member 2 | Secondary | Availability Zone B (Regional Backup Host 1) |
| Member 3 | Secondary | Availability Zone C (Regional Backup Host 2) |

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Failure and consistency
If the primary node fails, the remaining two secondaries hold a [replica set election](https://mongodb.com) and promote one secondary to become the new primary. During this election, the system experiences a brief write interruption where new `DELIVERY_COMPLETED` events cannot be recorded until a new primary is elected. If two members fail simultaneously, no reachable majority exists; the surviving node steps down to read-only, blocking all writes to prevent split-brain conflicts.

Using a `"majority"` [write concern](https://mongodb.com) ensures an event is acknowledged only after most voting members persist it, protecting against data loss. However, reading from secondaries can expose stale data due to replication lag. Consequently, core operational decisions—such as enforcing driver availability or preventing double bookings—must remain with the authoritative PostgreSQL database.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## Sharding and cloud deployment
Unlike replication, which copies the same dataset across nodes for fault tolerance, [sharding](https://mongodb.com) splits large datasets across multiple machines to scale write capacity. Because our current `delivery_events` collection contains only four documents, sharding is unnecessary and would add unneeded operational complexity.

Moving to a managed cloud service like MongoDB Atlas would require enabling user authentication, TLS network encryption, encryption at rest, and IP access lists to restrict public exposure. Managed clusters also provide automated [cloud backup and restore](https://mongodb.com) capabilities for disaster recovery. However, cloud deployments introduce recurring subscription costs and network latency. A key architectural limitation is that MongoDB replication only copies MongoDB collections; it does not replicate PostgreSQL tables or automatically synchronise data between the two separate database engines.

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>

## References
* MongoDB, Inc. (2026). *Replication*. Available at: https://mongodb.com
* MongoDB, Inc. (2026). *Replica Set Elections*. Available at: https://mongodb.com
* MongoDB, Inc. (2026). *Write Concern*. Available at: https://mongodb.com
* MongoDB, Inc. (2026). *Sharding*. Available at: https://mongodb.com
* MongoDB, Inc. (2026). *Back Up, Restore, and Archive Clusters*. Available at: https://mongodb.com
