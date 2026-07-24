# 11 — Backend API Registration & Binding Integration

**What to build:**
Modify the `POST /api/auth/register` endpoint in the backend (`be_vac`) to accept a `qrKey` parameter. When called, the backend must execute a transaction that creates a new User and immediately creates an active `TrDeviceUser` binding for the scanned device. It should return a JWT token in the response so the user is instantly logged in. Verify that `POST /api/device/bind` properly unbinds the old device and returns a new token for the Change Device feature.

**Blocked by:** None — can start immediately.

**Status:** ready-for-agent

- [ ] `POST /api/auth/register` accepts `qrKey`.
- [ ] Validates `qrKey` against the `Device` table; returns 400 Bad Request if invalid.
- [ ] Database transaction ensures `User` and `TrDeviceUser` records are created together.
- [ ] Endpoint returns 201 Created containing the JWT Token and `deviceId`.
