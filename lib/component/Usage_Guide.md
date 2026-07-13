# VAC Dashboard Component Usage Guide

Panduan ini mendokumentasikan cara menggunakan komponen-komponen antarmuka (UI components) yang dapat digunakan kembali (*reusable*) di aplikasi VAC Dashboard. Seluruh komponen didesain untuk merepresentasikan gaya visual iOS/macOS modern yang konsisten.

---

## 1. AppText (`text.dart`)
Komponen dasar untuk menampilkan teks dengan tipografi *SF Pro* (atau *system font* bawaan) secara terstruktur berdasarkan hierarki tipografi.

### Usage
```dart
import 'package:vac_dashboard_app/component/text.dart';

// Standar
AppText('Hello World', type: AppTextType.title1);

// Dengan styling kustom
AppText(
  'Total Value',
  type: AppTextType.subheadline,
  customColor: Colors.blue,
  fontWeight: FontWeight.bold,
  textAlign: TextAlign.center,
);
```

### Variants (`AppTextType`)
- `largeTitle` (34px, w400)
- `title1` (28px, w400)
- `title2` (22px, w400)
- `title3` (20px, w400)
- `headline` (17px, w600)
- `body` (17px, w400)
- `callout` (16px, w400)
- `subheadline` (15px, w400)
- `footnote` (13px, w400)
- `caption1` (12px, w400)
- `caption2` (11px, w400)

---

## 2. AppButton (`button.dart`)
Tombol fleksibel dengan variasi warna (*variant*) dan ukuran (*size*). Juga mendukung pembuatan tombol bulat khusus ikon (*icon-only*).

### Usage
```dart
import 'package:vac_dashboard_app/component/button.dart';

// Primary button
AppButton(
  label: 'Submit',
  variant: ButtonVariant.primary,
  size: ButtonSize.medium,
  onPressed: () {},
);

// Tombol dengan Ikon (Leading & Trailing)
AppButton(
  label: 'Settings',
  icon: Icons.settings,
  trailingIcon: Icons.chevron_right,
  variant: ButtonVariant.tertiary,
  onPressed: () {},
);

// Icon Only (otomatis menjadi bulat)
AppButton(
  icon: Icons.add,
  size: ButtonSize.iconOnly, // ukuran 44px
  variant: ButtonVariant.primary,
  onPressed: () {},
);
```

### Variants (`ButtonVariant`)
- `primary`: Biru (`0xFF007AFF`) dengan teks putih.
- `secondary`: Abu-abu transparan iOS (`0x28787880`) dengan teks hitam (contoh pada dialog).
- `tertiary`: Abu-abu tipis (`0x1E767680`) dengan teks sekunder.
- `destructive`: Latar merah tipis dengan teks merah terang (untuk hapus/keluar).
- `ghost`: Tanpa *background* (Gaya legasi, disarankan menggunakan properti `isGhost: true`).
- `elevated`: Latar putih dengan bayangan *drop-shadow*.

### Properti Tambahan
- `isGhost` (bool): Jika `true`, tombol tidak memiliki warna latar belakang (menjadi transparan) dan warna teks/ikon otomatis mengikuti warna khas dari varian yang dipilih (misalnya teks menjadi biru pada `variant: ButtonVariant.primary`, atau merah pada `variant: ButtonVariant.destructive`).

### Sizes (`ButtonSize`)
- `small` (Height 28px)
- `medium` (Height 34px)
- `large` (Height 50px)
- `iconOnly` (Membentuk lingkaran 44pxx44px)

---

## 3. AppHeader (`header.dart`)
Bagian atas (*AppBar*) standar yang menampilkan gaya modern dengan opsi varian gaya *acrylic* (transparan dengan *blur* iOS) atau standar.

### Usage
```dart
import 'package:vac_dashboard_app/component/header.dart';

AppHeader(
  title: 'Dashboard',
  variant: AppHeaderVariant.primary, // atau secondary / acrylic
  leading: const Icon(Icons.arrow_back), // Opsional
  trailing: const Icon(Icons.notifications), // Opsional
  onLeadingPressed: () => Navigator.pop(context),
)
```

### Variants
- `primary`: Background putih polos, judul besar di tengah (`title3`).
- `secondary`: Background transparan, judul besar di kiri (`title1`).
- `acrylic`: Efek kaca (Glassmorphism/Blur) khas iOS di *background*, judul di tengah.

---

## 4. SplitButton (`splitButton.dart`)
Tombol aksi ganda yang memungkinkan pengguna untuk melakukan satu aksi utama (klik label) atau membuka *dropdown menu* berlapis kaca untuk memilih opsi lain.

### Usage
```dart
import 'package:vac_dashboard_app/component/splitButton.dart';
import 'package:vac_dashboard_app/component/menu.dart';

SplitButton(
  label: 'Export',
  size: SplitButtonSize.medium,
  variant: SplitButtonVariant.outline, // outline / solid / ghost
  onPressed: () {
    print('Aksi Utama dieksekusi!');
  },
  // Menu list akan otomatis muncul ketika panah dropdown ditekan
  menuItems: [
    AppMenuItem(
      label: 'Export as CSV',
      leadingIcon: Icons.file_download,
      onPressed: () => print('CSV'),
    ),
    AppMenuItem(
      label: 'Export as PDF',
      leadingIcon: Icons.picture_as_pdf,
      onPressed: () => print('PDF'),
    ),
  ],
);
```

---

## 5. AppContextMenu (`menu.dart`)
Komponen menu bergaya iOS *glassmorphism* (sudut melengkung, efek *blur*, pemisah baris) yang digunakan secara internal oleh `SplitButton` tetapi juga dapat dipanggil secara manual jika dibutuhkan.

### Usage (Standalone Pop-up)
Umumnya digunakan bersama `showDialog` yang menempatkan menu pada koordinat spesifik.
```dart
import 'package:vac_dashboard_app/component/menu.dart';

showDialog(
  context: context,
  barrierColor: Colors.transparent,
  builder: (context) {
    return Stack(
      children: [
        Positioned(
          left: 100, // Koordinat X
          top: 200,  // Koordinat Y
          child: AppContextMenu(
            width: 250,
            children: [
              AppMenuActionRow(
                label: 'Edit',
                leadingIcon: Icons.edit,
                onPressed: () {},
              ),
              const AppMenuDivider(),
              AppMenuActionRow(
                label: 'Delete',
                leadingIcon: Icons.delete,
                isDestructive: true, // Warna teks menjadi merah
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  },
);
```

---

## 6. AppAlertDialog (`alert_dialog.dart`)
Dialog konfirmasi dengan *layout* tombol fleksibel (horizontal atau vertikal) lengkap dengan efek kaca ala macOS/iOS (Backdrop Filter blur & transparan).

### Usage
```dart
import 'package:vac_dashboard_app/component/alert_dialog.dart';

showAppAlertDialog(
  context,
  title: 'Are you sure?',
  description: 'This action cannot be undone and your data will be lost forever.',
  primaryButtonLabel: 'Delete',
  onPrimaryPressed: () {
    // Jalankan aksi
    Navigator.of(context).pop();
  },
  secondaryButtonLabel: 'Cancel',
  onSecondaryPressed: () => Navigator.of(context).pop(),
  // Opsi: horizontal atau vertical
  buttonLayout: AppAlertDialogButtonLayout.vertical, 
  
  // Opsional: Jika ingin menampilkan list "Value" khusus
  content: const AppAlertContentList(
    items: ['Session Data', 'User Logs'],
  ),
);
```

---

## 7. AppStepper (`stepper.dart`)
Stepper bergaya iOS kustom untuk menaikkan atau menurunkan suatu nilai numerik. Memiliki desain kapsul terintegrasi dengan pembatas tipis di tengah, serta mendukung kondisi nonaktif (*disabled state*) jika callback bernilai `null`.

### Usage
```dart
import 'package:vac_dashboard_app/component/stepper.dart';

AppStepper(
  onIncrement: () {
    print('Increment!');
  },
  onDecrement: () {
    print('Decrement!');
  },
  // Lebar dan tinggi opsional (default: width 92, height 32)
  width: 92.0,
  height: 32.0,
);

// Contoh dengan state management: Menonaktifkan Decrement jika nilai sudah 0
int counter = 0;
AppStepper(
  onIncrement: () => setState(() => counter++),
  onDecrement: counter > 0 ? () => setState(() => counter--) : null, // Disabled if counter <= 0
);
```

---

## 8. AppGroupedList & AppGroupedListTile (`grouped_list.dart`)
Komponen daftar berkelompok (*grouped list*) bergaya iOS/Form. Baris-baris dibungkus di dalam kartu melengkung dengan pembatas tipis (*divider*) otomatis di antara setiap elemennya. Komponen ini sepenuhnya menggunakan Material Icons (`Icons.check`, `Icons.chevron_right_rounded`) untuk tombol aksi visualnya.

### Usage
```dart
import 'package:vac_dashboard_app/component/grouped_list.dart';

AppGroupedList(
  children: [
    // Tile Standard
    AppGroupedListTile(
      title: 'Profile Settings',
      detail: 'Update your personal info',
      showChevron: true,
      onTap: () {
        print('Go to profile settings');
      },
    ),
    
    // Tile dengan Subtitle & Checkmark
    AppGroupedListTile(
      title: 'Notifications',
      subtitle: 'Enable push alerts',
      showCheckmark: true,
      onTap: () {
        print('Toggle notifications');
      },
    ),
    
    // Tile dengan Capsule Badge
    AppGroupedListTile(
      title: 'Current Term',
      badgeLabel: 'June 2024',
      onTap: () {
        print('Show calendar');
      },
    ),
    
    // Tile dengan Widget Custom di Trailing (contoh: AppButton)
    AppGroupedListTile(
      title: 'Auto-sync',
      trailing: Switch(
        value: true,
        onChanged: (val) {},
      ),
    ),
    
    // Tile dengan Avatar / Gambar Leading
    AppGroupedListTile(
      title: 'John Doe',
      subtitle: 'Premium Member',
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          'https://placehold.co/68x68',
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      ),
      onTap: () {},
    ),
  ],
);
```

---

## Kesimpulan Best Practices
1. **DRY (Don't Repeat Yourself):** Jika butuh teks, gunakan `AppText`. Jika butuh tombol, gunakan `AppButton`. Hindari menggunakan `Text` atau `ElevatedButton` bawaan secara langsung jika desainnya dapat dicapai dengan varian yang ada.
2. **Konsistensi Warna & Font:** Komponen-komponen di atas sudah membungkus kode *hex* (*opacity*/transparansi), bobot font (*FontWeight*), dan ukuran secara ketat (Sistem SF Pro).
3. **Modifikasi Varian:** Jika mendapati *style* baru di desain Figma yang mirip tapi tak sama, tambahkan sebagai **Variant** baru pada *enum* di komponen terkait, jangan buat kelas komponen *widget* baru.
