# Resources: Bluetooth Low Energy (BLE) di VAC STECHOQ

## Source Code Utama
- [BleService (`lib/services/ble_service.dart`)](file:///home/broo/Documents/apps/vac_dashboard_app/lib/services/ble_service.dart) - Implementasi singleton manajemen BLE di Flutter.
- [TherapyReceiver (`lib/services/therapy_receiver.dart`)](file:///home/broo/Documents/apps/vac_dashboard_app/lib/services/therapy_receiver.dart) - Handler penanganan event & penyimpanan database sesi terapi.

## Dokumentasi & Spesifikasi Resmi
- [Flutter Blue Plus Package Documentation](https://pub.dev/packages/flutter_blue_plus) - Package BLE resmi yang digunakan pada aplikasi ini.
- [Bluetooth Core Specification - GATT Architecture](https://www.bluetooth.com/specifications/specs/) - Core specification mengenai GATT Server/Client, Services, dan Characteristics.

## Konsep Kunci
- **GATT Server**: Perangkat Hardware VAC (ESP32) yang menyediakan data/layanan.
- **GATT Client**: Aplikasi Flutter di Smartphone yang membaca dan menulis data ke server.
- **Characteristic RX (Write)**: Channel pengiriman data dari App ke VAC.
- **Characteristic TX (Notify)**: Channel penerimaan data dari VAC ke App secara asynchronous.
