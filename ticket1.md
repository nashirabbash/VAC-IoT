## Parent
Part of #20 (Feature: Mobile App Logout)

## What to build
When the user taps "Log out" in the Avatar menu and they are not connected to a device, they successfully log out. This requires wiring up the UI to hit the `/auth/logout` endpoint, clearing the token on success, and returning to the Welcome screen.

## Acceptance criteria
- [ ] `ApiService.logout()` sends a POST request to `/auth/logout`
- [ ] The "Log out" button in `HomeScreen`'s avatar menu calls `ApiService.logout()`
- [ ] On a successful response, the local token is cleared via `AuthRepository`
- [ ] On a successful response, the app navigates to `WelcomeScreens`
- [ ] Widget tests are added to verify this success path by mocking `ApiService.logout()`

## Blocked by
- None — can start immediately.
