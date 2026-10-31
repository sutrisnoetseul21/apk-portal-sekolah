import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_guru_wali_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/screens/guru_wali_siswa_screen.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/services/siswa_guru_wali_service.dart';

class FakeSiswaGuruWaliService extends SiswaGuruWaliService {
  final SiswaGuruWaliDashboardResponse mockDashboard;
  final SiswaKonsultasiListResponse mockKonsultasi;
  final SiswaKlasikalListResponse mockKlasikal;

  FakeSiswaGuruWaliService({
    required this.mockDashboard,
    required this.mockKonsultasi,
    required this.mockKlasikal,
  }) : super(dio: Dio());

  @override
  Future<SiswaGuruWaliDashboardResponse> getDashboard({String? identifier}) async {
    return mockDashboard;
  }

  @override
  Future<SiswaKonsultasiListResponse> getKonsultasiList({
    String status = 'all',
    String? kategori,
    String? search,
    int page = 1,
    int perPage = 10,
    String? identifier,
  }) async {
    return mockKonsultasi;
  }

  @override
  Future<SiswaKlasikalListResponse> getPendampinganKlasikalList({
    String? jenis = 'all',
    String? kategori,
    String? search,
    int page = 1,
    int perPage = 10,
    String? identifier,
  }) async {
    return mockKlasikal;
  }
}

void main() {
  testWidgets('GuruWaliSiswaScreen renders 6 Summary Metrics and Clean Search Input without chip menus', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 924));

    final mockDashboard = SiswaGuruWaliDashboardResponse(
      hasGuruWali: true,
      guruWali: const SiswaGuruWaliProfile(
        id: '19',
        name: 'Sutrisno, S.Pd.',
        nip: '198501012010011001',
        photoUrl: null,
        phone: '08123456789',
        namaKelompok: 'Kelompok Sutrisno, S.Pd.',
        tahunAjaran: '2026/2027',
        tanggalBergabung: '2026-10-01',
        formattedTanggalBergabung: 'Mendampingi sejak 01 Oct 2026',
      ),
      counts: const SiswaGuruWaliCounts(
        semua: 2,
        menunggu: 0,
        dijadwalkan: 0,
        selesai: 2,
        ditolak: 0,
        klasikal: 1,
        kelompokKecil: 0,
        totalKlasikal: 1,
        catatanGuru: 0,
      ),
    );

    final mockKonsulList = SiswaKonsultasiListResponse(
      items: const [
        SiswaKonsultasiItem(
          id: 'konsul-01',
          kategori: 'Akademik',
          topik: 'Kesulitan Memahami Materi Matematika (Aljabar) & Persiapan Ujian',
          detail: 'Saya sering tertinggal saat penjelasan materi Aljabar di kelas.',
          mode: 'Tatap Muka',
          status: 'Dikonversi ke Jurnal',
          statusLabel: 'Dikonversi ke Jurnal',
          statusKey: 'selesai',
          isCancellable: false,
          canChat: false,
          canFeedback: false,
          unreadMessagesCount: 0,
          guruName: 'Sutrisno, S.Pd.',
          jadwalPasti: '2026-10-05 10:15:00',
          formattedJadwalPasti: 'Monday, 05 October 2026, 10:15 WIB',
          tanggapanGuru: 'Sesi konsultasi disetujui di gazebo depan perpustakaan.',
          feedbackRating: 5,
          feedbackEmoji: 'Lega',
          feedbackNote: 'Terimakasih Bapak atas bimbingannya',
          createdAt: '2026-10-03 20:17:00',
          formattedCreatedAt: '03 Oct 2026, 20:17',
        ),
      ],
      currentPage: 1,
      lastPage: 1,
      total: 1,
      hasMore: false,
    );

    final mockKlasikalList = SiswaKlasikalListResponse(
      items: const [
        SiswaBimbinganKlasikalItem(
          id: 'klasikal-01',
          jenisPendampingan: 'Klasikal',
          kategoriPendampingan: 'Akademik',
          tanggalWaktu: '2026-10-03 09:30:00',
          formattedDate: 'Saturday, 03 October 2026',
          formattedTime: '09:30 WIB',
          uraianPembahasan: 'Topik: Pendampingan Pasca ASTS',
          rencanaTindakLanjut: 'Mengerjakan evaluasi mandiri',
          statusSesi: 'Tuntas / Selesai',
          guruName: 'Sutrisno, S.Pd.',
          isPublicNote: true,
        ),
      ],
      currentPage: 1,
      lastPage: 1,
      total: 1,
      hasMore: false,
    );

    final fakeService = FakeSiswaGuruWaliService(
      mockDashboard: mockDashboard,
      mockKonsultasi: mockKonsulList,
      mockKlasikal: mockKlasikalList,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: GuruWaliSiswaScreen(
          identifier: '0138109237',
          studentName: 'AGAM ABDILAH PRATAMA',
          schoolName: 'SMP Negeri 3 Kedungreja',
          service: fakeService,
        ),
      ),
    );

    // Pump widget sampai data ter-load
    await tester.pump();
    await tester.pumpAndSettle();

    // Verifikasi AppBar & Title
    expect(find.text('Guru Wali (SI-WALI)'), findsOneWidget);
    expect(find.text('SMP Negeri 3 Kedungreja'), findsOneWidget);

    // Verifikasi FAB Mulai Bercerita
    expect(find.text('Mulai Bercerita'), findsOneWidget);

    // Verifikasi 6 Kotak Metrik Ringkasan & Filter Cepat di Atas
    expect(find.text('Konsultasi'), findsWidgets);
    expect(find.text('Menunggu'), findsWidgets);
    expect(find.text('Dijadwalkan'), findsWidgets);
    expect(find.text('Selesai'), findsWidgets);
    expect(find.text('Klasikal'), findsWidgets);
    expect(find.text('Kelompok Kecil'), findsWidgets);

    // Verifikasi Angka pada Kotak
    expect(find.text('2'), findsWidgets);
    expect(find.text('1'), findsWidgets);

    // Verifikasi Menu Pencarian Bersih (Tanpa Menu Baris Chip Lagi di Bawahnya)
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Cari topik curhat atau kata kunci...'), findsOneWidget);
    expect(find.byType(FilterChip), findsNothing);

    // Verifikasi Kartu Konsultasi Ter-render
    expect(find.text('Kesulitan Memahami Materi Matematika (Aljabar) & Persiapan Ujian'), findsOneWidget);
  });

  testWidgets('SiswaGuruWali models parse and serialize correctly including kelompok_kecil and total_klasikal', (
    WidgetTester tester,
  ) async {
    // 1. Dashboard model
    final mockDashJson = {
      'has_guru_wali': true,
      'guru_wali': {
        'id': '19',
        'name': 'Sutrisno, S.Pd.',
        'nip': '198501012010011001',
        'photo_url': null,
        'phone': '08123456789',
        'nama_kelompok': 'Kelompok Sutrisno, S.Pd.',
        'tahun_ajaran': '2026/2027',
        'tanggal_bergabung': '2026-10-01',
        'formatted_tanggal_bergabung': '01 Oct 2026',
      },
      'counts': {
        'semua': 2,
        'menunggu': 0,
        'dijadwalkan': 0,
        'selesai': 2,
        'ditolak': 0,
        'klasikal': 1,
        'kelompok_kecil': 0,
        'total_klasikal': 1,
        'catatan_guru': 0,
      },
    };

    final dashResp = SiswaGuruWaliDashboardResponse.fromJson(mockDashJson);
    expect(dashResp.hasGuruWali, isTrue);
    expect(dashResp.guruWali?.name, equals('Sutrisno, S.Pd.'));
    expect(dashResp.counts.semua, equals(2));
    expect(dashResp.counts.selesai, equals(2));
    expect(dashResp.counts.klasikal, equals(1));
    expect(dashResp.counts.kelompokKecil, equals(0));
    expect(dashResp.counts.totalKlasikal, equals(1));

    // 2. Konsultasi List Item
    final mockKonsulItem = SiswaKonsultasiItem(
      id: 'konsul-01',
      kategori: 'Akademik',
      topik: 'Kesulitan Belajar Matematika Aljabar',
      detail: 'Saya sering kesulitan mengikuti penjelasan aljabar di kelas.',
      mode: 'Tatap Muka',
      status: 'Selesai',
      statusLabel: 'Selesai',
      statusKey: 'selesai',
      isCancellable: false,
      canChat: false,
      canFeedback: false,
      unreadMessagesCount: 0,
      guruName: 'Sutrisno, S.Pd.',
      jadwalPasti: '2026-10-03 09:00:00',
      formattedJadwalPasti: 'Sabtu, 03 Okt 2026, 09:00 WIB',
      tanggapanGuru: 'Sesi konsultasi tuntas di gazebo perpustakaan.',
      feedbackRating: 5,
      feedbackEmoji: 'Lega',
      feedbackNote: 'Terimakasih Bapak atas bimbingannya',
      createdAt: '2026-10-02 08:00:00',
      formattedCreatedAt: '02 Okt 2026, 08:00',
    );

    expect(mockKonsulItem.statusKey, equals('selesai'));
    expect(mockKonsulItem.feedbackRating, equals(5));

    // 3. Klasikal List Item
    final mockKlasikalItem = SiswaBimbinganKlasikalItem(
      id: 'klasikal-01',
      jenisPendampingan: 'Individu • Akademik',
      kategoriPendampingan: 'Akademik',
      tanggalWaktu: '2026-10-03 09:30:00',
      formattedDate: 'Saturday, 03 October 2026',
      formattedTime: '09:30',
      uraianPembahasan:
          'Topik: "Kesulitan Memahami Materi Matematika (Aljabar) & Persiapan Ujian"\n\n'
          'Permasalahan Siswa:\n'
          '"Saya sering tertinggal saat penjelasan materi Aljabar di kelas dan butuh saran metode belajar yang lebih pas agar nilai tidak turun."\n\n'
          'Tanggapan Guru:\n'
          'Jadwal konsultasi disetujui. Silakan temui di gazebo depan perpustakaan\n\n'
          'Ulasan & Refleksi Siswa:\n'
          '- Penilaian Sesi: 5/5 (Perasaan: Lega)\n'
          '- Catatan Murid: "Terimakasih Bapak atas bimbingan dan arahannya "',
      rencanaTindakLanjut: 'Mengerjakan latihan soal mandiri bab 3 dan konsultasi lanjutan bila perlu',
      statusSesi: 'Tuntas / Selesai',
      guruName: 'Sutrisno, S.Pd.',
      isPublicNote: true,
    );

    expect(mockKlasikalItem.guruName, equals('Sutrisno, S.Pd.'));
    expect(mockKlasikalItem.isPublicNote, isTrue);
  });
}
