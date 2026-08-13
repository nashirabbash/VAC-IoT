# VAC STECHOQ Dashboard App

A cross-platform Flutter application (Android, iOS, Web) for real-time therapy monitoring, device control, and session tracking for the **VAC STECHOQ** (Vacuum Assisted Closure) medical device.

The app connects over Bluetooth Low Energy (BLE) for live hardware telemetry, persists session history and medical audit logs locally in an AES-256 encrypted SQLite database (`sqflite_sqlcipher`), manages auth tokens securely via `flutter_secure_storage`, and synchronizes records to the cloud REST backend over TLS 1.3 / HTTPS.

---

## Table of Contents

- [Key Features](#-key-features)
- [Getting Started](#-getting-started)
- [Platform Notes](#-platform-notes)
- [API Configuration](#-api-configuration)
- [System Architecture](#%EF%B8%8F-system--directory-architecture)
- [Data Layer & Storage](#-data-layer--storage)
- [Medical Audit Trail System](#-medical-audit-trail-system)
- [BLE Internals & Safety Boundaries](#-ble-internals--safety-boundaries)
- [Therapy Modes & Telemetry](#-therapy-modes--ble-telemetry)
- [End-to-End Flow](#-end-to-end-therapy--data-flow)
- [Security & Transport Requirements](#-security--transport-requirements)
- [Contributing](#-contributing)
- [Technology Stack](#%EF%B8%8F-technology-stack--dependencies)

---

## 📌 Key Features

- **BLE Device Pairing & Telemetry:** Connects to VAC hardware via `flutter_blue_plus`, subscribes to real-time therapy data streams, and handles automated handshakes.
- **Read-Only Telemetry Safety:** Enforces strict command whitelisting to block unauthorized remote therapy parameter modifications over BLE.
- **AES-256 Encrypted Local Database:** Uses `sqflite_sqlcipher` (schema v3) with 256-bit hex encryption keys derived and stored in `flutter_secure_storage` with self-healing recovery.
- **Medical Audit Trail Logging:** Records Nakes (medical personnel) clinical and device actions locally (`audit_logs`) and automatically synchronizes them to the cloud REST backend.
- **Cloud API Synchronization:** Automatically synchronizes unsynced local sessions and audit logs to the remote REST backend via HTTPS / TLS 1.3.
- **QR Code Provisioning:** Integrated QR scanner via `mobile_scanner` for rapid device pairing and Wi-Fi credential provisioning.
- **Live System Log Viewer:** Built-in in-app diagnostic log viewer ([`lib/screens/logScreen.dart`](lib/screens/logScreen.dart)) for debugging BLE telemetry, connection states, and API events.
- **Adaptive Design Token System:** Cupertino & Material combined styling with automatic light/dark mode support ([lib/asset/color_tokens.dart](lib/asset/color_tokens.dart)).
- **OTA Updates Banner:** Notifies users of Over-The-Air firmware updates for the connected VAC hardware.

---

## 🚀 Getting Started

This section walks you through setting up the project from scratch on your local machine.

### Prerequisites

Before you begin, make sure the following are installed and configured:

| Requirement | Version / Notes |
| :--- | :--- |
| [Flutter SDK](https://flutter.dev/docs/get-started/install) | `^3.12.2` (check with `flutter --version`) |
| Dart SDK | Included with Flutter |
| Android Studio **or** Xcode | For emulators and device toolchains |
| Physical Android or iOS device | **Strongly recommended** — BLE and Camera do not work on most emulators |
| Git | Any recent version |

> **Android minimum SDK:** The app targets a minimum SDK version compatible with `flutter_blue_plus`, `sqflite_sqlcipher`, and `flutter_secure_storage`. Ensure your device runs Android 8.0 (API 26) or higher.

### 1. Clone the Repository

```bash
git clone https://github.com/nashirabbash/VAC-IoT.git
cd VAC-IoT/vac_dashboard_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure the Backend URL

The API base URL is defined in [`lib/services/api_service.dart`](lib/services/api_service.dart). If you need to point to a local or staging backend, update this constant before running:

```dart
// lib/services/api_service.dart
static const _baseUrl = 'https://be-vac-production.up.railway.app/api';
```

See [API Configuration](#-api-configuration) for full details.

### 4. Run the App

Connect a physical device, then:

```bash
flutter run
```

To run on a specific device when multiple are connected:

```bash
flutter devices          # list connected devices
flutter run -d <device-id>
```

### 5. Verify Setup

Run static analysis and the test suite to confirm everything is working:

```bash
flutter analyze
flutter test
```

A clean run of both commands means your environment is set up correctly.

### Component Sandbox

[`lib/main.dart`](lib/main.dart) contains a `ComponentSandboxPage` for interactive UI component previews — Typography, Buttons, Steppers, Grouped Lists, and Alert Dialogs. To enable it, temporarily set the home route in `main.dart` to `ComponentSandboxPage()`.

---

## 📱 Platform Notes

### Android

Permissions are declared in [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml).

| Permission | API Level | Purpose |
| :--- | :--- | :--- |
| `BLUETOOTH` | ≤ 30 (legacy) | BLE adapter access on older Android |
| `BLUETOOTH_ADMIN` | ≤ 30 (legacy) | BLE on/off control on older Android |
| `BLUETOOTH_SCAN` | 31+ | Scan for nearby BLE devices (no location inference) |
| `BLUETOOTH_CONNECT` | 31+ | Connect to paired BLE devices |
| `ACCESS_FINE_LOCATION` | ≤ 30 | Required by BLE scan on Android 10 and below |
| `INTERNET` | All | Cloud REST API communication |
| `FOREGROUND_SERVICE` | All | Background BLE session continuity |
| `FOREGROUND_SERVICE_CONNECTED_DEVICE` | All | Foreground service type for connected BLE device |

> `BLUETOOTH_SCAN` is declared with `usesPermissionFlags="neverForLocation"` — the app does **not** use Bluetooth to derive location.

### iOS

Privacy usage descriptions are declared in [`ios/Runner/Info.plist`](ios/Runner/Info.plist).

| Key | Description |
| :--- | :--- |
| `NSCameraUsageDescription` | "This app needs camera access to scan for VAC devices." |
| `NSMicrophoneUsageDescription` | "This app needs microphone access for camera support." |

> iOS does **not** require explicit Bluetooth permission keys in `Info.plist` since `flutter_blue_plus` handles CoreBluetooth permission requests at runtime. If you target iOS 13+, the system permission dialog is shown automatically on first BLE scan.

> A physical iOS device is required for BLE. The iOS Simulator does not support CoreBluetooth scanning.

---

## 🔌 API Configuration

### Base URL

The REST API base URL is defined as a single constant in [`lib/services/api_service.dart`](lib/services/api_service.dart):

```dart
static const _baseUrl = 'https://be-vac-production.up.railway.app/api';
```

### Authentication Flow

1. User submits credentials via the login form ([`lib/component/login_form.dart`](lib/component/login_form.dart)).
2. `ApiService.login()` sends `POST /api/auth/login` with `{ username, password }`.
3. On success, the response JWT token is saved via `AuthRepository.saveToken()` to device Keystore/Keychain using `flutter_secure_storage`.
4. Device credentials (`deviceId`, `authPin`) extracted from the login response are also persisted securely.
5. All subsequent HTTP requests are intercepted by [`lib/network/api_interceptor.dart`](lib/network/api_interceptor.dart), which validates TLS 1.3 / HTTPS transport and attaches the `Authorization: Bearer <token>` header automatically.

### Logout Flow

1. User triggers logout from the avatar menu in [`lib/screens/homeScreens.dart`](lib/screens/homeScreens.dart).
2. `ApiService.logout()` sends `POST /api/auth/logout`.
3. The backend returns HTTP 400 if the user still has an active device connection.
4. On HTTP 200/204, `AuthRepository.clearToken()` wipes the token, device ID, auth PIN, and username from secure storage.

### REST API Endpoints Summary

| Method | Endpoint | Purpose |
| :--- | :--- | :--- |
| `POST` | `/api/auth/login` | Authenticate user, receive JWT |
| `POST` | `/api/auth/register` | Create a new account |
| `POST` | `/api/auth/logout` | Invalidate session server-side |
| `POST` | `/api/device/bind` | Bind a QR-scanned device to account |
| `GET` | `/api/therapy-sessions` | Fetch cloud session list (optional `?year=`) |
| `POST` | `/api/therapy-sessions` | Sync a local session to the cloud |
| `POST` | `/api/audit-logs` | Sync medical personnel audit logs to backend |

---

## 🏗️ System & Directory Architecture

The application adopts a modular multi-tier architecture isolating user interfaces, background business logic, and encrypted persistence layers.

```mermaid
flowchart TD
    accTitle: VAC STECHOQ Dashboard System Architecture
    accDescr: Component architecture showing user interfaces, background services, encrypted persistence layers, hardware BLE interfaces, and cloud REST integration.

    subgraph UI["UI & Screen Layer"]
        home_screen["HomeScreen<br/>(Dashboard & Summary)"]
        device_screen["DeviceScreen<br/>(Real-Time Control)"]
        history_screen["HistoryScreen<br/>(Session Log & Filter)"]
        scan_screen["ScanScreen<br/>(QR Provisioning)"]
        settings_screen["SettingsScreen<br/>(Theme & Account)"]
        log_screen["LogScreen<br/>(Live System Logs)"]
    end

    subgraph SERVICES["Services & Business Logic"]
        ble_service["BleService<br/>(Scan, Connection & Whitelist)"]
        therapy_receiver["TherapyReceiver<br/>(Live Telemetry Stream)"]
        therapy_sync["TherapySyncService<br/>(Offline Session Sync)"]
        audit_service["AuditService<br/>(Nakes Audit Trail Logger)"]
        audit_sync["AuditSyncService<br/>(Audit Log Cloud Sync)"]
        api_service["ApiService<br/>(REST API Client)"]
        log_service["LogService<br/>(In-Memory Log Notifier)"]
        ota_service["OtaBannerService<br/>(Firmware Notifier)"]
    end

    subgraph DATA["Persistence & Repositories"]
        auth_repo["AuthRepository<br/>(Token & Credentials)"]
        db_helper["DatabaseHelper<br/>(SQLCipher Singleton)"]
        secure_storage["Secure Storage<br/>(Keystore / Keychain)"]
        encrypted_db[("vac_dashboard.db<br/>(AES-256 Encrypted Tables)")]
    end

    subgraph EXTERNAL["External Ecosystem"]
        vac_hardware["VAC STECHOQ Device<br/>(BLE Hardware)"]
        cloud_backend["Cloud REST Backend<br/>(TLS 1.3 / HTTPS API)"]
    end

    UI --> SERVICES
    device_screen --> ble_service
    device_screen --> therapy_receiver
    scan_screen --> ble_service
    log_screen --> log_service
    
    SERVICES --> DATA
    therapy_receiver --> db_helper
    therapy_sync --> db_helper
    therapy_sync --> api_service
    audit_service --> db_helper
    audit_sync --> db_helper
    audit_sync --> api_service
    auth_repo --> secure_storage
    db_helper --> secure_storage
    db_helper --> encrypted_db

    ble_service <-->|"BLE GATT (Whitelisted)"| vac_hardware
    api_service <-->|"HTTPS / TLS 1.3"| cloud_backend

    classDef uiStyle fill:#e0f2fe,stroke:#0284c7,stroke-width:2px,color:#0369a1
    classDef serviceStyle fill:#f0fdf4,stroke:#16a34a,stroke-width:2px,color:#15803d
    classDef dataStyle fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#b45309
    classDef extStyle fill:#fae8ff,stroke:#c026d3,stroke-width:2px,color:#86198f

    class home_screen,device_screen,history_screen,scan_screen,settings_screen,log_screen uiStyle
    class ble_service,therapy_receiver,therapy_sync,audit_service,audit_sync,api_service,log_service,ota_service serviceStyle
    class auth_repo,db_helper,secure_storage,encrypted_db dataStyle
    class vac_hardware,cloud_backend extStyle
```

The application source code is organized under [lib/](lib/):

```
lib/
├── main.dart                    # Application entrypoint, theme listener & component sandbox
├── asset/                       # Design system tokens and color definitions
│   ├── color_tokens.dart        # Context-aware color tokens (AppColorTokenSet)
│   └── color.dart               # AppColors legacy color scheme
├── component/                   # Reusable UI components & design system widgets
│   ├── alert_dialog.dart        # iOS-style AppAlertDialog
│   ├── auth_bottom_sheet.dart   # Unified authentication bottom sheet
│   ├── auth_input_field.dart    # Custom authentication form input field
│   ├── bottomSheet.dart         # Standard bottom sheet wrapper
│   ├── bottom_sheet_header.dart # Header component for bottom sheets
│   ├── button.dart              # AppButton (primary, secondary, danger, ghost)
│   ├── card.dart                # Therapy session card item
│   ├── forgot_password_form.dart# Password reset form
│   ├── grouped_list.dart        # iOS-style grouped list view & tiles
│   ├── header.dart              # AppHeader widget (compact, large, inline)
│   ├── login_form.dart          # Login form widget
│   ├── menu.dart                # Context menu & action sheet
│   ├── mode_badge.dart          # Therapy mode visual badge
│   ├── ota_notification.dart    # OTA firmware update notification banner
│   ├── register_form.dart       # Registration form widget
│   ├── sectionHistory.dart      # Grouped therapy history list section
│   ├── splitButton.dart         # Dual-action split button widget
│   ├── stepper.dart             # Custom increment/decrement stepper
│   └── text.dart                # AppText typography system
├── data/                        # Local mock & seed data
│   └── dummyData.json           # Development fallback dataset
├── db/                          # Database persistence layer
│   └── database_helper.dart     # SQLCipher AES-256 singleton manager & queries
├── models/                      # Business & data transfer models
│   ├── auth_form_data.dart      # Auth form state validation model
│   ├── device_credentials.dart  # VAC device connection credentials
│   ├── register_dto.dart        # Registration payload DTO
│   └── therapy_session.dart     # TherapySession entity model
├── network/                     # Network middleware
│   └── api_interceptor.dart     # HTTP request interceptor, TLS 1.3 check & error handler
├── repositories/                # Data repository layer
│   ├── auth_repository.dart     # Secure token & credential persistence
│   └── settings_repository.dart # Preferences repository (theme mode)
├── screens/                     # Primary user interface screens
│   ├── homeScreens.dart         # Main dashboard & active session summary
│   ├── historyScreens.dart      # Session history list & year filtering
│   ├── deviceScreens.dart       # Real-time BLE device control screen
│   ├── logScreen.dart           # In-app system log viewer for debugging
│   ├── scanScreens.dart         # QR code device scanning screen
│   ├── settingsScreen.dart      # Settings, theme toggle & account details
│   ├── welcomeScreens.dart      # Onboarding welcome screen
│   └── wifiScreens.dart         # VAC device Wi-Fi configuration screen
├── services/                    # Business logic & background services
│   ├── api_service.dart         # REST API client service
│   ├── audit_service.dart       # Medical personnel action audit trail logger
│   ├── audit_sync_service.dart  # Background audit trail cloud sync bridge
│   ├── ble_service.dart         # BLE scanning, connecting & GATT safety whitelisting
│   ├── heartbeat_alarm_service.dart # Heartbeat monitor service
│   ├── log_service.dart         # Global in-memory logging service
│   ├── ota_banner_service.dart  # OTA firmware update banner manager
│   ├── therapy_receiver.dart    # Live therapy packet stream handler
│   └── therapy_sync_service.dart# Session synchronization bridge between SQLCipher and Cloud
└── utils/                       # Utility helpers
    ├── mode_color.dart          # Therapy mode visual badge color resolver
    └── text_styles.dart         # Typography text style utilities
```

---

## 💾 Data Layer & Storage

### SQLCipher AES-256 Local Database

Managed by [`DatabaseHelper`](lib/db/database_helper.dart) via `sqflite_sqlcipher` (`vac_dashboard.db`, schema version `3`).

#### Database Encryption & Key Management

- **Encryption Standard:** AES-256 full database encryption via SQLCipher.
- **Key Generation:** A clean 256-bit hex encryption key is generated using `Random.secure()` upon first run and cached securely in `flutter_secure_storage` under key `vac_db_encryption_key`.
- **Self-Healing Recovery:** If database opening fails (e.g. key corruption), `DatabaseHelper` catches the failure, logs the error, safely re-creates the database structure, and prevents application deadlock.

#### Table: `therapy_sessions`

| Column | Type | Modifiers | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Local session record identifier |
| `session_date` | `TEXT` | `NOT NULL` | ISO date string (`YYYY-MM-DD...`) used for year filtering |
| `title` | `TEXT` | `NOT NULL` | Session title / display name |
| `date` | `TEXT` | `NOT NULL` | User-formatted date string |
| `mode` | `TEXT` | `NOT NULL` | Therapy mode (`Kontinyu` or `Intermiten`) |
| `duration` | `TEXT` | `NOT NULL` | Session duration string |
| `is_synced` | `INTEGER` | `NOT NULL DEFAULT 0` | `0` = local only, `1` = synced to cloud |

#### Table: `audit_logs`

| Column | Type | Modifiers | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Audit log record identifier |
| `user_id` | `INTEGER` | `NULLABLE` | ID of logged-in medical personnel |
| `username` | `TEXT` | `NULLABLE` | Username of Nakes user |
| `hospital_name` | `TEXT` | `NULLABLE` | Associated hospital / medical facility |
| `device_id` | `TEXT` | `NULLABLE` | VAC device identifier |
| `action` | `TEXT` | `NOT NULL` | Action code (`VIEW_SESSION`, `BIND_DEVICE`, `EXPORT_REPORT`, `BLE_DISCONNECT`) |
| `details` | `TEXT` | `NULLABLE` | Additional context or parameters |
| `timestamp` | `TEXT` | `NOT NULL` | UTC ISO 8601 timestamp string |
| `is_synced` | `INTEGER` | `NOT NULL DEFAULT 0` | `0` = local only, `1` = synced to backend |

### Entity Relationship Diagram

```mermaid
erDiagram
    accTitle: SQLCipher Database and Storage Entity Relationship
    accDescr: Entity relationship diagram representing local encrypted SQLCipher tables and keys stored in secure storage.

    THERAPY_SESSIONS {
        int id PK "Auto Increment Local ID"
        string session_date "ISO format YYYY-MM-DD for year filter"
        string title "Session display title"
        string date "Formatted display date"
        string mode "Kontinyu or Intermiten"
        string duration "Duration string"
        int is_synced "0 = Local only, 1 = Cloud synced"
    }

    AUDIT_LOGS {
        int id PK "Auto Increment Local ID"
        int user_id "Nakes user identifier"
        string username "Nakes username"
        string hospital_name "Hospital / Facility"
        string device_id "Target VAC device ID"
        string action "Action code string"
        string details "Log action details"
        string timestamp "UTC ISO 8601 timestamp"
        int is_synced "0 = Local only, 1 = Cloud synced"
    }

    SECURE_STORAGE {
        string jwt_auth_token PK "Encrypted Auth Token"
        string vac_db_encryption_key "256-bit Hex SQLCipher Key"
        string device_id "Saved VAC Hardware ID"
        string auth_pin "Device BLE Auth PIN"
    }

    THERAPY_SESSIONS ||--o| SECURE_STORAGE : "authenticated & encrypted by"
    AUDIT_LOGS ||--o| SECURE_STORAGE : "logged under credentials in"
```

---

## 🩺 Medical Audit Trail System

To meet clinical compliance standards, the app implements an audit logging pipeline via [`AuditService`](lib/services/audit_service.dart) and [`AuditSyncService`](lib/services/audit_sync_service.dart).

### Logged Actions (`AuditActions`)

- `VIEW_SESSION` — Medical staff opened and inspected a specific therapy session log.
- `BIND_DEVICE` — Medical staff bound a new VAC hardware unit via QR code scanning.
- `EXPORT_REPORT` — Clinical therapy session report was generated or exported.
- `BLE_DISCONNECT` — Device BLE connection was explicitly closed or lost.

### Synchronization Pipeline

1. **Local Recording:** Every Nakes action calls `AuditService.instance.logAction()`, automatically retrieving user profile details (username, hospital) and writing to the encrypted `audit_logs` SQLite table.
2. **Background Sync:** Immediately after insertion, `AuditSyncService.instance.syncPendingAuditLogs()` batches unsynced audit logs (`is_synced = 0`) and sends them to `POST /api/audit-logs`.
3. **Acknowledgment:** Upon receiving HTTP 200/201 from the server, records are marked as `is_synced = 1`.

---

## 📡 BLE Internals & Safety Boundaries

All BLE communication is managed by [`BleService`](lib/services/ble_service.dart) using `flutter_blue_plus`.

### Read-Only Telemetry & GATT Command Whitelisting

To guarantee hardware safety and prevent unauthorized remote modification of therapeutic parameters over BLE:

- **Command Whitelist:** The app permits ONLY non-invasive housekeeping commands via `BleService.isCommandAllowed(type)`.
- **Allowed Commands:**
  - `auth` — Initial authentication handshake.
  - `time_sync` — Synchronize device internal RTC clock.
  - `get_status` — Query current Wi-Fi status.
  - `wifi_config` — Provision local Wi-Fi credentials.
  - `wifi_disconnect` — Unlink Wi-Fi network.
- **Forbidden Commands:** Any remote RPC attempting to adjust target pressure, continuous/intermittent therapy parameters, or suction motor speed over BLE is rejected before transmission.

### GATT Profile

| Role | UUID | Direction | Description |
| :--- | :--- | :--- | :--- |
| **Service** | `4fafc201-1fb5-459e-8fcc-c5c9c331914b` | — | Primary GATT service |
| **RX Char** | `c083b0f6-bb21-4f15-8120-d4f13b28b7e2` | App → Device (Write) | Command channel — whitelisted JSON commands only |
| **TX Char** | `6e400003-b5a3-f393-e0a9-e50e24dcca9e` | Device → App (Notify) | Telemetry channel — device notifies JSON events here |

---

## ⚡ Therapy Modes & BLE Telemetry

The VAC STECHOQ device operates in two primary therapy modes:

| Mode | Visual Badge Color | Description |
| :--- | :--- | :--- |
| **Kontinyu (Continuous)** | Blue | Continuous negative pressure wound therapy |
| **Intermiten (Intermittent)** | Orange | Cycled suction and release intervals |

Badge colors are resolved by [`lib/utils/mode_color.dart`](lib/utils/mode_color.dart) via `modeBadgeColor(mode)`.

---

## 🔄 End-to-End Therapy & Data Flow

```mermaid
sequenceDiagram
    accTitle: End-to-End Therapy Session and Cloud Sync Flow
    accDescr: Sequence diagram illustrating device connection, telemetry stream reception, session completion local persistence, audit logging, and cloud sync.

    actor User as Medical Personnel
    participant UI as DeviceScreen / UI
    participant BLE as BleService
    participant VAC as VAC Hardware
    participant Audit as AuditService
    participant DB as DatabaseHelper (SQLCipher)
    participant Sync as TherapySyncService & AuditSyncService
    participant API as Cloud REST API

    User->>UI: 1. View Session / Connect Device
    UI->>Audit: 2. Record Nakes Audit Action (e.g. BIND_DEVICE / VIEW_SESSION)
    Audit->>DB: 3. Insert audit log (is_synced = 0)
    
    UI->>BLE: 4. Initiate Whitelisted BLE Handshake (auth & time_sync)
    BLE->>VAC: 5. BLE GATT Command Write
    VAC-->>BLE: 6. Handshake Success & Live Telemetry Stream
    
    loop Real-Time Telemetry Stream
        VAC-->>BLE: 7. BLE Notification (Pressure, Duration, Mode)
        BLE-->>UI: 8. Emit Live Telemetry to Dashboard UI
    end

    User->>UI: 9. Complete Therapy Session
    UI->>DB: 10. Save Session Record (is_synced = 0)
    DB-->>UI: 11. Session Saved in Encrypted Local Storage

    opt Background Cloud Sync (HTTPS / TLS 1.3)
        Sync->>DB: 12. Query Unsynced Sessions & Audit Logs
        DB-->>Sync: 13. Return Unsynced Batches
        Sync->>API: 14. POST /api/therapy-sessions & POST /api/audit-logs
        API-->>Sync: 15. HTTP 200/201 Confirmation
        Sync->>DB: 16. Update Records (is_synced = 1)
    end
```

---

## 🛡️ Security & Transport Requirements

1. **Mandatory TLS 1.3 / HTTPS:** [`ApiInterceptor`](lib/network/api_interceptor.dart) inspects every outgoing HTTP request. Plaintext HTTP traffic is rejected in release builds (`SecurityException`).
2. **AES-256 Storage Encryption:** Local databases use SQLCipher (`sqflite_sqlcipher`) with randomly generated 256-bit keys stored in platform-native secure enclaves (Keystore / Keychain).
3. **No Safety-Critical Control via BLE:** Control parameters for wound therapy suction levels are enforced at hardware boundary level and protected against BLE parameter modification.

---

## 🤝 Contributing

### Branch Conventions

| Branch prefix | Purpose |
| :--- | :--- |
| `feat/` | New feature |
| `fix/` | Bug fix |
| `refactor/` | Code restructuring without behavior change |
| `docs/` | Documentation updates only |
| `chore/` | Maintenance tasks (deps, configs) |

### Before Submitting

Run both checks and fix any issues before opening a pull request:

```bash
flutter analyze   # check code style & lints
flutter test      # run unit & widget test suite
```

---

## 🛠️ Technology Stack & Dependencies

### Runtime Dependencies

| Package | Version | Purpose |
| :--- | :--- | :--- |
| Flutter SDK | `^3.12.2` | Core application framework |
| `sqflite_sqlcipher` | `^3.4.1` | AES-256 encrypted local SQLite database engine |
| `flutter_blue_plus` | `^1.32.12` | BLE scanning, connecting, and GATT streaming |
| `flutter_secure_storage` | `^10.3.1` | Encrypted storage for JWT tokens and database keys |
| `http` | `^1.3.0` | REST API HTTP client |
| `mobile_scanner` | `^7.2.0` | QR code scanner engine |
| `camera` | `^0.10.6` | Camera hardware module integration |
| `path` | `^1.9.1` | Cross-platform file path helper |

### Development Dependencies

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `flutter_test` | `sdk: flutter` | Unit and widget testing framework |
| `flutter_lints` | `^6.0.0` | Recommended lint rules |
| `mocktail` | `^1.0.5` | Mocking library for Dart tests |
| `flutter_native_splash` | `^2.4.6` | Native launch splash screen generator |
