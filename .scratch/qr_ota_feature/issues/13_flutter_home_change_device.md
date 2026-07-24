# 13 — Flutter Home Screen "Change Device" Menu

**What to build:**
Update the Avatar Context Menu on the `HomeScreen` (`homeScreens.dart`) to include a "Change Device" button. This option should only be visible if the user currently has a bound device. Clicking it opens a QR scanner. Scanning a new machine triggers the `/api/device/bind` backend endpoint. Upon a successful response, the app updates the local device identity and refreshes the Home screen state to reflect the new machine.

**Blocked by:** 11 — Backend API Registration & Binding Integration

**Status:** ready-for-agent

- [ ] "Change Device" menu item conditionally appears in the Avatar menu.
- [ ] Clicking the menu opens the QR scanner screen.
- [ ] Scanned data hits `POST /api/device/bind` to swap the active device.
- [ ] The new JWT token and `deviceId` are saved locally and the UI state refreshes.
