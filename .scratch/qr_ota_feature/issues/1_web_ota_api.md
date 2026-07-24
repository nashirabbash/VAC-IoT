## What to build

Implement the basic `/api/ota` GET route handler in the Vercel web app. This route serves the firmware update manifest to the devices.

## Acceptance criteria

- [ ] Route `GET /api/ota` is created and functional.
- [ ] Route accepts query parameters: `device_id`, `esp_v`, `atm_v`, and `nex_v`.
- [ ] Returns a JSON manifest containing `update_available` (boolean).
- [ ] If an update is available, the response includes: `target` (esp/atm/nex), `version` (string), `download_url` (string), and `md5_hash` (string).
- [ ] Unit tests mock database queries and verify the JSON response structures.

## Blocked by

None - can start immediately
