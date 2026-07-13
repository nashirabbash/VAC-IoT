# vac_dashboard_app — VAC STECHOQ Dashboard

Flutter mobile app (Android/iOS/Web) sebagai dashboard monitoring sesi terapi untuk perangkat **VAC STECHOQ** (Vacuum Assisted Closure). Menampilkan riwayat sesi terapi yang tersimpan di SQLite lokal, dengan koneksi Bluetooth (flutter_blue_plus) ke perangkat.

**Target platform:** Android (utama), iOS, Web  
**Flutter SDK:** ^3.12.2  
**Entry point:** `lib/main.dart`

## Dependensi Kunci

| Package             | Versi    | Kegunaan                     |
| ------------------- | -------- | ---------------------------- |
| `sqflite`           | ^2.4.2   | Database lokal sesi terapi   |
| `flutter_blue_plus` | ^1.32.12 | Koneksi BLE ke perangkat VAC |
| `path`              | ^1.9.1   | Helper path database         |

---

## Struktur `lib/`

```
lib/
├── main.dart                    # Entry point — StatefulWidget tunggal, load data, filter per tahun
│
├── asset/
│   ├── color_tokens.dart        # AppColorTokenSet — Design system tokens (context.colors) mendukung Dark Mode
│   └── color.dart               # AppColors (Legacy)
│
├── component/                   # Widget reusable UI
│   ├── alert_dialog.dart        # iOS-style Alert Dialog & confirmation popups
│   ├── auth_bottom_sheet.dart   # Bottom sheet terpadu (Login, Register, Forgot Password)
│   ├── bottomSheet.dart         # Bottom sheet (detail sesi / form input)
│   ├── bottom_sheet_header.dart # Header standard untuk semua bottom sheet
│   ├── card.dart                # Card satu sesi terapi
│   ├── grouped_list.dart        # List bergaya iOS grouped (Settings, Input Form)
│   ├── header.dart              # Header app bar / judul halaman
│   ├── menu.dart                # iOS-style Context menu / action sheet
│   ├── mode_badge.dart          # Badge mode terapi (Kontinyu/Intermiten)
│   ├── sectionHistory.dart      # Daftar riwayat sesi berkelompok
│   └── splitButton.dart         # Tombol aksi split (dua aksi dalam satu tombol)
│
├── data/
│   └── dummyData.json           # Data dummy untuk development / preview tanpa DB
│
├── db/
│   └── database_helper.dart     # Singleton SQLite helper — CRUD therapy_sessions
│
├── models/
│   └── therapy_session.dart     # Model TherapySession (id, sessionDate, title, date, mode, duration)
│
└── utils/
    ├── mode_color.dart          # modeBadgeColor(mode) → Color (Kontinyu=blue, Intermiten=orange)
    └── text_styles.dart         # AppTextStyles — konstanta TextStyle (headerTitle, cardTitle, dll)
```

---

## Database Schema

File: `vac_dashboard.db` (SQLite via sqflite)

```sql
CREATE TABLE therapy_sessions (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  session_date  TEXT NOT NULL,   -- format: "YYYY-MM-DD..." (dipakai filter tahun)
  title         TEXT NOT NULL,
  date          TEXT NOT NULL,
  mode          TEXT NOT NULL,   -- "Kontinyu" | "Intermiten"
  duration      TEXT NOT NULL
)
```

Helper: `DatabaseHelper.instance` (singleton) — method: `insert`, `getAll`, `getByYear(year)`, `getYears`, `update`, `delete`

---

## Alur Data Utama

```
main.dart
  └── _loadData()                 # load dummyData.json ATAU dari DatabaseHelper
       └── filter by _selectedYear
  └── komponen UI:
       ├── header.dart            # judul + tahun aktif
       ├── sectionHistory.dart    # list sesi per kelompok
       │    └── card.dart         # tiap sesi → tap → bottomSheet.dart
       └── mode_badge.dart        # warna mode via mode_color.dart
```

---

## Mode Terapi

| Mode       | Warna Badge     |
| ---------- | --------------- |
| Kontinyu   | `Colors.blue`   |
| Intermiten | `Colors.orange` |

---

## Tips Navigasi

- **Tambah fitur UI** → mulai dari `lib/component/`
- **Ubah warna/tema** → Gunakan `context.colors.<nama_token>` dari `lib/asset/color_tokens.dart` (mendukung Dark/Light mode otomatis). Hindari hardcode `Colors.black`/`white`.
- **Typografi** → Gunakan komponen `AppText` dari `lib/component/text.dart`.
- **Logika DB** → `lib/db/database_helper.dart`
- **Model data** → `lib/models/therapy_session.dart`
- **Koneksi BLE ke VAC** → belum diimplementasi, entry point akan di `lib/` (service/provider baru)
- **Data dummy** → `lib/data/dummyData.json` (diload via `rootBundle`)

These rules apply to every task in this project unless explicitly overridden.
Bias: caution over speed on non-trivial work. Use judgment on trivial tasks.
Btw, I use Bun

## Rule 1 — Think Before Coding

State assumptions explicitly. If uncertain, ask rather than guess.
Present multiple interpretations when ambiguity exists.
Push back when a simpler approach exists.
Stop when confused. Name what's unclear.

## Rule 2 — Simplicity First

Minimum code that solves the problem. Nothing speculative.
No features beyond what was asked. No abstractions for single-use code.
Test: would a senior engineer say this is overcomplicated? If yes, simplify.

## Rule 3 — Surgical Changes

Touch only what you must. Clean up only your own mess.
Don't "improve" adjacent code, comments, or formatting.
Don't refactor what isn't broken. Match existing style.

## Rule 4 — Goal-Driven Execution

Define success criteria. Loop until verified.
Don't follow steps. Define success and iterate.
Strong success criteria let you loop independently.

## Rule 5 — Use the model only for judgment calls

Use me for: classification, drafting, summarization, extraction.
Do NOT use me for: routing, retries, deterministic transforms.
If code can answer, code answers.

## Rule 6 — Token budgets are not advisory

Per-task: 4,000 tokens. Per-session: 30,000 tokens.
If approaching budget, summarize and start fresh.
Surface the breach. Do not silently overrun.

## Rule 7 — Surface conflicts, don't average them

If two patterns contradict, pick one (more recent / more tested).
Explain why. Flag the other for cleanup.
Don't blend conflicting patterns.

## Rule 8 — Read before you write

Before adding code, read exports, immediate callers, shared utilities.
"Looks orthogonal" is dangerous. If unsure why code is structured a way, ask.

## Rule 9 — Tests verify intent, not just behavior

Tests must encode WHY behavior matters, not just WHAT it does.
A test that can't fail when business logic changes is wrong.

## Rule 10 — Checkpoint after every significant step

Summarize what was done, what's verified, what's left.
Don't continue from a state you can't describe back.
If you lose track, stop and restate.

## Rule 11 — Match the codebase's conventions, even if you disagree

Conformance > taste inside the codebase.
If you genuinely think a convention is harmful, surface it. Don't fork silently.

## Rule 12 — Fail loud

"Completed" is wrong if anything was skipped silently.
"Tests pass" is wrong if any were skipped.
Default to surfacing uncertainty, not hiding it.

## Rule 13 — Always Apply Clean Code Principles

Apply clean code principles in every piece of code you write.

- Simplicity (KISS): Keep logic straightforward and avoid unnecessary complexity. Choose the easiest solution to understand and maintain.
- Readability: Use clear, descriptive names for variables and functions, and keep formatting and indentation consistent.
- Single Responsibility (SRP): Each function, class, or module should have one responsibility and one reason to change.
- Don't Repeat Yourself (DRY): Avoid duplication by extracting repeated logic into reusable functions or modules.
- Small Functions: Keep functions short and focused on a single task to improve clarity and testability.
- Minimal Side Effects: Avoid changing state outside a function's scope unless that behavior is intentional.
- YAGNI: Do not add functionality unless it is immediately needed. Avoid over-engineering.
- Consistency: Follow the codebase's existing conventions and style so the project stays easy to work on.

## Rule 14 - dont use dash for comment

dont write comment use dash like this
`# ── Preprocessing ──────────────────────────────────────────────────────────────`

better write like this
`#PreProcessing`

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
