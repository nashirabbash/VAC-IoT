## Problem Statement

When a user wants to log out of the support mobile application via the avatar menu, the app simply navigates back to the welcome screen without formally invalidating the session against our business rules. Furthermore, there is a strict rule that a user cannot log out while still actively connected to a physical device to ensure the device isn't left locked to an inaccessible account.

## Solution

Modify the existing "Log out" button located in the avatar menu (`HomeScreen`). When tapped, the app will call the backend `/auth/logout` endpoint. If the backend detects an active device connection, it will reject the logout request and the app will inform the user (via a toast or alert) that they must disconnect their device first. If the logout is successful, the app will clear the local authentication token and return the user to the welcome/login screen.

## User Stories

1. As a mobile app user, I want the "Log out" button in the avatar menu to securely sign me out by calling the backend.
2. As a mobile app user, I want the app to prevent me from logging out if I am still actively connected to a physical device, so that my device does not remain permanently locked to a signed-out account.
3. As a mobile app user, I want to see a clear error message instructing me to disconnect my device first if my logout attempt is blocked, so that I understand what action to take next.
4. As a mobile app user, I want my local session token to be cleared upon a successful logout, so that my device is securely signed out locally.
5. As a mobile app user, I want to be redirected to the Welcome/Login screen immediately after a successful logout, so that I can log in again if needed.

## Implementation Decisions

- **UI Modifications:** Hook up the existing "Log out" `AppMenuItem` in the `_showAvatarMenu` method of `HomeScreen` (`lib/screens/homeScreens.dart`) to the new asynchronous logout flow.
- **Network Layer:** Add a `logout()` method to `ApiService` (in `lib/services/api_service.dart`) that sends a POST request to `/auth/logout`. It should properly parse and throw any API errors (e.g., the 400 error requiring device disconnection).
- **Auth State Management:** Update the relevant Auth repository (e.g., `AuthRepository.deleteToken()`) to clear the JWT locally upon a successful `/auth/logout` response.
- **Navigation:** Upon successful logout, use `Navigator.pushReplacement` (or `pushAndRemoveUntil`) to clear the navigation stack and navigate to the `WelcomeScreens`.
- **Error Handling:** If `ApiService.logout()` throws an error containing "disconnect the device", show a `Toastification` or `showAppAlertDialog` to inform the user.

## Testing Decisions

- **Seam:** The primary seam for testing this feature will be at the Widget level (`HomeScreen` widget tests), focusing on the avatar menu interaction with a mocked `ApiService` and `AuthRepository`. We want to mock out the network calls, so we don't hit the real backend during tests.
- **What makes a good test:** The tests should verify the external behavior (UI updates, navigation, and API service invocation) without relying on the actual network layer.
- **Modules Tested:** `HomeScreen` avatar menu logic, and `ApiService` response parsing.
- **Prior Art:** We will follow the existing patterns for widget testing in the Flutter project (using `mocktail` for mocks as specified in `pubspec.yaml`).

## Out of Scope

- Implementing the backend `/auth/logout` endpoint (this is already complete in the backend repository).
- Modifying the Disconnect Device feature (this already exists in `DeviceScreen`).

## Further Notes

- The backend endpoint `/auth/logout` was built to strictly enforce this rule. It returns a 400 Bad Request with the message "Please disconnect the device before logging out." if `isActive: true` is found for the user's device link.
