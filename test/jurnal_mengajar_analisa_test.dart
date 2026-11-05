import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/screens/widgets/jurnal_mengajar/sections/jurnal_analisa_section.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/screens/widgets/jurnal_mengajar/sections/jurnal_filter_card.dart';

void main() {
  testWidgets(
    'JurnalAnalisaSection menampilkan kotak 2x2 status KBM, chip kelas, dan analisa siswa',
    (WidgetTester tester) async {
      String? selectedClassId;
      String? openedJurnalId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: JurnalAnalisaSection(
                academicYearName: '2026/2027',
                isSupervisor: false,
                teachers: const [],
                selectedTeacherId: null,
                onTeacherChanged: (_) {},
                availableMonthsList: const [
                  {'key': '11-2026', 'label': 'November 2026'},
                ],
                selectedMonthYear: '11-2026',
                onMonthChanged: (_) {},
                isSingleMapel: true,
                availableMapels: const [
                  {'id': 1, 'nama_mapel': 'Matematika'},
                ],
                selectedMapelId: 1,
                onMapelChanged: (_) {},
                selectedClassId: selectedClassId,
                onClassChanged: (val) {
                  selectedClassId = val;
                },
                isLoading: false,
                isAnalyticsLoading: false,
                overallTotals: const {
                  'total_sesi': 4,
                  'total_jp': 8,
                  'hadir': 115,
                  'izin': 2,
                  'sakit': 1,
                  'izin_sakit': 3,
                  'alpa': 1,
                  'tidak_mengikuti': 2,
                  'total_absen': 6,
                },
                classesSummary: const [
                  {
                    'class_id': 'c1',
                    'class_name': '8A',
                    'total_sesi': 2,
                    'total_jp': 4,
                    'hadir': 58,
                    'izin': 1,
                    'sakit': 1,
                    'izin_sakit': 2,
                    'alpa': 1,
                    'tidak_mengikuti': 2,
                    'total_absen': 5,
                    'siswa_pernah_absen_count': 2,
                  },
                  {
                    'class_id': 'c2',
                    'class_name': '8B',
                    'total_sesi': 2,
                    'total_jp': 4,
                    'hadir': 57,
                    'izin': 1,
                    'sakit': 0,
                    'izin_sakit': 1,
                    'alpa': 0,
                    'tidak_mengikuti': 0,
                    'total_absen': 1,
                    'siswa_pernah_absen_count': 1,
                  },
                ],
                studentsSummary: const [
                  {
                    'student_id': 's1',
                    'student_name': 'Ahmad Fauzi',
                    'nis': '12345',
                    'class_id': 'c1',
                    'class_name': '8A',
                    'total_pertemuan': 2,
                    'hadir': 0,
                    'izin': 0,
                    'sakit': 0,
                    'izin_sakit': 0,
                    'alpa': 0,
                    'tidak_mengikuti': 2,
                    'total_absen': 2,
                    'absence_logs': [
                      {
                        'jurnal_id': 'j1',
                        'tanggal': '2026-11-05',
                        'tanggal_formatted': 'Kamis, 05 November 2026',
                        'jam_ke_label': 'Jam ke 1 - 2 (2 JP)',
                        'mata_pelajaran_name': 'Matematika',
                        'materi': 'Persamaan Linear',
                        'status': 'tidak_mengikuti',
                        'status_label': 'Tidak Mengikuti',
                        'status_gerbang': 'hadir',
                        'keterangan': 'Izin ke UKS tidak kembali',
                      },
                    ],
                  },
                ],
                onOpenJurnalById: (id) {
                  openedJurnalId = id;
                },
              ),
            ),
          ),
        ),
      );

      // Pastikan 4 kotak status KBM tampil
      expect(find.text('HADIR'), findsOneWidget);
      expect(find.text('IZIN / SAKIT'), findsOneWidget);
      expect(find.text('ALPA'), findsOneWidget);
      expect(find.text('TIDAK MENGIKUTI'), findsOneWidget);

      // Pastikan chip kelas & nama siswa yang tidak hadir tampil
      expect(find.text('Semua Kelas'), findsOneWidget);
      expect(find.text('Ahmad Fauzi'), findsOneWidget);
      expect(find.textContaining('Persamaan Linear'), findsOneWidget);

      // Ketuk log ketidakhadiran untuk membuka detail jurnal
      await tester.tap(find.textContaining('Persamaan Linear'));
      expect(openedJurnalId, equals('j1'));
    },
  );

  testWidgets(
    'JurnalCompactSummaryBar menampilkan ringkasan sesi, JP, dan tombol Analisa Siswa',
    (WidgetTester tester) async {
      bool tappedAnalisa = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JurnalCompactSummaryBar(
              totalSesi: 4,
              totalJp: 8,
              totalTidakHadir: 6,
              onOpenAnalisaTab: () {
                tappedAnalisa = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('4 Sesi KBM'), findsOneWidget);
      expect(find.text('8 JP (320 Menit)'), findsOneWidget);
      expect(find.text('6 Absen'), findsOneWidget);

      await tester.tap(find.text('Analisa Siswa'));
      expect(tappedAnalisa, isTrue);
    },
  );
}
