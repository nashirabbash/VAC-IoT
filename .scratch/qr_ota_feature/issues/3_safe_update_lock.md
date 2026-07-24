## What to build

Implement safety mechanisms in the ESP32 OTA process, including running OTA asynchronously on Core 0, locking updates during active therapy, and watchdog rollback protection.

## Acceptance criteria

- [x] OTA download task is created using FreeRTOS `xTaskCreatePinnedToCore` on Core 0.
- [x] Core 1 continues running the main BLE/UART communication loop completely unblocked during downloads.
- [x] Safe Lock: If `isTherapyActive == true`, setting partition swaps or ESP restarts is blocked; sets `update_pending = true` instead.
- [x] Applies pending update once the device state changes to `STATE_IDLE` or on next boot.
- [x] Rollback Watchdog: Bootloader checks RTC memory boot crash count. If count > 3, triggers automatic rollback to the previous stable partition.
- [x] Unit tests verify that updates are deferred during active therapy state.

## Blocked by

- [2_esp32_self_ota.md](file:///home/broo/Documents/apps/vac_dashboard_app/.scratch/qr_ota_feature/issues/2_esp32_self_ota.md)
