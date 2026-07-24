## What to build

Build the targeted device OTA release portal. Integrate a web UI to upload firmware binaries, link it to cloud storage, and write database logic to serve specific versions to selected device IDs.

## Acceptance criteria

- [x] Web page allows selecting a `.bin`, `.hex`, or `.tft` file and entering a version string.
- [x] Uploaded files are successfully stored in Supabase or Firebase Storage.
- [x] Database stores device registries and active deployments.
- [x] Provides options to release an update globally or to target specific device IDs.
- [x] API endpoint `/api/ota` verifies the requesting `device_id` against active targeted releases first, falling back to global releases.

## Blocked by

- [1_web_ota_api.md](file:///home/broo/Documents/apps/vac_dashboard_app/.scratch/qr_ota_feature/issues/1_web_ota_api.md)
