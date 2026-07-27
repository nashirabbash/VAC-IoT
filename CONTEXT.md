# Context & Domain Language

## Authentication
* **AuthBottomSheet**: The unified, single-component entry point for all authentication flows in the app (Login, Register, and Forgot Password). State transitions between these flows happen in-place without stacking new screens.
* **AuthMode**: The current state of the AuthBottomSheet. Can be `login`, `signUp`, or `forgotPassword`. 
  * The `forgotPassword` mode allows direct password resets and contains fields for: Username, New Password, and Confirm New Password.

## Wi-Fi Provisioning
* **WifiBottomSheet**: The entry point bottom sheet for managing device Wi-Fi connection from `DeviceScreen`. Dynamically switches between the form state (*notConnected*) and the status state (*connected*).
* **WifiConnectionState**: Represents the state of the Wi-Fi connection modal: `notConnected`, `connecting`, `connected`, and `failed`.
  * In the `connected` state, no header is shown, presenting a centered Wi-Fi icon with status text and a bottom destructive "Disconnect Wifi" button.
  * Clicking "Disconnect Wifi" triggers an iOS-style confirmation dialog (`showAppAlertDialog`) before sending the disconnect instruction to the ESP32.

