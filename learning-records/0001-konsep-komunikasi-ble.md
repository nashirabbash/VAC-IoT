# Learning Record 0001: Konsep Komunikasi BLE pada VAC STECHOQ

- **Tanggal**: 2026-07-29
- **Topik**: Konsep Komunikasi Bluetooth Low Energy (BLE)
- **Status**: Completed

## Insight Kunci
1. **Peran Komunikasi**: Smartphone bertindak sebagai GATT Client, sedangkan alat VAC STECHOQ (ESP32) bertindak sebagai GATT Server dan Advertiser.
2. **Duplex Channel via GATT Characteristics**:
   - `RX Characteristic` (`c083...`): Tempat Flutter menulis pesan JSON (Command/Auth/Time Sync).
   - `TX Characteristic` (`6e40...`): Tempat Flutter mendengarkan notifikasi streaming JSON dari perangkat (Status WiFi, Therapy Events).
3. **Tahapan Handshake**: Setelah koneksi & discovery service berhasil, Flutter langsung melakukan 2 hal otomatis:
   - Pengiriman `auth` JSON berisi PIN keamanan.
   - Pengiriman `time_sync` JSON berisi Unix timestamp terkini untuk menyelaraskan jam internal alat.
4. **Manajemen Proksimitas RSSI**: Pemantauan nilai RSSI dilakukan secara berkala (tiap 4 detik). Jika sinyal lemah (< -85 dBm) sebanyak 3 kali berturut-turut, koneksi diputus secara terkontrol (*auto-disconnect due to far distance*).

## Zone of Proximal Development Selanjutnya
- Simulasi pengujian koneksi BLE menggunakan Mock `flutter_blue_plus`.
- Penanganan error transmisi data & strategi pengolahan buffer data besar.
