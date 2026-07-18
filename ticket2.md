## Parent
Part of #20 (Feature: Mobile App Logout)

## What to build
When the user taps "Log out" but they are still connected to a physical device, the app must prevent the logout and inform the user to disconnect the device first.

## Acceptance criteria
- [ ] `ApiService.logout()` correctly parses the 400 Bad Request error returned by the backend when an active device is found.
- [ ] The `HomeScreen` avatar menu's logout action catches this specific error.
- [ ] The app displays an error toast or alert dialog instructing the user: "Please disconnect the device before logging out."
- [ ] The user remains on the `HomeScreen` and their local token is *not* cleared.
- [ ] Widget tests are added to verify this error path by mocking `ApiService.logout()` to throw.

## Blocked by
- Blocked by #21 (Logout: Success Path)
