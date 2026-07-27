# 03 — Wi-Fi Provisioning UI Migration to Unified BLE Events

**What to build:**
Migrate `WifiBottomSheet` and `DeviceScreen` UI components to use the new `bleService.send(...)` method for sending Wi-Fi credentials / disconnect commands, and reactively update UI state from `bleService.onMessage` (`type == 'wifi_status'`), completely eliminating GATT read polling loops.

**Blocked by:** 02 — Flutter BleService Event Bus & JSON Stream

**Status:** completed
Completed At: 2026-07-27T16:01:30+07:00

- [x] `WifiBottomSheet` uses `bleService.send('wifi_config', {...})` and `bleService.send('wifi_disconnect', {})`
- [x] `WifiBottomSheet` listens to `bleService.onMessage` / `onWifiStatusChanged` for state transitions
- [x] `DeviceScreen` tile detail updates reactively from stream
- [x] `flutter test` and `flutter analyze` pass cleanly
