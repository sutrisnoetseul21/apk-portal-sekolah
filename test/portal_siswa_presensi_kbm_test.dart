import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_presensi_kbm_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/widgets/presensi_siswa/sections/kbm_siswa_summary_card.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/widgets/presensi_siswa/sections/kbm_siswa_subject_list.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/widgets/presensi_siswa/modals/sheet_kbm_siswa_subject_detail.dart';

void main() {
  testWidgets('KbmSiswaSummaryCard and KbmSiswaSubjectList render correctly', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));

    const summary = SiswaKbmSummary(
      totalPertemuanTerdata: 10,
      totalHadir: 9,
      totalIzin: 1,
      totalSakit: 0,
      totalAlpa: 0,
      persentaseKehadiran: 90.0,
    );

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
          totalPertemuanTerdata: 2,
          hadir: 2,
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
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                const KbmSiswaSummaryCard(summary: summary),
                KbmSiswaSubjectList(subjects: subjects),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Presensi KBM Mapel'), findsOneWidget);
    expect(find.text('90.0%'), findsOneWidget);
    expect(find.text('Informatika'), findsOneWidget);
    expect(find.text('Budi Santoso, S.Kom'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
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
  });
}
