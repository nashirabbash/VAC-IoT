# 8 — Flutter Admin WiFi Setup UI

**What to build:**
Implement the WiFi Provisioning wizard on the Flutter app. Access to this wizard is restricted to Admin or Maintenance users, either by role verification or by scanning a technician-specific QR code. It will connect to the ESP32 via BLE and transmit target WiFi credentials.

**Blocked by:**
- [7_esp32_ble_wifi_provisioning.md](file:///home/broo/Documents/apps/vac_dashboard_app/.scratch/qr_ota_feature/issues/7_esp32_ble_wifi_provisioning.md)

**Status:** ready-for-agent

- [ ] Add authorization UI guard (hiding WiFi setup button except for users with `admin` metadata or scanning signed technician QR).
- [ ] Implement local WiFi scan in Flutter (or allow manual entry) for SSID and Password.
- [ ] Connect to ESP32 BLE GATT Server and identify the WiFi config characteristics.
- [ ] Format and send the encrypted/hashed payload `{ssid, password, admin_key}` over the BLE write characteristic.
- [ ] Subscribe to the status characteristic to display progress feedback (e.g. "Connecting...", "Success!", "Invalid Password").
- [ ] Persist connectivity status feedback dynamically in the UI.
