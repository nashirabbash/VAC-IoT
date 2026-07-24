# 9 — Flutter QR Code Scanner & Parser Utility

**What to build:**
Implement the QR Code scanner interface and parsing utility in the Flutter application. It must scan a QR code, parse the pipe-separated string format, and validate the HMAC checksum.

**Blocked by:**
- None (Can start immediately)

**Status:** ready-for-agent

- [ ] Integrate a QR code scanner library (e.g. `mobile_scanner` or similar package) into a new page in the Flutter app.
- [ ] Create a parser utility class `QrPayloadParser` that handles strings formatted as `PREFIX|MAC_ADDRESS|SECURITY_STRING|DEVICE_NAME|AUTH_KEY|HMAC`.
- [ ] Implement string validation checking for correct prefix and non-empty parameters.
- [ ] Verify the HMAC checksum of the QR payload to prevent tampering.
- [ ] Write unit tests verifying successful parsing of valid strings, and error handling for empty, wrong prefix, or corrupted HMAC strings.
