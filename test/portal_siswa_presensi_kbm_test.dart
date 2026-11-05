import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_presensi_kbm_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/widgets/presensi_siswa/sections/kbm_siswa_subject_list.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/widgets/presensi_siswa/modals/sheet_kbm_siswa_subject_detail.dart';

void main() {
  testWidgets(
      'KbmSiswaSubjectList renders 2x2 attendance boxes without percentage badge',
      (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));

    final subjects = <SiswaKbmSubject>[
      const SiswaKbmSubject(
        mataPelajaranId: 1,
        namaMapel: 'Informatika',
        kodeMapel: 'INF',
        kategori: 'Wajib',
        kkm: 75.0,
        guruPengampu: SiswaKbmGuru(
          id: '10',
          name: 'Budi Santoso, S.Kom',
          nip: '198501012010011001',
        ),
        stats: SiswaKbmSubjectStats(
          totalPertemuanTerdata: 5,
          hadir: 2,
          izin: 1,
          sakit: 0,
          alpa: 1,
          tidakMengikuti: 1,
          persentaseKehadiran: 40.0,
        ),
        hasData: true,
        pertemuanList: [
          SiswaKbmPertemuan(
            jurnalId: '101',
            pertemuanKe: 1,
            tanggal: '2026-02-01',
            tanggalFormatted: '01 Feb 2026',
            hari: 'Senin',
            jamKeLabel: 'Jam Ke-1 s.d 2',
            durasiJp: 2,
            materi: 'Pengenalan Microsoft Excel',
            uraianMateri: 'Membahas formula dasar SUM dan AVERAGE',
            status: 'hadir',
            statusLabel: 'Hadir',
            statusGerbang: 'hadir',
            keterangan: '',
            guruNama: 'Budi Santoso, S.Kom',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: KbmSiswaSubjectList(subjects: subjects),
          ),
        ),
      ),
    );

    expect(find.text('Informatika'), findsOneWidget);
    expect(find.text('Budi Santoso, S.Kom'), findsOneWidget);
    expect(find.text('HADIR'), findsOneWidget);
    expect(find.text('2 kali'), findsOneWidget);
    expect(find.text('IZIN / SAKIT'), findsOneWidget);
    expect(find.text('ALPA'), findsOneWidget);
    expect(find.text('TIDAK MENGIKUTI'), findsOneWidget);
    expect(find.text('5 Pertemuan'), findsOneWidget);
    expect(find.text('Lihat Riwayat KBM'), findsOneWidget);
    // Pastikan persentase 40% tidak ditampilkan
    expect(find.textContaining('40%'), findsNothing);
  });

  testWidgets('SheetKbmSiswaSubjectDetail renders subject meetings properly', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));

    const subject = SiswaKbmSubject(
      mataPelajaranId: 1,
      namaMapel: 'Informatika',
      kodeMapel: 'INF',
      kategori: 'Wajib',
      kkm: 75.0,
      guruPengampu: SiswaKbmGuru(
        id: '10',
        name: 'Budi Santoso, S.Kom',
        nip: '198501012010011001',
      ),
      stats: SiswaKbmSubjectStats(
        totalPertemuanTerdata: 1,
        hadir: 1,
        persentaseKehadiran: 100.0,
      ),
      hasData: true,
      pertemuanList: [
        SiswaKbmPertemuan(
          jurnalId: '101',
          pertemuanKe: 1,
          tanggal: '2026-02-01',
          tanggalFormatted: '01 Feb 2026',
          hari: 'Senin',
          jamKeLabel: 'Jam Ke-1 s.d 2',
          durasiJp: 2,
          materi: 'Pengenalan Microsoft Excel',
          uraianMateri: 'Membahas formula dasar SUM dan AVERAGE',
          status: 'hadir',
          statusLabel: 'Hadir',
          statusGerbang: 'hadir',
          keterangan: '',
          guruNama: 'Budi Santoso, S.Kom',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SheetKbmSiswaSubjectDetail(subject: subject),
        ),
      ),
    );

    expect(find.text('Informatika'), findsOneWidget);
    expect(find.textContaining('Pengenalan Microsoft Excel'), findsOneWidget);
    expect(find.text('Pertemuan 1'), findsOneWidget);
    expect(find.text('Kehadiran KBM'), findsNothing);
  });
}
