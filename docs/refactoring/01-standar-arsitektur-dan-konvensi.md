# 🏛️ 01. Standar Arsitektur & Konvensi Modularisasi

Dokumen ini mendefinisikan standar baku arsitektur kode baru untuk mengurai dan mencegah kembalinya berkas kode monolitik (*God-Widget*) di dalam proyek Flutter ini.

---

## 1. Konvensi Struktur Folder Fitur (`lib/features/<nama_fitur>/`)

Sebelumnya, file screen ditaruh langsung di `screens/` dan menampung ribuan baris kode. Struktur baru mengadopsi modularitas berbasis hierarki fungsional:

```text
lib/features/<nama_fitur>/
├── models/                         # Model data ber-tipe (fromJson/toJson)
│   ├── <fitur>_model.dart
│   └── <fitur>_filter_model.dart
│
├── services/                       # Lapisan networking Dio & API Client
│   └── <fitur>_service.dart
│
├── screens/                        # Orchestrator Layar (HANYA Scaffold & Koordinasi)
│   ├── <nama>_screen.dart          # Target: 150 - 300 baris
│   └── ...
│
└── screens/widgets/<nama_layar>/   # Folder komponen khusus layar tersebut
    ├── tabs/                       # Setiap tab layar wajib memiliki file terpisah
    │   ├── tab_katalog.dart
    │   ├── tab_pinjaman_saya.dart
    │   └── ...
    │
    ├── modals/                     # BottomSheet & Dialog interaktif terpisah
    │   ├── modal_input_manual.dart
    │   ├── modal_input_single.dart
    │   ├── dialog_cetak_export.dart
    │   └── sheet_wa_reminder.dart
    │
    ├── cards/                      # Card list item atau data item
    │   ├── student_daily_card.dart
    │   └── matrix_grid_view.dart
    │
    └── sections/                   # Bagian-bagian besar layar (Header, Filter, Stats)
        ├── hero_banner_section.dart
        ├── filter_bar_section.dart
        └── summary_kpi_section.dart
```

---

## 2. Batas Toleransi Baris Kode (*Line Limit Guardrails*)

| Jenis Berkas | Rekomendasi Target | Batas Keras (Hard Limit) | Catatan |
| :--- | :-: | :-: | :--- |
| **Screen (`_screen.dart`)** | 150 – 250 baris | **350 baris** | Hanya menyusun `Scaffold`, memuat data awal, dan menyusun sub-widget. |
| **Tab Widget (`tab_*.dart`)** | 150 – 300 baris | **400 baris** | Menangani scroll controller dan list view tab tersebut. |
| **Modal / BottomSheet** | 100 – 250 baris | **350 baris** | Form interaktif, validasi, dan callback submission. |
| **Section Widget** | 50 – 150 baris | **200 baris** | Header banner, KPI cards, filter chips. |
| **List Item / Card** | 50 – 150 baris | **200 baris** | Card individual yang diulang dalam ListView. |
| **Service Layer** | 100 – 250 baris | **350 baris** | Hanya mengurusi panggilan endpoint HTTP Dio. |

> [!IMPORTANT]
> **Aturan Emas 350 Baris:** Jika sebuah berkas mulai mendekati 350 baris, lakukan evaluasi segera: cari sub-widget atau modal yang bisa diekstraksi ke file terpisah sebelum bertambah panjang.

---

## 3. Prinsip Pemisahan Tanggung Jawab (*Separation of Concerns*)

### ❌ Anti-Pattern (Sebelumnya)
```dart
// CONTOH BURUK: Seluruh logic, UI, modal, dan HTTP di satu class State (4.000+ baris)
class _PresensiKelasScreenState extends State<PresensiKelasScreen> {
  // 1. Puluhan Controller & State mentah
  // 2. Dio call langsung di dalam method
  // 3. Modal 900 baris di dalam method _openInputManualModal()
  // 4. Matrix table 400 baris di method _buildMonthlyMatrixSection()
  // 5. WhatsApp URL launcher di method _openWaModal()
}
```

### ✅ Clean Pattern (Target Baru)
```dart
// CONTOH BAIK: Layar utama bersih dan deklaratif (hanya ~180 baris)
class PresensiKelasScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  // ...
}

class _PresensiKelasScreenState extends State<PresensiKelasScreen> {
  // State terkelola rapi
  late final PresensiKelasService _service;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PresensiAppBar(title: 'Presensi Kelas'),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          children: [
            PresensiHeroBanner(summary: _summaryData),
            PresensiFilterBar(
              academicYears: _years,
              onClassChanged: _handleClassChanged,
            ),
            PresensiKpiMetrics(stats: _stats),
            _rekapMode == 'harian'
                ? PresensiDailySection(students: _filteredStudents, onEdit: _openEditModal)
                : PresensiMonthlyMatrixSection(matrix: _matrixData),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. Standar Ekstraksi Modal & Dialog

Setiap modal atau dialog yang memiliki logika form, interaksi tombol, atau tampilan kompleks **Wajib** dipisahkan menjadi file mandiri:

1. Buat class tersendiri (`StatefulWidget` atau `StatelessWidget`).
2. Sediakan static helper method untuk pemanggilan bersih:
   ```dart
   class PresensiManualBulkModal extends StatefulWidget {
     final List<Map<String, dynamic>> students;
     final Future<void> Function(List<Map<String, dynamic>> payload) onSave;

     const PresensiManualBulkModal({
       super.key,
       required this.students,
       required this.onSave,
     });

     /// Helper static untuk memanggil bottom sheet dengan bersih
     static Future<bool?> show(
       BuildContext context, {
       required List<Map<String, dynamic>> students,
       required Future<void> Function(List<Map<String, dynamic>> payload) onSave,
     }) {
       return showModalBottomSheet<bool>(
         context: context,
         isScrollControlled: true,
         useSafeArea: true,
         builder: (_) => PresensiManualBulkModal(
           students: students,
           onSave: onSave,
         ),
       );
     }
     // ...
   }
   ```
3. Pemanggilan dari Screen induk menjadi satu baris:
   ```dart
   final updated = await PresensiManualBulkModal.show(context, students: _students, onSave: _saveBulk);
   if (updated == true) _refreshData();
   ```

---

## 5. Standar Komponen Bersama (*Cross-Feature Shared Widgets*)

Ada beberapa komponen yang saat ini diduplikasi berulang kali di berbagai screen:
1. **WhatsApp Launcher & Reminder Sheet**:
   Diduplikasi di Presensi Harian, Presensi Sholat, Guru Wali, Perpustakaan, dan Data Siswa.  
   👉 **Solusi:** Satukan ke `lib/shared/widgets/modals/whatsapp_launcher_sheet.dart`.
2. **Dialog Cetak / Rekap PDF & Excel**:
   Diduplikasi di Presensi Kelas, Sholat Dhuhur, Jurnal Mengajar, dan Guru Wali.  
   👉 **Solusi:** Satukan layout periodenya ke `lib/shared/widgets/modals/export_options_dialog.dart`.
3. **Empty State & Error State Widget**:
   Pola icon abu-abu + teks keterangan diduplikasi di puluhan tempat.  
   👉 **Solusi:** Gunakan `shared/widgets/app_empty_state.dart` dan `app_error_state.dart`.

---

## 6. Protokol "Zero Breaking Changes"

Untuk memastikan aplikasi tetap berfungsi normal tanpa regresi:
1. **Dilarang Mengubah Parameter Screen**:
   Konstruktor publik screen (misal `PresensiKelasScreen`, `PerpustakaanScreen`) tidak boleh mengalami penambahan parameter wajib baru atau penghapusan parameter yang ada.
2. **Dilarang Mengubah Route Path**:
   Alur navigasi antar layar di dashboard harus tetap memakai `MaterialPageRoute` atau mekanisme navigasi yang sama.
3. **Penyimpanan State Aman**:
   Jika mengekstrak widget menjadi stateless, pastikan callback event (`onTap`, `onChanged`, `onSubmit`) mengalirkan data dengan tipe yang jelas ke parent state.

