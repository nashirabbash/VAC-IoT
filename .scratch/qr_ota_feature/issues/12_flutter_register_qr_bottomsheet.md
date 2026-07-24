# 12 — Flutter UI Register: Real-time Form, Snap Fullscreen & Scanner Transition

**What to build:**
Enhance the Flutter Registration UI. First, implement real-time validation on the registration form fields (errors appear as the user types, not just on submit). Second, change the submit button to "Next". When clicked, the bottom sheet automatically snaps to 100% fullscreen and elegantly transitions (e.g., cross-fade) to the Camera Scanner view. If the user scans an invalid QR code, display a Toast/Snackbar message immediately. If valid, combine the QR data with the form data, hit `/api/auth/register`, and navigate to the Home screen on success.

**Blocked by:** 11 — Backend API Registration & Binding Integration

**Status:** ready-for-agent

- [ ] Registration text fields show error validation in real-time as the user types.
- [ ] "Next" button validates the form and snaps the bottom sheet to fullscreen (100%).
- [ ] Fullscreen sheet animates/transitions smoothly into the QR Scanner view.
- [ ] Scanning an invalid QR code shows a Toast/Snackbar warning.
- [ ] Successful scan posts data to `/api/auth/register` and routes to Home on 201 response.
