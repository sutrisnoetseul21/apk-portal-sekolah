import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_spikap_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/services/siswa_spikap_service.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/spikap_siswa_screen.dart';

class FakeSiswaSpikapService extends SiswaSpikapService {
  FakeSiswaSpikapService() : super(dio: Dio());

  @override
  Future<SiswaSpikapDashboardResponse> getDashboard({String? identifier}) async {
    return const SiswaSpikapDashboardResponse(
      branding: SiswaSpikapBranding(
        namaAplikasi: 'SPIKAP',
        subJudul: 'Anti-Perundungan & Pengaduan Siswa',
        penjelasan: 'Sistem Pelaporan Integratif Konflik & Anti-Perundungan',
      ),
      counts: SiswaSpikapCounts(
        total: 5,
        diterima: 2,
        dalamInvestigasi: 1,
        selesai: 2,
        darurat: 1,
        biasa: 4,
      ),
      recentLaporan: [],
    );
  }

  @override
  Future<SiswaSpikapListResponse> getLaporanList({
    String status = 'all',
    String sifatLaporan = 'all',
    String jenisPerundungan = 'all',
    String? search,
    int page = 1,
    int perPage = 15,
    String? identifier,
  }) async {
    return const SiswaSpikapListResponse(
      items: [
        SiswaSpikapLaporanItem(
          id: 1,
          sifatLaporan: 'biasa',
          isDarurat: false,
          labelSifat: 'Biasa',
          jenisPerundungan: 'verbal',
          labelJenis: 'Verbal',
          labelTujuan: 'Wali Kelas',
          uraianKejadian: 'Mendapat ejekan saat istirahat di kantin.',
          lokasiKejadian: 'Kantin Sekolah',
          status: 'diterima',
          labelStatus: 'Diterima',
        ),
      ],
      pagination: SiswaSpikapPagination(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 1,
      ),
    );
  }
}

void main() {
  testWidgets('SpikapSiswaScreen renders 6 Summary Metrics and Clean Search Input without chip menus', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 924));

    await tester.pumpWidget(
      MaterialApp(
        home: SpikapSiswaScreen(
          identifier: '0138109237',
          studentName: 'AGAM ABDILAH PRATAMA',
          schoolName: 'SMP Negeri 3 Kedungreja',
          service: FakeSiswaSpikapService(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifikasi Header AppBar & Hero Banner
    expect(find.text('SPIKAP (Layanan Pengaduan)'), findsOneWidget);
    expect(find.text('SPIKAP • Ruang Aman & Layanan Pengaduan Murid'), findsOneWidget);
    expect(find.text('Perlindungan Kerahasiaan Terjamin'), findsOneWidget);

    // Verifikasi 6 Kotak Metrik (2 Baris x 3 Kolom)
    expect(find.text('Semua Aduan'), findsOneWidget);
    expect(find.text('Diterima'), findsNWidgets(2)); // 1 di metric box, 1 di badge kartu list
    expect(find.text('Investigasi'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    expect(find.text('Darurat'), findsOneWidget);
    expect(find.text('Biasa'), findsNWidgets(2)); // 1 di metric box, 1 di badge kartu list

    // Verifikasi Angka pada Kotak
    expect(find.text('5'), findsOneWidget); // total
    expect(find.text('2'), findsNWidgets(2)); // diterima (2) & selesai (2)
    expect(find.text('1'), findsNWidgets(2)); // investigasi (1) & darurat (1)
    expect(find.text('4'), findsOneWidget); // biasa

    // Verifikasi Search Bar ada
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Cari kata kunci, lokasi, atau isi aduan...'), findsOneWidget);

    // Verifikasi Filter Chips Lama TIDAK ADA LAGI
    expect(find.text('Semua Status'), findsNothing);
    expect(find.text('Semua Sifat'), findsNothing);
    expect(find.text('⏳ Diterima'), findsNothing);
    expect(find.text('🔍 Investigasi'), findsNothing);
    expect(find.text('✅ Selesai'), findsNothing);
    expect(find.text('🚨 Darurat'), findsNothing);

    // Verifikasi Kartu Laporan Ter-render
    expect(find.text('Tujuan: Wali Kelas'), findsOneWidget);
    expect(find.text('Mendapat ejekan saat istirahat di kantin.'), findsOneWidget);

    // Verifikasi FAB Buat Laporan
    expect(find.text('Buat Laporan'), findsOneWidget);

    // Uji klik salah satu kotak metrik (Investigasi)
    await tester.tap(find.text('Investigasi'));
    await tester.pumpAndSettle();

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });

  test('SiswaSpikapCounts model parses biasa and falls back accurately', () {
    final withBiasa = SiswaSpikapCounts.fromJson({
      'total': 10,
      'diterima': 3,
      'dalam_investigasi': 2,
      'selesai': 5,
      'darurat': 2,
      'biasa': 8,
    });
    expect(withBiasa.total, 10);
    expect(withBiasa.darurat, 2);
    expect(withBiasa.biasa, 8);

    // Fallback: total - darurat
    final fallback = SiswaSpikapCounts.fromJson({
      'total': 7,
      'diterima': 1,
      'dalam_investigasi': 1,
      'selesai': 5,
      'darurat': 3,
    });
    expect(fallback.biasa, 4);
  });
}
