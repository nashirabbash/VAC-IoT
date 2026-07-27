# 02 — Flutter BleService Event Bus & JSON Stream

**What to build:**
Update `BleService` in Flutter to communicate through a unified `send(type, payload)` method over the single RX characteristic, and expose a broadcast `Stream<Map<String, dynamic>> onMessage` that deserializes and emits incoming TX JSON events from the ESP32.

**Blocked by:** 01 — ESP32 Unified BLE JSON Command Dispatcher

**Status:** completed

- [x] `BleService.send(String type, Map<String, dynamic> payload)` serializes and writes JSON command payload over RX characteristic
- [x] `BleService.onMessage` stream emits parsed JSON objects for all incoming TX notifications
- [x] `BleService` sanitizes incoming byte payloads removing null bytes and non-printable characters
- [x] `flutter analyze` and `flutter test` pass with 0 errors
