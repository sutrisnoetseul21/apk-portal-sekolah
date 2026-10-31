import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_profil_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/services/siswa_profil_service.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/profil_siswa_screen.dart';

class FakeSiswaProfilService extends SiswaProfilService {
  FakeSiswaProfilService() : super(dio: Dio());

  @override
  Future<SiswaProfilResponse> getProfilInfo({String? identifier}) async {
    return const SiswaProfilResponse(
      success: true,
      message: 'Profil siswa berhasil dimuat.',
      data: SiswaProfilDetail(
        studentId: '1',
        name: 'AGAM ABDILAH PRATAMA',
        nisn: '0138109237',
        nis: '9515',
        email: 'agam@smpn3kedungreja.sch.id',
        className: '8A',
        academicYear: '2026/2027',
        status: 'Aktif',
        gender: 'L',
        genderLabel: 'Laki-Laki',
        religion: 'Islam',
        birthPlace: 'Cilacap',
        birthDate: '2012-05-14',
        birthInfo: 'Cilacap, 14 Mei 2012',
        address: 'Jl. Raya Kedungreja No. 45',
        noHp: '081234567890',
        allowPhotoUpload: true,
        namaAyah: 'Bambang Pratama',
        pekerjaanAyah: 'Wiraswasta',
        namaIbu: 'Siti Aminah',
        pekerjaanIbu: 'Guru',
        namaWali: '-',
        pekerjaanWali: '-',
        noHpOrangTua: '081298765432',
        barcodeCode: '0138109237',
      ),
    );
  }
}

void main() {
  testWidgets('ProfilSiswaScreen renders student biodata and tabs smoothly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 924);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeService = FakeSiswaProfilService();

    await tester.pumpWidget(
      MaterialApp(
        home: ProfilSiswaScreen(
          identifier: '0138109237',
          studentName: 'AGAM ABDILAH PRATAMA',
          schoolName: 'SMP Negeri 3 Kedungreja',
          service: fakeService,
        ),
      ),
    );

    // Initial pump and settle
    await tester.pumpAndSettle();

    // Verify AppBar & Profile Header
    expect(find.text('Profil Saya & Akun'), findsOneWidget);
    expect(find.text('AGAM ABDILAH PRATAMA'), findsNWidgets(2));
    expect(find.text('0138109237'), findsNWidgets(2)); // in NISN row & Barcode ID row
    expect(find.text('Kelas 8A'), findsOneWidget);

    // Verify TabBar
    expect(find.text('Biodata & Kontak'), findsOneWidget);
    expect(find.text('Keamanan Sandi'), findsOneWidget);

    // Verify Biodata fields
    expect(find.text('Bambang Pratama'), findsOneWidget);
    expect(find.text('Siti Aminah'), findsOneWidget);
  });
}
