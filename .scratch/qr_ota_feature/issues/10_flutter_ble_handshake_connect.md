# 10 — Flutter BLE Auto-Connect & Auth Handshake

**What to build:**
Implement the Bluetooth auto-connect sequence driven by the scanned QR parameters. The Flutter application must scan for the specific device name, establish a connection, write the AUTH_KEY to authenticate, and subscribe to update notifications.

**Blocked by:**
- [9_flutter_qr_scanner_utility.md](file:///home/broo/Documents/apps/vac_dashboard_app/.scratch/qr_ota_feature/issues/9_flutter_qr_scanner_utility.md)

**Status:** ready-for-agent

- [ ] Implement background scan using `flutter_blue_plus` filtering for the specific `DEVICE_NAME` parsed from the QR code.
- [ ] Implement auto-connect behavior: once the matching device name is found, automatically stop scanning and initiate the BLE connection.
- [ ] Implement connection timeout security handshake: Write the parsed `AUTH_KEY` to the ESP32 security characteristic immediately upon connecting (must be completed within 5 seconds to prevent the ESP32 from dropping the connection).
- [ ] **Auto-Reconnect (Hilang Jarak):** Jika koneksi BLE terputus karena jarak jauh, simpan status Device ID lokal dan buat aplikasi otomatis mencari dan terkoneksi ulang saat mesin kembali ke dalam jangkauan tanpa perlu scan QR.
- [ ] **Ganti Mesin (Unbind):** Sediakan tombol "Ganti Mesin" di layar Home UI untuk menghapus pengikatan alat lama, membuka kamera, dan men-scan QR alat baru.
- [ ] Subscribe to the `UPDATE_PENDING` characteristic to listen for firmware update notifications.
- [ ] Show user feedback in the UI for connecting, authenticating, and connection success/failure.
- [ ] Unit/Integration tests mock `flutter_blue_plus` connection states to verify the handshake flow.
