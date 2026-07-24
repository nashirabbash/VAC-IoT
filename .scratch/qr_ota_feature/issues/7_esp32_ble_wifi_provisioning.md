# 7 — ESP32 BLE WiFi Provisioning & Admin Authentication

**What to build:**
Implement new BLE characteristics on the ESP32 to allow WiFi provisioning. The characteristics must enforce authorization by verifying an Admin Auth Key before writing new credentials to NVS and attempting to connect.

**Blocked by:**
- [5_esp32_avr_isp_ota.md](file:///home/broo/Documents/apps/vac_dashboard_app/.scratch/qr_ota_feature/issues/5_esp32_avr_isp_ota.md)

**Status:** completed

- [x] Define `WIFI_CONFIG_UUID` (Write) and `WIFI_STATUS_UUID` (Read/Notify) BLE Characteristics.
- [x] Implement write callback for `WIFI_CONFIG_UUID` that checks for a payload format containing `{ssid, password, admin_key}`.
- [x] Authorize writes by verifying `admin_key` matches the configured secret organization credential on the ESP32.
- [x] If unauthorized, reject the write and return a failure status to `WIFI_STATUS_UUID`.
- [x] If authorized, write the SSID and password to NVS using `NvsHelper`, update `WIFI_STATUS_UUID` to "CONNECTING", and initiate connection in background.
- [x] Update `WIFI_STATUS_UUID` to "CONNECTED" or "FAILED" depending on the outcome.
- [x] Native unit tests verify parser validation and NVS writes.
