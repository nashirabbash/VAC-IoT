import { Elysia, t } from "elysia";
import { cors } from "@elysiajs/cors";
import { swagger } from "@elysiajs/swagger";
import { db } from "./db";

// --- therapy_sessions -------------------------------------------------

const sessionBody = t.Object({
  startDate: t.String(),
  endDate: t.String(),
  averagePressureMmHg: t.Number(),
  badgeLevel: t.Optional(t.String()),
});

function sessionApiShape(row: any) {
  return {
    id: row.id,
    sessionNumber: row.session_number,
    startDate: row.start_date,
    endDate: row.end_date,
    durationSeconds: row.duration_seconds,
    averagePressureMmHg: row.average_pressure_mmhg,
    badgeLevel: row.badge_level,
  };
}

// --- readings -----------------------------------------------------------
// Any monitoring device (ESP32 or otherwise) POSTs a live snapshot here.
// Shape mirrors NpwtDeviceData in the Flutter app, but this API is not
// tied to that app — any client that sends this JSON shape is accepted.

const readingBody = t.Object({
  timestamp: t.String(),
  isDeviceOn: t.Boolean(),
  isTherapyActive: t.Boolean(),
  connectionStatus: t.Union([
    t.Literal("online"),
    t.Literal("offline"),
    t.Literal("connecting"),
  ]),
  pressureValue: t.Number(),
  pressureStability: t.Union([
    t.Literal("stable"),
    t.Literal("unstable"),
    t.Literal("unknown"),
  ]),
  isPumpActive: t.Boolean(),
  pumpCumulativeSeconds: t.Integer(),
  pumpCurrentSessionSeconds: t.Integer(),
  canisterVolumeMl: t.Number(),
  isCanisterFull: t.Boolean(),
  canisterNeedsReplacement: t.Boolean(),
  activeAlarms: t.Array(
    t.Union([
      t.Literal("leakDetected"),
      t.Literal("pressureAbnormal"),
      t.Literal("pumpFailure"),
      t.Literal("systemError"),
    ])
  ),
  batteryLevel: t.Optional(t.Number()),
  isAdapterConnected: t.Boolean(),
  systemVoltage: t.Number(),
});

function readingApiShape(row: any) {
  return {
    id: row.id,
    timestamp: row.timestamp,
    isDeviceOn: !!row.is_device_on,
    isTherapyActive: !!row.is_therapy_active,
    connectionStatus: row.connection_status,
    pressureValue: row.pressure_value,
    pressureStability: row.pressure_stability,
    isPumpActive: !!row.is_pump_active,
    pumpCumulativeSeconds: row.pump_cumulative_seconds,
    pumpCurrentSessionSeconds: row.pump_current_session_seconds,
    canisterVolumeMl: row.canister_volume_ml,
    isCanisterFull: !!row.is_canister_full,
    canisterNeedsReplacement: !!row.canister_needs_replacement,
    activeAlarms: JSON.parse(row.active_alarms),
    batteryLevel: row.battery_level,
    isAdapterConnected: !!row.is_adapter_connected,
    systemVoltage: row.system_voltage,
  };
}

const app = new Elysia()
  .use(cors())
  .use(swagger({ path: "/swagger" }))
  .get("/", () => ({ status: "ok", service: "npwt-backend" }))

  // sessions
  .get("/sessions", () => {
    const rows = db
      .query("SELECT * FROM therapy_sessions ORDER BY start_date DESC")
      .all();
    return rows.map(sessionApiShape);
  })
  .get("/sessions/:id", ({ params, set }) => {
    const row = db
      .query("SELECT * FROM therapy_sessions WHERE id = ?")
      .get(params.id);
    if (!row) {
      set.status = 404;
      return { error: "session not found" };
    }
    return sessionApiShape(row);
  })
  .post(
    "/sessions",
    ({ body, set }) => {
      const start = new Date(body.startDate);
      const end = new Date(body.endDate);
      const durationSeconds = Math.max(
        0,
        Math.round((end.getTime() - start.getTime()) / 1000)
      );

      const { count } = db
        .query("SELECT COUNT(*) as count FROM therapy_sessions")
        .get() as { count: number };
      const sessionNumber = count + 1;

      const row = db
        .query(
          `INSERT INTO therapy_sessions
            (session_number, start_date, end_date, duration_seconds, average_pressure_mmhg, badge_level)
           VALUES (?, ?, ?, ?, ?, ?)
           RETURNING *`
        )
        .get(
          sessionNumber,
          body.startDate,
          body.endDate,
          durationSeconds,
          body.averagePressureMmHg,
          body.badgeLevel ?? null
        );

      set.status = 201;
      return sessionApiShape(row);
    },
    { body: sessionBody }
  )

  // readings
  .post(
    "/readings",
    ({ body, set }) => {
      const row = db
        .query(
          `INSERT INTO readings
            (timestamp, is_device_on, is_therapy_active, connection_status,
             pressure_value, pressure_stability, is_pump_active,
             pump_cumulative_seconds, pump_current_session_seconds,
             canister_volume_ml, is_canister_full, canister_needs_replacement,
             active_alarms, battery_level, is_adapter_connected, system_voltage)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
           RETURNING *`
        )
        .get(
          body.timestamp,
          body.isDeviceOn ? 1 : 0,
          body.isTherapyActive ? 1 : 0,
          body.connectionStatus,
          body.pressureValue,
          body.pressureStability,
          body.isPumpActive ? 1 : 0,
          body.pumpCumulativeSeconds,
          body.pumpCurrentSessionSeconds,
          body.canisterVolumeMl,
          body.isCanisterFull ? 1 : 0,
          body.canisterNeedsReplacement ? 1 : 0,
          JSON.stringify(body.activeAlarms),
          body.batteryLevel ?? null,
          body.isAdapterConnected ? 1 : 0,
          body.systemVoltage
        );

      set.status = 201;
      return readingApiShape(row);
    },
    { body: readingBody }
  )
  .get("/readings/latest", ({ set }) => {
    const row = db
      .query("SELECT * FROM readings ORDER BY id DESC LIMIT 1")
      .get();
    if (!row) {
      set.status = 404;
      return { error: "no readings yet" };
    }
    return readingApiShape(row);
  })
  .get("/readings", () => {
    const rows = db
      .query("SELECT * FROM readings ORDER BY id DESC LIMIT 50")
      .all();
    return rows.map(readingApiShape);
  })
  .listen(3000);

console.log(
  `NPWT backend listening at ${app.server?.hostname}:${app.server?.port}`
);
console.log(`Swagger UI: http://localhost:${app.server?.port}/swagger`);
