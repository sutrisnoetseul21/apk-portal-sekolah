import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_dashboard_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/services/siswa_dashboard_service.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/dashboard_siswa_screen.dart';

class FakeSiswaDashboardService extends SiswaDashboardService {
  FakeSiswaDashboardService() : super(dio: Dio());

  @override
  Future<SiswaDashboardSummary> getDashboardSummary({String? identifier}) async {
    return SiswaDashboardSummary.fromJson({
      'student': {
        'id': '1',
        'name': 'AGAM ABDILAH PRATAMA',
        'nisn': '0138109237',
        'class_name': 'Kelas IX-A',
        'barcode_code': '0138109237',
      },
      'today_attendance': {
        'status': 'Hadir Tepat Waktu',
        'jam_masuk': '06:45',
        'jam_pulang': null,
        'sholat_dhuhur': 'Sudah Berjamaah',
      },
      'quick_stats': {
        'pending_leaves_count': 0,
        'active_counseling_count': 0,
        'spikap_reports_count': 0,
        'active_loans_count': 0,
      },
      'unread_notifications_count': 0,
    });
  }
}

void main() {
  testWidgets('DashboardSiswaScreen renders all 7 Portal Siswa menus', (
    WidgetTester tester,
  ) async {
    // Set surface size to emulate a phone screen
    await tester.binding.setSurfaceSize(const Size(400, 1600));

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardSiswaScreen(
          identifier: '0138109237',
          studentName: 'AGAM ABDILAH PRATAMA',
          schoolName: 'SMP Negeri 3 Kedungreja',
          service: FakeSiswaDashboardService(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verifikasi Header Welcome
    expect(find.text('PORTAL SISWA & PELAJAR'), findsOneWidget);
    expect(find.text('Hai, AGAM ABDILAH PRATAMA!'), findsOneWidget);

    // Verifikasi Kartu Presensi Masuk & Sholat
    expect(find.text('Presensi Masuk'), findsOneWidget);
    expect(find.text('Sholat Dhuhur'), findsOneWidget);

    // Verifikasi Kartu Barcode Cepat
    expect(find.text('Kartu Pelajar Barcode'), findsOneWidget);

    // Verifikasi Seluruh 7 Menu Utama Portal Siswa
    expect(find.text('Presensi & Akademik'), findsOneWidget);
    expect(find.text('Pengajuan Ijin Kehadiran'), findsOneWidget);
    expect(find.text('Guru Wali (SI-WALI)'), findsOneWidget);
    expect(find.text('SPIKAP (Karakter & Lapor)'), findsOneWidget);
    expect(find.text('Perpustakaan Siswa'), findsOneWidget);
    expect(find.text('Kartu Pelajar & Unduh PDF'), findsOneWidget);
    expect(find.text('Profil Saya'), findsOneWidget);

    // Verifikasi Tombol / Label Aksi Seluruh 7 Menu
    expect(find.text('Buka Presensi'), findsOneWidget);
    expect(find.text('Ajukan Ijin'), findsOneWidget);
    expect(find.text('Buka SI-WALI'), findsOneWidget);
    expect(find.text('Buka SPIKAP'), findsOneWidget);
    expect(find.text('Buka Perpustakaan'), findsOneWidget);
    expect(find.text('Lihat Kartu PDF'), findsOneWidget);
    expect(find.text('Buka Profil'), findsOneWidget);

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
