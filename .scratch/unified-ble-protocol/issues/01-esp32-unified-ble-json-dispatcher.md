# 01 — ESP32 Unified BLE JSON Command Dispatcher

**What to build:**
Refactor ESP32 BLE receiver to accept incoming JSON command payloads on a single RX Write characteristic, parse commands (`auth`, `wifi_config`, `wifi_disconnect`, `time_sync`, `get_status`), and emit corresponding JSON event messages (`auth_result`, `wifi_status`, `therapy_event`, `update_pending`) on a single TX Notify characteristic.

**Blocked by:** None — can start immediately

**Status:** completed

- [x] ESP32 receives JSON strings on single RX Write characteristic (`c083b0f6-bb21-4f15-8120-d4f13b28b7e2`)
- [x] ESP32 parses `"type"` field and routes commands (`auth`, `wifi_config`, `wifi_disconnect`, `time_sync`, `get_status`)
- [x] ESP32 emits JSON event payloads over single TX Notify characteristic (`6e400003-b5a3-f393-e0a9-e50e24dcca9e`)
- [x] Firmware compiles cleanly with PlatformIO (`pio run -e esp32wroom32`)
