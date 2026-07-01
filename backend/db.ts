import { Database } from "bun:sqlite";

export const db = new Database("npwt.sqlite", { create: true });

// Completed/ongoing therapy sessions — history shown in app.
db.run(`
  CREATE TABLE IF NOT EXISTS therapy_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_number INTEGER NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    duration_seconds INTEGER NOT NULL,
    average_pressure_mmhg REAL NOT NULL,
    badge_level TEXT
  )
`);

// Raw live snapshots pushed by any monitoring device — mirrors NpwtDeviceData.
db.run(`
  CREATE TABLE IF NOT EXISTS readings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    device_id TEXT,
    session_id INTEGER REFERENCES therapy_sessions(id),
    timestamp TEXT NOT NULL,
    is_device_on INTEGER NOT NULL,
    is_therapy_active INTEGER NOT NULL,
    connection_status TEXT NOT NULL,
    pressure_value REAL NOT NULL,
    pressure_stability TEXT NOT NULL,
    is_pump_active INTEGER NOT NULL,
    pump_cumulative_seconds INTEGER NOT NULL,
    pump_current_session_seconds INTEGER NOT NULL,
    canister_volume_ml REAL NOT NULL,
    is_canister_full INTEGER NOT NULL,
    canister_needs_replacement INTEGER NOT NULL,
    active_alarms TEXT NOT NULL,
    battery_level REAL,
    is_adapter_connected INTEGER NOT NULL,
    system_voltage REAL NOT NULL
  )
`);

db.run(`
  CREATE INDEX IF NOT EXISTS idx_readings_timestamp ON readings(timestamp)
`);
