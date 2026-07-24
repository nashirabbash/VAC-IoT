## What to build

Implement the AVR ISP OTA bridge for flashing the ATmega chip. The ESP32 downloads the ATmega `.hex` program into its internal LittleFS/SPIFFS file storage and flashes it over the SPI ISP pins using the STK500v1 protocol.

## Acceptance criteria

- [ ] ESP32 downloads the `.hex` file from the Vercel API and saves it locally in SPIFFS/LittleFS.
- [ ] MD5 checksum is calculated and verified against the manifest before flashing.
- [ ] ESP32 executes the ISP bit-bang flashing sequence (`runIspMode` functions in `isp.h`) using the saved `.hex` file as the source.
- [ ] If flashing is interrupted (e.g. power loss), the ESP32 retains the `.hex` file and re-flashes the ATmega automatically on next boot.
- [ ] Unit tests verify SPIFFS storage operations and mock the STK500v1 flashing state machine.

## Blocked by

- [3_safe_update_lock.md](file:///home/broo/Documents/apps/vac_dashboard_app/.scratch/qr_ota_feature/issues/3_safe_update_lock.md)
- [4_web_targeted_ota.md](file:///home/broo/Documents/apps/vac_dashboard_app/.scratch/qr_ota_feature/issues/4_web_targeted_ota.md)
