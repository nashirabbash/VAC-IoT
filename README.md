# VAC STECHOQ Dashboard App

A cross-platform Flutter application (Android, iOS, Web) designed for real-time therapy monitoring, device control, and session tracking for the **VAC STECHOQ** (Vacuum Assisted Closure) medical device.

The app supports Bluetooth Low Energy (BLE) connectivity for live hardware telemetrics, offline-first local session history storage via SQLite (`sqflite`), secure authentication token management (`flutter_secure_storage`), cloud REST API synchronization, and adaptive dark/light design token styling.

## 📖 Technical Overview & Diátaxis Framework

This documentation is structured according to the [Diátaxis Framework](https://diataxis.fr/) across four distinct documentation quadrants:

- **Tutorials:** Step-by-step onboarding walkthrough for developers joining the project.
- **How-to Guides:** Actionable instructions for environment setup, app execution, static analysis, unit testing, and using the component sandbox.
- **Reference:** Technical specifications including SQLite database schema, dependency catalog, and codebase directory layout.
- **Explanation:** In-depth technical discussions on architecture design, BLE stream processing, offline synchronization, and state management.

## 📌 Key Features

- **BLE Device Pairing & Telemetry:** Connects to VAC hardware via `flutter_blue_plus`, subscribes to real-time therapy data streams, and enables device control.
- **Offline-First Therapy History:** Persists therapy session records in a local SQLite database (`vac_dashboard.db`).
- **Cloud API Synchronization:** Automatically or manually synchronizes unsynced local session records to the remote REST backend.
- **QR Code Connectivity:** Integrated QR scanner via `mobile_scanner` for rapid device and Wi-Fi credential provisioning.
- **Adaptive Design Token System:** Cupertino & Material combined styling with automatic light/dark mode support ([lib/asset/color_tokens.dart](lib/asset/color_tokens.dart)).
- **OTA Updates Banner:** Notifies users of Over-The-Air firmware updates for connected VAC hardware.

## 🛠️ Technology Stack & Dependencies

### Runtime Dependencies (`dependencies`)

| Dependency | Version | Purpose |
| :--- | :--- | :--- |
| **Flutter SDK** | `^3.12.2` | Core application framework |
| **sqflite** | `^2.4.3` | Local SQLite database engine |
| **flutter_blue_plus** | `^1.32.12` | Bluetooth Low Energy scanning, connecting, and streaming |
| **flutter_secure_storage** | `^10.3.1` | Encrypted storage for JWT auth tokens and device credentials |
| **http** | `^1.3.0` | REST API HTTP client |
| **mobile_scanner** | `^7.2.0` | QR Code scanner engine |
| **camera** | `^0.10.6` | Camera hardware module integration |
| **path** | `^1.9.1` | Cross-platform file path helper |

### Development & Build Dependencies (`dev_dependencies`)

| Dependency | Version | Purpose |
| :--- | :--- | :--- |
| **flutter_test** | `sdk: flutter` | Unit and widget testing framework |
| **flutter_lints** | `^6.0.0` | Recommended lint rules for Flutter apps |
| **mocktail** | `^1.0.5` | Mocking library for Dart testing |
| **flutter_native_splash** | `^2.4.6` | Native launch splash screen generator |

## 🏗️ System & Directory Architecture

The application adopts a modular multi-tier architecture isolating user interfaces, background business logic, and local/remote persistence layers.

```mermaid
flowchart TD
    accTitle: VAC STECHOQ Dashboard System Architecture
    accDescr: Component architecture showing user interfaces, background services, persistence layers, hardware BLE interfaces, and cloud REST integration.

    subgraph UI["📱 UI & Screen Layer"]
        home_screen["🏠 HomeScreen<br/>(Dashboard & Summary)"]
        device_screen["⚡ DeviceScreen<br/>(Real-Time Control)"]
        history_screen["📜 HistoryScreen<br/>(Session Log & Filter)"]
        scan_screen["📷 ScanScreen<br/>(QR Provisioning)"]
        settings_screen["⚙️ SettingsScreen<br/>(Theme & Account)"]
    end

    subgraph SERVICES["⚙️ Services & Business Logic"]
        ble_service["📡 BleService<br/>(Scan & GATT Connection)"]
        therapy_receiver["📊 TherapyReceiver<br/>(Live Telemetry Stream)"]
        therapy_sync["🔄 TherapySyncService<br/>(Offline Sync Bridge)"]
        api_service["🌐 ApiService<br/>(REST API Client)"]
        ota_service["🔔 OtaBannerService<br/>(Firmware Notifier)"]
    end

    subgraph DATA["💾 Persistence & Repositories"]
        auth_repo["🔒 AuthRepository<br/>(Token & Credentials)"]
        db_helper["🗄️ DatabaseHelper<br/>(SQLite Singleton)"]
        secure_storage["🔑 Secure Storage<br/>(Keystore / Keychain)"]
        sqlite_db[("💾 vac_dashboard.db<br/>(therapy_sessions)")]
    end

    subgraph EXTERNAL["🔌 External Ecosystem"]
        vac_hardware["📟 VAC STECHOQ Device<br/>(BLE Hardware)"]
        cloud_backend["☁️ Cloud REST Backend<br/>(Server API)"]
    end

    UI --> SERVICES
    device_screen --> ble_service
    device_screen --> therapy_receiver
    scan_screen --> ble_service
    
    SERVICES --> DATA
    therapy_receiver --> db_helper
    therapy_sync --> db_helper
    therapy_sync --> api_service
    auth_repo --> secure_storage
    db_helper --> sqlite_db

    ble_service <-->|"BLE GATT"| vac_hardware
    api_service <-->|"HTTPS / REST"| cloud_backend

    classDef uiStyle fill:#e0f2fe,stroke:#0284c7,stroke-width:2px,color:#0369a1
    classDef serviceStyle fill:#f0fdf4,stroke:#16a34a,stroke-width:2px,color:#15803d
    classDef dataStyle fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#b45309
    classDef extStyle fill:#fae8ff,stroke:#c026d3,stroke-width:2px,color:#86198f

    class home_screen,device_screen,history_screen,scan_screen,settings_screen uiStyle
    class ble_service,therapy_receiver,therapy_sync,api_service,ota_service serviceStyle
    class auth_repo,db_helper,secure_storage,sqlite_db dataStyle
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
│   └── database_helper.dart     # SQLite singleton manager & queries
├── models/                      # Business & data transfer models
│   ├── auth_form_data.dart      # Auth form state validation model
│   ├── device_credentials.dart  # VAC device connection credentials
│   ├── register_dto.dart        # Registration payload DTO
│   └── therapy_session.dart     # TherapySession entity model
├── network/                     # Network middleware
│   └── api_interceptor.dart     # HTTP request interceptor & error handler
├── repositories/                # Data repository layer
│   ├── auth_repository.dart     # Secure token & credential persistence
│   └── settings_repository.dart # Preferences repository (theme mode)
├── screens/                     # Primary user interface screens
│   ├── homeScreens.dart         # Main dashboard & active session summary
│   ├── historyScreens.dart      # Session history list & year filtering
│   ├── deviceScreens.dart       # Real-time BLE device control screen
│   ├── scanScreens.dart         # QR code device scanning screen
│   ├── settingsScreen.dart      # Settings, theme toggle & account details
│   ├── welcomeScreens.dart      # Onboarding welcome screen
│   └── wifiScreens.dart         # VAC device Wi-Fi configuration screen
├── services/                    # Business logic & background services
│   ├── api_service.dart         # REST API client service
│   ├── ble_service.dart         # BLE scanning, connecting & GATT characteristic streams
│   ├── ota_banner_service.dart  # OTA firmware update banner manager
│   ├── therapy_receiver.dart    # Live therapy packet stream handler
│   └── therapy_sync_service.dart# Synchronization bridge between SQLite and Cloud API
└── utils/                       # Utility helpers
    ├── mode_color.dart          # Therapy mode visual badge color resolver
    └── text_styles.dart         # Typography text style utilities
```

## 💾 Data Layer & Storage

### SQLite Local Database
Managed by [DatabaseHelper](lib/db/database_helper.dart) (`vac_dashboard.db`, Version `2`).

#### Table Schema: `therapy_sessions`

| Column | Data Type | Modifiers | Description |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` | Local session record identifier |
| `session_date` | `TEXT` | `NOT NULL` | ISO Date string (`YYYY-MM-DD...`) used for year filtering |
| `title` | `TEXT` | `NOT NULL` | Session title / display name |
| `date` | `TEXT` | `NOT NULL` | User-formatted date string |
| `mode` | `TEXT` | `NOT NULL` | Therapy mode (`Kontinyu` or `Intermiten`) |
| `duration` | `TEXT` | `NOT NULL` | Therapy session duration |
| `is_synced` | `INTEGER` | `NOT NULL DEFAULT 0` | `0` = Unsynced local session, `1` = Synced to cloud |

### Entity Relationship Diagram

```mermaid
erDiagram
    accTitle: SQLite Database and Storage Entity Relationship
    accDescr: Entity relationship diagram representing local SQLite tables and encrypted key-value pairs stored in secure storage.

    THERAPY_SESSIONS {
        int id PK "Auto Increment Local ID"
        string session_date "ISO format YYYY-MM-DD for year filter"
        string title "Session display title"
        string date "Formatted display date"
        string mode "Kontinyu or Intermiten"
        string duration "Duration string"
        int is_synced "0 = Local only, 1 = Cloud synced"
    }

    SECURE_STORAGE {
        string jwt_auth_token PK "Encrypted Auth Token"
        string device_mac_address "Saved VAC Hardware MAC"
        string wifi_credentials "Encrypted SSID & Password"
    }

    APP_SETTINGS {
        string theme_mode "light or dark or system"
    }

    THERAPY_SESSIONS ||--o| SECURE_STORAGE : "authenticated by"
    APP_SETTINGS ||--o| THERAPY_SESSIONS : "styles UI display for"
```

### Offline-First Cloud Synchronization Flow

```mermaid
flowchart TD
    accTitle: Offline-First Synchronization Decision Flowchart
    accDescr: Decision flowchart showing local session persistence and conditional remote cloud REST API sync logic.

    start_sync(["🚀 Trigger Sync Operation"]) --> check_net{"📡 Network Available?"}

    check_net -- "No (Offline)" --> store_offline["💾 Store Session in SQLite<br/>(is_synced = 0)"]
    store_offline --> notify_user["ℹ️ Display Saved Locally Status"]

    check_net -- "Yes (Online)" --> fetch_unsynced["🔍 Query SQLite for<br/>is_synced == 0"]
    fetch_unsynced --> has_records{"📋 Unsynced Sessions Exist?"}

    has_records -- "No" --> sync_complete(["✅ DB Up To Date"])
    has_records -- "Yes" --> iterate_sessions["🔄 Loop Unsynced Session Batch"]

    iterate_sessions --> send_api["🌐 Send POST /api/sessions"]
    send_api --> api_success{"Response 200/201?"}

    api_success -- "Yes" --> mark_synced["✏️ Update SQLite DB<br/>(is_synced = 1)"]
    mark_synced --> next_session{"More Sessions?"}
    next_session -- "Yes" --> iterate_sessions
    next_session -- "No" --> sync_done(["🎉 Cloud Sync Complete"])

    api_success -- "No (Error/Timeout)" --> log_error["⚠️ Log Sync Failure"]
    log_error --> keep_local["🔒 Keep is_synced = 0 for Retry"]
    keep_local --> sync_done

    classDef startStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e3a5f
    classDef decisionStyle fill:#fef9c3,stroke:#ca8a04,stroke-width:2px,color:#713f12
    classDef actionStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#14532d
    classDef warnStyle fill:#fee2e2,stroke:#dc2626,stroke-width:2px,color:#991b1b

    class start_sync,sync_complete,sync_done startStyle
    class check_net,has_records,api_success,next_session decisionStyle
    class store_offline,fetch_unsynced,iterate_sessions,send_api,mark_synced actionStyle
    class log_error,keep_local warnStyle
```

### Secure Credentials Storage
The [AuthRepository](lib/repositories/auth_repository.dart) utilizes `flutter_secure_storage` to encrypt sensitive user authorization tokens and device connection credentials via Keystore on Android and Keychain on iOS.

## ⚡ Therapy Modes & BLE Telemetry

The VAC STECHOQ device operates in two primary therapy modes:

| Mode | Visual Badge Color | Description |
| :--- | :--- | :--- |
| **Kontinyu (Continuous)** | `Blue` | Continuous negative pressure wound therapy. |
| **Intermiten (Intermittent)** | `Orange` | Cycled suction and release intervals. |

Live telemetry packets received over Bluetooth Low Energy via [therapy_receiver.dart](lib/services/therapy_receiver.dart) are processed real-time, displayed on [deviceScreens.dart](lib/screens/deviceScreens.dart), and persisted to SQLite upon session completion.

### Device State & Connection Lifecycle

```mermaid
stateDiagram-v2
    accTitle: VAC STECHOQ Device and Therapy Lifecycle
    accDescr: State machine diagram detailing BLE connection states and therapy operation modes from idle to completed session.

    [*] --> Disconnected

    state Connection_Phase {
        Disconnected --> Scanning : Start BLE Scan
        Scanning --> Connecting : Device Discovered / QR Paired
        Connecting --> Connected : GATT Handshake Success
        Connecting --> Disconnected : Connection Timeout / Failed
    }

    state Therapy_Phase {
        Connected --> Idle : Ready for Therapy
        
        state Mode_Selection {
            Idle --> KontinyuMode : Select Continuous Mode
            Idle --> IntermitenMode : Select Intermittent Mode
        }

        state Active_Therapy {
            KontinyuMode --> TherapyRunning : Suction Active (Constant)
            IntermitenMode --> TherapyRunning : Suction Active (Cycled)
            TherapyRunning --> TherapyPaused : User Pause
            TherapyPaused --> TherapyRunning : Resume
        }

        TherapyRunning --> SessionCompleted : Stop Therapy / Timer Reached
    }

    SessionCompleted --> SavingLocal : Write to SQLite DB
    SavingLocal --> SyncingCloud : TherapySyncService Active
    SyncingCloud --> Idle : Session Sync Finished
    Connected --> Disconnected : Device Disconnected / Link Lost
```

## 🔄 End-to-End Therapy & Data Flow

The following sequence illustrates how therapy commands, live telemetry streams, local storage persistence, and remote cloud REST API synchronization interact during an end-to-end therapy session.

```mermaid
sequenceDiagram
    accTitle: End-to-End Therapy Session and Cloud Sync Flow
    accDescr: Sequence diagram illustrating device connection, telemetry stream reception, session completion local persistence, and cloud sync.

    actor User
    participant UI as 📱 DeviceScreen / UI
    participant BLE as 📡 BleService
    participant VAC as 📟 VAC Hardware
    participant Rx as 📊 TherapyReceiver
    participant DB as 🗄️ DatabaseHelper (SQLite)
    participant Sync as 🔄 TherapySyncService
    participant API as ☁️ Cloud REST API

    User->>UI: 1. Select Therapy Mode (Kontinyu / Intermiten) & Start
    UI->>BLE: 2. Send Start Command via GATT Characteristic
    BLE->>VAC: 3. BLE Command Write
    VAC-->>BLE: 4. Command Acknowledged & Suction Started
    
    loop Real-Time Telemetry Stream
        VAC-->>BLE: 5. BLE Notification (Pressure, Duration, Mode)
        BLE-->>Rx: 6. Forward Data Packet Stream
        Rx-->>UI: 7. Emit Live Telemetry to Dashboard UI
    end

    User->>UI: 8. Stop Therapy Session
    UI->>BLE: 9. Send Stop Command
    BLE->>VAC: 10. BLE Command Write
    
    UI->>DB: 11. Save Session Record (is_synced = 0)
    DB-->>UI: 12. Session Saved Locally

    opt Background / Automatic Cloud Sync
        Sync->>DB: 13. Query Unsynced Sessions (is_synced = 0)
        DB-->>Sync: 14. Return Unsynced Session List
        Sync->>API: 15. POST /api/therapy-sessions (Payload)
        API-->>Sync: 16. HTTP 201 Created Confirmation
        Sync->>DB: 17. Update Record (is_synced = 1)
        DB-->>Sync: 18. Sync Status Updated
    end
```

## 🚀 How-to: Developer Walkthrough & Setup

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) version `^3.12.2`
- Android Studio or Xcode configured for mobile development
- Physical Android or iOS device (recommended for Bluetooth BLE and Camera testing)

### Getting Started (Tutorial)
1. **Clone the repository** and navigate to the project directory:
   ```bash
   git clone https://github.com/nashirabbash/VAC-IoT.git
   cd vac_dashboard_app
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Launch the application** on a connected device:
   ```bash
   flutter run
   ```

### Code Quality & Testing
Run static analysis and the test suite:
```bash
flutter analyze
flutter test
```

### Component Sandbox
For interactive UI component testing, `ComponentSandboxPage` inside [lib/main.dart](lib/main.dart) provides live showcases for Typography, Buttons, Steppers, Grouped Lists, and Custom Alert Dialogs.
