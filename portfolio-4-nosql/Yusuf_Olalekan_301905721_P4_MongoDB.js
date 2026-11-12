// 1. Select the isolated database
use cargo_ride_portfolio;

// 2. Verify the collection is empty before inserting
db.delivery_events.countDocuments();

// 3. Insert four fictional operational events (two event types) in one batch
db.delivery_events.insertMany([
  {
    _id: "EVT-2026-1108-001",
    event_type: "DISPATCH_ASSIGNED",
    occurred_at: ISODate("2026-11-08T07:55:00Z"),
    trip_ref: "11111111-1111-1111-1111-111111111111",
    actor: {
      driver_license: "DRV-NGA-99218-A",
      driver_name: "Chidi Okonkwo",
      dispatch_center: "ABJ-CENTRAL"
    },
    details: {
      vehicle_plate: "ABJ-884-XA",
      cargo_volume_class: "HEAVY_FREIGHT",
      delivery_type: "EXPRESS"
    }
  },
  {
    _id: "EVT-2026-1108-002",
    event_type: "DELIVERY_COMPLETED",
    occurred_at: ISODate("2026-11-08T08:45:00Z"),
    trip_ref: "11111111-1111-1111-1111-111111111111",
    actor: {
      driver_license: "DRV-NGA-99218-A",
      rider_account: "ACC-RIDER-001"
    },
    details: {
      cargo_weight_kg: 15.5,
      settled_fare: 4500.00,
      payment_status: "SETTLED",
      recipient_verified: true
    }
  },
  {
    _id: "EVT-2026-1108-003",
    event_type: "DISPATCH_ASSIGNED",
    occurred_at: ISODate("2026-11-08T15:55:00Z"),
    trip_ref: "32323232-3232-3232-3232-323232323232",
    actor: {
      driver_license: "DRV-NGA-10492-B",
      driver_name: "Amina Yusuf",
      dispatch_center: "LOS-MAINLAND"
    },
    details: {
      vehicle_plate: "LOS-112-BY",
      cargo_volume_class: "LIGHT_COURIER",
      delivery_type: "FRAGILE",
      handling_note: "Keep upright; glass contents"
    }
  },
  {
    _id: "EVT-2026-1109-004",
    event_type: "DELIVERY_COMPLETED",
    occurred_at: ISODate("2026-11-09T10:15:00Z"),
    trip_ref: "44444444-4444-4444-4444-444444444444",
    actor: {
      driver_license: "DRV-NGA-55210-C",
      rider_account: "ACC-RIDER-002"
    },
    details: {
      cargo_weight_kg: 8.0,
      settled_fare: 1800.00,
      payment_status: "SETTLED",
      recipient_verified: true
    }
  }
]);

// --- SCREENSHOT CHECKPOINT: Run the three verification queries below ---

// Query 1: Total document count in the collection
db.delivery_events.countDocuments();

// Query 2: Ordered event history for one specific trip entity
db.delivery_events.find(
  { trip_ref: "11111111-1111-1111-1111-111111111111" },
  { _id: 1, event_type: 1, occurred_at: 1, "actor.driver_license": 1 }
).sort({ occurred_at: 1 });

// Query 3: Nested-field filter for completed deliveries over 10 kg
db.delivery_events.find(
  { event_type: "DELIVERY_COMPLETED", "details.cargo_weight_kg": { $gt: 10 } },
  { _id: 1, trip_ref: 1, "details.cargo_weight_kg": 1, "details.settled_fare": 1 }
);
