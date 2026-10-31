import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_kartu_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/services/siswa_kartu_service.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/kartu_siswa_screen.dart';

class FakeSiswaKartuService extends SiswaKartuService {
  FakeSiswaKartuService() : super(dio: Dio());

  @override
  Future<SiswaKartuResponse> getDigitalInfo({String? identifier}) async {
    return const SiswaKartuResponse(
      success: true,
      message: 'Kartu digital siswa berhasil dimuat.',
      data: SiswaKartuDigitalInfo(
        studentId: '1',
        name: 'AGAM ABDILAH PRATAMA',
        nisn: '0138109237',
        nis: '9515',
        className: '8A',
        gender: 'L',
        genderLabel: 'Laki-laki',
        birthPlace: 'Cilacap',
        birthInfo: 'Cilacap, 14 Mei 2012',
        barcodeCode: '0138109237',
        barcodeActive: true,
        schoolName: 'SMP Negeri 3 Kedungreja',
        schoolAddress: 'Jl. Raya Kedungreja No. 45',
        principalName: 'Kepala Sekolah',
        principalNip: '19700101 199003 1 001',
        scanMode: 'nisn',
        downloadPdfUrl: 'https://example.com/api/siswa/kartu/download',
        biodataPdfUrl: 'https://example.com/api/siswa/kartu/biodata',
      ),
    );
  }
}

void main() {
  testWidgets('KartuSiswaScreen renders centered ID card without Kelas label and with print button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 924);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeService = FakeSiswaKartuService();

    await tester.pumpWidget(
      MaterialApp(
        home: KartuSiswaScreen(
          identifier: '0138109237',
          studentName: 'AGAM ABDILAH PRATAMA',
          schoolName: 'SMP Negeri 3 Kedungreja',
          service: fakeService,
        ),
      ),
    );

    // Initial pump & settle
    await tester.pumpAndSettle();

    // Verifikasi AppBar
    expect(find.text('Kartu Pelajar & Cetak PDF'), findsOneWidget);

    // Verifikasi Badge KARTU SISWA pada ID card terpusat
    expect(find.text('KARTU SISWA'), findsOneWidget);

    // Verifikasi Nama Siswa & Identitas Box NISN
    expect(find.text('AGAM ABDILAH PRATAMA'), findsWidgets);
    expect(find.text('USERNAME (NISN)'), findsOneWidget);
    expect(find.text('0138109237'), findsWidgets);

    // Pastikan label 'Kelas' TIDAK ada pada kartu
    expect(find.textContaining('Kelas:'), findsNothing);

    // Verifikasi Tombol Putar Sisi (Sisi Depan / Sisi Belakang) & Cetak PDF In-App
    expect(find.text('Sisi Depan'), findsOneWidget);
    expect(find.text('Sisi Belakang'), findsOneWidget);
    expect(find.text('Unduh PDF Kartu'), findsOneWidget);
    expect(find.text('Unduh Biodata'), findsOneWidget);
  });
}
