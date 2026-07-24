# 14 — Flutter BLE 5-Second Handshake & Auto-Reconnect Logic

**What to build:**
Implement the core Bluetooth connectivity engine using `flutter_blue_plus`. The app should continuously scan in the background for the saved `DEVICE_ID`. When found, it auto-connects and writes the hidden `AUTH_PIN` to the ESP32 to satisfy the 5-second security window. If the phone loses connection because it moved out of range, the app automatically falls back to scanning mode and reconnects silently once the user walks back in range.

**Blocked by:** 12, 13

**Status:** ready-for-agent

- [ ] App retrieves stored `DEVICE_ID` and `AUTH_PIN` from local storage.
- [ ] `flutter_blue_plus` filters background scan specifically for the `DEVICE_ID` name.
- [ ] On connection, the app writes `AUTH_PIN` to the correct BLE characteristic within 5 seconds.
- [ ] The app listens to connection state drops and safely re-enters the scanning loop (Auto-Reconnect).
- [ ] **Home Screen UI State:** The Home screen observes the BLE state. It displays a "Mencoba Connect..." (Trying to connect) UI with a loading/pulsing animation while scanning. If it fails or drops, it updates to a "Gagal Connect" (Failed/Searching) UI.
