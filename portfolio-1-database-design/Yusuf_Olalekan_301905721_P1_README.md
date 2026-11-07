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
| [ **Design** ](./Yusuf_Olalekan_301905721_P1_Design.md) | Entities, attributes, keys, relationships, and business rules. |
| **ER diagram** | Visual mapping of the four tables and their relationships. |
| **Normalisation** | Example tables demonstrating the progression of 1NF, 2NF, and 3NF. |
| **Schema** | PostgreSQL table definitions, keys, date checks, and open-loan index. |
| **Sample records** | Fictional seed data for members, a book, physical copies, and loans. |
| **Constraint tests** | Six deliberately invalid inserts alongside the final count query. |
| **Evidence** | Documented links to execution screenshots stored in `screenshots/`. |

---

<br />

<div align="right">

  [ [↑ to top ↑](#table-of-contents) ]
</div>