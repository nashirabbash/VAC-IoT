# Specification: VAC QR-BLE Integration and Flow Architecture

**Triage:** `ready-for-agent`

## Problem Statement

The user is facing fragmented and insecure connectivity when pairing the VAC Dashboard application with the physical VAC machine. Without an explicit binding flow, users have to manually pair via Bluetooth settings which is error-prone. Additionally, registering an account without physically associating it with a machine risks unauthorized access. Furthermore, once connected, if a therapist leaves Bluetooth range, the connection drops and currently requires a manual re-connection process. Finally, changing between machines requires a clear UI interaction that does not exist in the current dashboard.

## Solution

A robust, localized Bluetooth binding architecture backed by cloud authentication. 
The system separates the "Account Phase" (connecting the user to the Backend via internet) from the "Machine Phase" (connecting the phone to the ESP32 via BLE without internet).
During registration, the user provides a `qrKey` via a QR Scanner bottom sheet, binding their account directly to a specific machine. The app stores the Machine's ID locally. When in range, the app automatically connects to the machine via BLE without needing re-scanning. If the connection drops due to distance, the app automatically reconnects when the user returns. To change machines, the user can explicitly trigger a "Change Device" flow from the Avatar Menu.

## User Stories

1. As a therapist, I want to fill in my registration details and immediately scan the machine's QR code, so that my account is instantly verified and bound to that specific machine on the backend.
2. As a hospital administrator, I want the backend to reject registrations that provide an invalid `qrKey`, so that unauthorized users cannot create accounts to access medical data.
3. As a returning therapist, I want the app to auto-login using a saved JWT token (valid for 2 weeks), so that I can bypass the registration and login screens daily.
4. As a therapist, I want the app to automatically connect to my bound machine via BLE, so that I do not have to scan a QR code every time I open the app.
5. As a therapist, I want the app to automatically reconnect to the machine if the Bluetooth signal drops due to distance, so that I can walk in and out of the patient's room seamlessly.
6. As a therapist covering multiple rooms, I want to click "Change Device" in my Avatar Menu, so that I can scan a new machine's QR code and shift my active binding to the new machine.
7. As a backend database, I want to maintain a `TrDeviceUser` 1-to-Many relational table, so that multiple nurses on different shifts can securely bind to the same machine by modifying their `isActive` status.
8. As a security administrator, I want the QR code to encode a hidden `AUTH_PIN` along with the `DEVICE_ID`, so that the Flutter app can send this PIN over BLE during the initial handshake, preventing unauthorized BLE scanners from holding a connection.
9. As a patient, I want the ESP32 to forcefully disconnect any Bluetooth connection that fails to provide the correct PIN within 5 seconds, ensuring my therapy cannot be tampered with.

## Implementation Decisions

- **QR Code Format:** The QR string will be formatted to contain the device identity and security PIN (e.g., `B002U|9A2F`). The first part (`B002U`) is the `DEVICE_ID` used for the backend validation and the BLE advertisement name. The second part (`9A2F`) is the `AUTH_PIN` used for the BLE security handshake.
- **Backend - Registration:** The `/api/auth/register` endpoint has been modified to accept `qrKey`. It performs a database transaction: creates the User, binds the User to the Device in `TrDeviceUser`, and returns the login JWT token directly.
- **Backend - Change Device:** The `/api/device/bind` endpoint accepts a new `qrKey`. It sets `isActive = false` on the old binding and creates a new active binding, returning a fresh JWT token.
- **Flutter UI - Registration Bottom Sheet:** The Registration screen uses a "Next" button instead of "Submit". Clicking it reveals a modal bottom sheet containing the QR Scanner.
- **Flutter UI - Home Screen Avatar Menu:** Added a conditionally rendered "Change Device" (`Icons.qr_code_scanner_rounded`) button in the Avatar Menu (`homeScreens.dart`). It only appears if the user has a bound device. Clicking it opens the `ScanScreen()`.
- **Flutter Auto-Reconnect:** The Flutter app stores `DEVICE_ID` and `AUTH_PIN` in local storage. The `flutter_blue_plus` package is configured to continuously scan for the `DEVICE_ID` filter. Upon detection, it connects automatically.

## Testing Decisions

Tests will verify external behaviors rather than internal implementation details:

- **Frontend-Backend API Seam (HTTP Mocking):** Test the UI transitions by mocking the HTTP client. Simulating `201 Created` during registration should navigate the user to the Home Screen. Simulating `400 Bad Request` should show an error snackbar and keep the user on the scanner.
- **Flutter-BLE Seam (Bluetooth Mocking):** Mock the `flutter_blue_plus` state machines. Simulate finding a device, connecting, writing the `AUTH_PIN` characteristic, and simulating a distance-induced disconnect to ensure the Auto-Reconnect loop triggers.
- **Backend Database Seam:** On the backend repository, test the Prisma database transactions to verify that registering with a valid `qrKey` correctly inserts records into both `User` and `TrDeviceUser` simultaneously.

## Out of Scope

- ESP32 Over-The-Air (OTA) updates are covered in a separate specification.
- Managing user profiles (e.g., changing names, resetting passwords) is not included.
- Automated hardware-level physical testing (requires manual bench testing).

## Further Notes

- The 2-week token expiry is managed by the backend JWT configuration. The Flutter app intercepts `401 Unauthorized` responses and forces a manual logout/re-login.
