# Mission: Memahami Komunikasi BLE pada VAC STECHOQ Dashboard

## Mengapa Mempelajari Ini?
Aplikasi **VAC STECHOQ Dashboard** bergantung pada koneksi Bluetooth Low Energy (BLE) untuk berkomunikasi secara real-time dengan perangkat perangkat medis VAC (Vacuum Assisted Closure). Memahami arsitektur komunikasi BLE ini penting untuk memelihara aplikasi, menambah fitur pengiriman/penerimaan data terapi, serta melakukan debugging koneksi hardware.

## Target Pembelajaran (Skills & Knowledge)
1. **Peran Central vs Peripheral** dalam konteks Smartphone (Flutter App) dan Perangkat VAC (ESP32/Hardware).
2. **Struktur GATT (Generic Attribute Profile)**: Service UUID, RX (Write), dan TX (Notify/Indicate).
3. **Alur Lifecycle BLE**: Scan Filter -> Connect -> Service Discovery -> Notification Subscription -> Handshake (Auth & Time Sync).
4. **Format & Parser Protokol Payload**: JSON berformat UTF-8 untuk perintah dan *therapy events*.
5. **Manajemen Proksimitas & Auto-Reconnect**: Pemantauan RSSI (Received Signal Strength Indicator) dan strategi *failover/reconnection*.

## Kriteria Keberhasilan
- Mampu menjelaskan secara runtut alur data saat smartphone terhubung ke VAC STECHOQ.
- Mampu mengidentifikasi fungsi masing-masing UUID (`_serviceUuid`, `_rxUuid`, `_txUuid`) di `lib/services/ble_service.dart`.
- Mampu merancang/memahami pengiriman payload JSON baru jika ada perintah baru dari app ke hardware.
