## What to build

Implement the Nextion HMI TFT OTA bridge. The ESP32 downloads the `.tft` update to its internal storage, commands the ATmega to switch to UART pass-through bridge mode, and uploads the TFT file over serial to the Nextion display.

## Acceptance criteria

- [ ] ESP32 downloads the Nextion `.tft` file to SPIFFS/LittleFS (or falls back to direct streaming if space is insufficient).
- [ ] ESP32 sends a pass-through trigger command over UART to the ATmega.
- [ ] ATmega halts its main loop and enters serial pass-through mode, forwarding all bytes between ESP32 and Nextion.
- [ ] ESP32 executes the Nextion upload protocol over serial (commands: `whmi-wri` and streaming data chunks).
- [ ] If upload fails mid-way, the ESP32 alerts the user and retries flashing on next boot.
- [ ] Unit tests verify serial command exchanges and pass-through states.

## Blocked by

- [5_esp32_avr_isp_ota.md](file:///home/broo/Documents/apps/vac_dashboard_app/.scratch/qr_ota_feature/issues/5_esp32_avr_isp_ota.md)
