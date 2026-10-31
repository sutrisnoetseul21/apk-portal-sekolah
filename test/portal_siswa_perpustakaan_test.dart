import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_perpustakaan_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/services/siswa_perpustakaan_service.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/perpustakaan_siswa_screen.dart';

class FakeSiswaPerpustakaanService extends SiswaPerpustakaanService {
  FakeSiswaPerpustakaanService() : super(dio: Dio());

  @override
  Future<SiswaPerpustakaanSummaryResponse> getSummary({String? identifier}) async {
    return const SiswaPerpustakaanSummaryResponse(
      student: SiswaPerpustakaanStudent(
        id: '1',
        name: 'AGAM ABDILAH PRATAMA',
        nisn: '0138109237',
        kelas: '8A',
      ),
      counts: SiswaPerpustakaanCounts(
        pinjamanAktif: 1,
        pinjamanTerlambat: 0,
        totalRiwayatPinjam: 0,
        totalKunjungan: 0,
      ),
      recentPinjaman: [],
    );
  }

  @override
  Future<SiswaPinjamanAktifResponse> getPinjamanAktif({String? identifier}) async {
    return const SiswaPinjamanAktifResponse(
      total: 1,
      items: [
        SiswaPinjamanItem(
          id: '1',
          kodeEksemplar: 'MTK9515',
          nomorBarcode: '-',
          buku: SiswaBukuInfo(
            judul: 'MATEMATIKA KONSEP DAN APLIKASINYA KELAS VIII BSE',
            penulis: 'DEWI NUHARINI, TRI WAHYUNI',
            kategori: 'Referensi',
          ),
          tanggalPinjamFormatted: '29 Oct 2026',
          tanggalJatuhTempoFormatted: '05 Nov 2026',
          tanggalKembaliFormatted: '-',
          status: 'dipinjam',
          labelStatus: 'Sedang Dipinjam',
          isTerlambat: false,
          sisaHari: 5,
        ),
      ],
    );
  }

  @override
  Future<SiswaRiwayatPinjamResponse> getRiwayatPinjam({
    String? search,
    int page = 1,
    int perPage = 15,
    String? identifier,
  }) async {
    return const SiswaRiwayatPinjamResponse(
      items: [],
      pagination: SiswaPerpustakaanPagination(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
      ),
    );
  }

  @override
  Future<SiswaRiwayatKunjunganResponse> getRiwayatKunjungan({
    int page = 1,
    int perPage = 15,
    String? identifier,
  }) async {
    return const SiswaRiwayatKunjunganResponse(
      items: [],
      pagination: SiswaPerpustakaanPagination(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
      ),
    );
  }
}

void main() {
  testWidgets('PerpustakaanSiswaScreen renders hero, 3 metric cards and active loan smoothly', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 924));

    final fakeService = FakeSiswaPerpustakaanService();

    await tester.pumpWidget(
      MaterialApp(
        home: PerpustakaanSiswaScreen(
          identifier: '0138109237',
          studentName: 'AGAM ABDILAH PRATAMA',
          schoolName: 'SMP Negeri 3 Kedungreja',
          service: fakeService,
        ),
      ),
    );

    // Initial loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for async fetch to finish
    await tester.pumpAndSettle();

    // Verify Hero Banner
    expect(find.text('Perpustakaan Sekolah'), findsOneWidget);
    expect(find.text('Cari buku yang ingin kamu pinjam dan pantau riwayat peminjamannya.'), findsOneWidget);
    expect(find.textContaining('AGAM ABDILAH PRATAMA • Kelas 8A'), findsOneWidget);

    // Verify 3 Metric cards in 1 row
    expect(find.text('Sedang Dipinjam'), findsOneWidget);
    expect(find.text('Riwayat Pinjam'), findsOneWidget);
    expect(find.text('Kunjungan'), findsOneWidget);

    // Verify Active Loan Item content
    expect(find.text('Buku Yang Sedang Anda Pinjam'), findsOneWidget);
    expect(find.text('MATEMATIKA KONSEP DAN APLIKASINYA KELAS VIII BSE'), findsOneWidget);
    expect(find.text('DEWI NUHARINI, TRI WAHYUNI'), findsOneWidget);
    expect(find.text('MTK9515'), findsOneWidget);
    expect(find.text('Sisa 5 hari lagi'), findsOneWidget);

    // Tap on 'Riwayat Pinjam' metric card
    await tester.tap(find.text('Riwayat Pinjam'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Peminjaman Buku'), findsOneWidget);
    expect(find.text('Belum Ada Riwayat Peminjaman'), findsOneWidget);

    // Tap on 'Kunjungan' metric card
    await tester.tap(find.text('Kunjungan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Kunjungan Fisik'), findsOneWidget);
    expect(find.text('Belum Ada Riwayat Kunjungan Fisik'), findsOneWidget);

    // Tap back to 'Sedang Dipinjam'
    await tester.tap(find.text('Sedang Dipinjam'));
    await tester.pumpAndSettle();

    expect(find.text('MATEMATIKA KONSEP DAN APLIKASINYA KELAS VIII BSE'), findsOneWidget);
  });
}
