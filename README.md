# VAC STECHOQ Dashboard App

A cross-platform Flutter application (Android, iOS, Web) designed for real-time therapy monitoring, device control, and session tracking for the **VAC STECHOQ** (Vacuum Assisted Closure) medical device.

The app supports Bluetooth Low Energy (BLE) connectivity for live hardware telemetrics, offline-first local session history storage via SQLite (`sqflite`), secure authentication token management (`flutter_secure_storage`), cloud REST API synchronization, and adaptive dark/light design token styling.

---

## Technical Overview & Diátaxis Framework

This documentation follows the [Diátaxis Framework](https://diataxis.fr/) structure:

- **Explanation:** Architecture, state design, storage strategy, and BLE stream pipelines.
- **Reference:** Database schema, package manifest, project folder layout, and component API.
- **How-to Guides:** Environment setup, building, linting, testing, and component sandbox usage.

---

## Key Features

- **BLE Device Pairing & Telemetry:** Connects to VAC hardware via `flutter_blue_plus`, subscribes to therapy data streams, and allows live control.
- **Offline-First Therapy History:** Saves therapy session records in a local SQLite database (`vac_dashboard.db`).
- **Cloud API Synchronization:** Automatically or manually synchronizes unsynced local sessions to the remote REST backend.
- **QR Code Connectivity:** Integrated QR scanner via `mobile_scanner` for rapid device and Wi-Fi credential provisioning.
- **Adaptive Design Token System:** Cupertino & Material combined styling with automatic light/dark mode support ([color_tokens.dart](file:///home/broo/Documents/apps/vac_dashboard_app/lib/asset/color_tokens.dart)).
- **OTA Updates Banner:** Notifies users of Over-The-Air firmware updates for connected VAC hardware.

---

## Technology Stack & Dependencies

| Dependency | Version | Purpose |
| :--- | :--- | :--- |
| **Flutter SDK** | `^3.12.2` | Core framework runtime |
| **sqflite** | `^2.4.3` | Local SQLite database engine |
| **flutter_blue_plus** | `^1.32.12` | Bluetooth Low Energy scanning, connecting, & streaming |
| **flutter_secure_storage** | `^10.3.1` | Encrypted storage for JWT auth tokens & device credentials |
| **http** | `^1.3.0` | Client for cloud REST API endpoints |
| **mobile_scanner** | `^7.2.0` | QR Code scanner engine |
| **camera** | `^0.10.6` | Camera hardware module integration |
| **path** | `^1.9.1` | Cross-platform file system path manipulation |
| **flutter_native_splash** | `^2.4.6` | Native launch splash screen generator |

---

## System & Directory Architecture

The application source code is structured inside [lib/](file:///home/broo/Documents/apps/vac_dashboard_app/lib/):

```
lib/
├── main.dart                    # Application entrypoint & theme listener
├── asset/                       # Design tokens & color system
│   ├── color_tokens.dart        # Context-aware color tokens (AppColorTokenSet)
│   └── color.dart               # AppColors legacy color scheme
├── component/                   # Reusable UI widgets & design system components
│   ├── alert_dialog.dart        # iOS-style AppAlertDialog
│   ├── auth_bottom_sheet.dart   # Unified authentication bottom sheet
│   ├── auth_input_field.dart    # Form input field widget
│   ├── bottomSheet.dart         # Standard bottom sheet layout
│   ├── bottom_sheet_header.dart # Reusable header for bottom sheets
│   ├── button.dart              # AppButton (primary, secondary, danger, ghost)
│   ├── card.dart                # Therapy session card item
│   ├── forgot_password_form.dart# Password reset form
│   ├── grouped_list.dart        # iOS-style grouped list view & tiles
│   ├── header.dart              # AppHeader widget (compact, large, inline)
│   ├── login_form.dart          # User authentication login view
│   ├── menu.dart                # Context menu & action sheet
│   ├── mode_badge.dart          # Therapy mode visual badge
│   ├── ota_notification.dart    # OTA firmware update notification banner
│   ├── register_form.dart       # Account registration view
│   ├── sectionHistory.dart      # Grouped therapy history list
│   ├── splitButton.dart         # Dual-action split button widget
│   ├── stepper.dart             # Custom increment/decrement stepper
│   └── text.dart                # AppText typography system
├── data/                        # Local mock & seed data
│   └── dummyData.json           # Development dummy data fallback
├── db/                          # Database persistence layer
│   └── database_helper.dart     # SQLite singleton manager & queries
├── models/                      # Business & transfer models
│   ├── auth_form_data.dart      # Auth state validation model
│   ├── device_credentials.dart  # VAC device connection credentials
│   ├── register_dto.dart        # Account registration DTO
│   └── therapy_session.dart     # TherapySession entity model
├── network/                     # Network middleware
│   └── api_interceptor.dart     # HTTP request interceptor & error handling
├── repositories/                # Data storage abstraction layer
│   ├── auth_repository.dart     # Secure token & credential persistence
│   └── settings_repository.dart # User preferences (theme mode)
├── screens/                     # Primary app screens
│   ├── homeScreens.dart         # Main dashboard & active session summary
│   ├── historyScreens.dart      # Session history list & year filtering
│   ├── deviceScreens.dart       # Real-time BLE device control screen
│   ├── scanScreens.dart         # QR code device scanning page
│   ├── settingsScreen.dart      # Settings, theme toggle & account details
│   ├── welcomeScreens.dart      # Onboarding welcome page
│   └── wifiScreens.dart         # VAC device Wi-Fi provisioning page
├── services/                    # Background & business services
│   ├── api_service.dart         # REST API communication client
│   ├── ble_service.dart         # BLE connection, scanning, & characteristic streams
│   ├── ota_banner_service.dart  # OTA firmware update banner manager
│   ├── therapy_receiver.dart    # Live therapy data packet stream handler
│   └── therapy_sync_service.dart# Sync bridge between SQLite and Cloud API
└── utils/                       # Utility helpers
    ├── mode_color.dart          # Badge color lookup per therapy mode
    └── text_styles.dart         # Typography text style utilities
```

---

## Data Layer & Storage

### SQLite Local Database
Managed by [DatabaseHelper](file:///home/broo/Documents/apps/vac_dashboard_app/lib/db/database_helper.dart) (`vac_dashboard.db`, Version `2`).

#### Table Schema: `therapy_sessions`

| Column | Data Type | Modifiers | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Local unique identifier |
| `session_date` | `TEXT` | `NOT NULL` | ISO Date string (`YYYY-MM-DD...`) used for year filtering |
| `title` | `TEXT` | `NOT NULL` | Session display name / title |
| `date` | `TEXT` | `NOT NULL` | User-formatted date display string |
| `mode` | `TEXT` | `NOT NULL` | Therapy mode (`Kontinyu` or `Intermiten`) |
| `duration` | `TEXT` | `NOT NULL` | Session duration representation |
| `is_synced` | `INTEGER` | `NOT NULL DEFAULT 0` | `0` = Unsynced local, `1` = Synced to cloud |

### Secure Credentials Storage
The [AuthRepository](file:///home/broo/Documents/apps/vac_dashboard_app/lib/repositories/auth_repository.dart) uses `flutter_secure_storage` to encrypt sensitive user authorization tokens and device credentials using hardware Keystore (Android) and Keychain (iOS).

---

## Therapy Modes & BLE Telemetry

The VAC STECHOQ device operates in two primary therapy modes:

| Mode | Visual Theme | Description |
| :--- | :--- | :--- |
| **Kontinyu (Continuous)** | `Blue` | Continuous negative pressure wound therapy. |
| **Intermiten (Intermittent)** | `Orange` | Cycled suction and release intervals. |

Live telemetry packets received over Bluetooth Low Energy via [therapy_receiver.dart](file:///home/broo/Documents/apps/vac_dashboard_app/lib/services/therapy_receiver.dart) are parsed real-time, displayed on [deviceScreens.dart](file:///home/broo/Documents/apps/vac_dashboard_app/lib/screens/deviceScreens.dart), and persisted to SQLite upon session completion.

---

## How-to: Development Setup

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) version `^3.12.2`
- Android Studio / Xcode configured for Flutter development
- Physical Android or iOS device (recommended for testing Bluetooth BLE & Camera features)

### 1. Install Dependencies
Clone the repository and install all required packages:
```bash
flutter pub get
```

### 2. Run Application
Run on a connected target device:
```bash
flutter run
```

### 3. Run Static Code Analysis & Tests
Execute linter and test suite:
```bash
flutter analyze
flutter test
```

---

## Component Sandbox
For developer UI testing and component previews, `ComponentSandboxPage` in [main.dart](file:///home/broo/Documents/apps/vac_dashboard_app/lib/main.dart) provides live showcases for Typography, Buttons, Steppers, Grouped Lists, and Custom Alert Dialogs.
