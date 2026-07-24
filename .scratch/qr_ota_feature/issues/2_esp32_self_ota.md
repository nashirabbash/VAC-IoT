## What to build

Implement the ESP32 self-updating OTA workflow. The ESP32 connects to WiFi, queries the Vercel API, downloads its own `.bin` update, verifies the MD5 checksum, and flashes its secondary OTA partition.

## Acceptance criteria

- [x] ESP32 successfully initiates a WiFi connection.
- [x] Queries `GET /api/ota` using its current version.
- [x] If `update_available` is true and target is `esp`, downloads the `.bin` file.
- [x] Calculates the MD5 checksum of the downloaded file locally and compares it with the manifest's `md5_hash`.
- [x] Aborts update and deletes file if MD5 checksum fails.
- [x] Installs update into the alternate OTA partition using the Arduino/NimBLE OTA library.
- [x] Unit tests verify MD5 calculation logic and state transitions (download, check, flash).

## Blocked by

- [1_web_ota_api.md](file:///home/broo/Documents/apps/vac_dashboard_app/.scratch/qr_ota_feature/issues/1_web_ota_api.md)
