import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_ijin_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/form_ijin_siswa_screen.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/ijin_kehadiran_siswa_screen.dart';

void main() {
  testWidgets('FormIjinSiswaScreen renders smoothly without LocaleDataException', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 924));

    await tester.pumpWidget(
      const MaterialApp(
        home: FormIjinSiswaScreen(
          identifier: '0138109237',
          studentName: 'AGAM ABDILAH PRATAMA',
          schoolName: 'SMP Negeri 3 Kedungreja',
        ),
      ),
    );

    // Initial render
    await tester.pump();

    // Pastikan AppBar dan Title ter-render
    expect(find.text('Form Pengajuan Ijin'), findsOneWidget);

    // Pastikan Kategori Permohonan Sakit & Izin ter-render
    expect(find.text('Kategori Permohonan'), findsOneWidget);
    expect(find.text('Sakit'), findsOneWidget);
    expect(find.text('Izin'), findsOneWidget);

    // Pastikan Waktu & Durasi ter-render (bebas crash dari locale)
    expect(find.text('Waktu & Durasi Izin'), findsOneWidget);
    expect(find.text('Tanggal Mulai'), findsOneWidget);
    expect(find.text('1 Hari'), findsOneWidget);

    // Pastikan Field Alasan & Bukti Foto ter-render
    expect(find.text('Alasan / Keterangan'), findsOneWidget);
    expect(find.text('Bukti Foto / Surat Lampiran'), findsOneWidget);

    // Pastikan Tombol Submit ter-render
    expect(find.text('Kirim Pengajuan Ijin'), findsOneWidget);

    // Selesaikan async timer network
    await tester.pump(const Duration(seconds: 16));
  });

  testWidgets('IjinKehadiranSiswaScreen initial state renders AppBar and FAB', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 924));

    await tester.pumpWidget(
      const MaterialApp(
        home: IjinKehadiranSiswaScreen(
          identifier: '0138109237',
          studentName: 'AGAM ABDILAH PRATAMA',
          schoolName: 'SMP Negeri 3 Kedungreja',
        ),
      ),
    );

    await tester.pump();

    // Pastikan AppBar & Title ter-render
    expect(find.text('Pengajuan Ijin Kehadiran'), findsOneWidget);
    expect(find.text('SMP Negeri 3 Kedungreja'), findsOneWidget);

    // Pastikan FloatingActionButton Ajukan Ijin ter-render
    expect(find.text('Ajukan Ijin'), findsOneWidget);

    // Selesaikan async timer network
    await tester.pump(const Duration(seconds: 16));
  });

  testWidgets('IjinKehadiranSiswaScreen renders list of ijin cards cleanly without Spacer exception', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 924));

    final mockResponse = SiswaIjinListResponse(
      counts: const SiswaIjinCounts(total: 2, pending: 1, approved: 1, rejected: 0),
      items: const [
        SiswaIjinItem(
          id: 'ijin-001',
          type: 'sakit',
          typeLabel: 'Sakit',
          durationDays: 2,
          startDate: '2026-10-30',
          endDate: '2026-10-31',
          formattedStartDate: '30 Oktober 2026',
          formattedEndDate: '31 Oktober 2026',
          formattedRange: '30 - 31 Okt 2026',
          reason: 'Demam tinggi dan istirahat dokter',
          status: 'pending',
          statusLabel: 'Menunggu Verifikasi',
          hasAttachments: true,
          attachmentsCount: 1,
          attachments: [
            SiswaIjinAttachment(
              index: 0,
              fileName: 'surat_dokter.jpg',
              url: 'https://example.com/surat.jpg',
              filePath: 'leave-requests/surat.jpg',
              extension: 'jpg',
              isImage: true,
              mediaType: 'image',
            ),
          ],
          isCancellable: true,
          createdAt: '2026-10-30 07:00:00',
          formattedCreatedAt: '30 Okt 2026, 07:00',
        ),
        SiswaIjinItem(
          id: 'ijin-002',
          type: 'ijin',
          typeLabel: 'Izin',
          durationDays: 1,
          startDate: '2026-10-25',
          endDate: '2026-10-25',
          formattedStartDate: '25 Oktober 2026',
          formattedEndDate: '25 Oktober 2026',
          formattedRange: '25 Okt 2026',
          reason: 'Menghadiri khitanan adik kandung',
          status: 'approved',
          statusLabel: 'Disetujui',
          hasAttachments: false,
          attachmentsCount: 0,
          attachments: [],
          isCancellable: false,
          createdAt: '2026-10-25 06:30:00',
          formattedCreatedAt: '25 Okt 2026, 06:30',
        ),
      ],
      pagination: const SiswaIjinPagination(
        currentPage: 1,
        lastPage: 1,
        perPage: 10,
        total: 2,
        hasMore: false,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: IjinKehadiranSiswaScreen(
          identifier: '0138109237',
          studentName: 'AGAM ABDILAH PRATAMA',
          schoolName: 'SMP Negeri 3 Kedungreja',
          initialData: mockResponse,
        ),
      ),
    );

    await tester.pump();

    // Verifikasi Filter Chips dengan counter
    expect(find.text('Semua Status (2)'), findsOneWidget);
    expect(find.text('Menunggu (1)'), findsOneWidget);
    expect(find.text('Disetujui (1)'), findsOneWidget);

    // Verifikasi Item 1 (Sakit)
    expect(find.text('Demam tinggi dan istirahat dokter'), findsOneWidget);
    expect(find.text('30 - 31 Okt 2026'), findsOneWidget);
    expect(find.text('2 Hari'), findsOneWidget);
    expect(find.text('1 Lampiran'), findsOneWidget);
    expect(find.text('Batalkan'), findsOneWidget);

    // Verifikasi Item 2 (Izin)
    expect(find.text('Menghadiri khitanan adik kandung'), findsOneWidget);
    expect(find.text('25 Okt 2026'), findsOneWidget);
    expect(find.text('Tanpa lampiran'), findsOneWidget);
  });
}

