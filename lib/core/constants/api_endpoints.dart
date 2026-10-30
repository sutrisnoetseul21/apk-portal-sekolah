/// Daftar Endpoint REST API Laravel Sanctum
class ApiEndpoints {
  // Informasi Publik Sekolah
  static const String schoolInfo = '/school-info';

  // Autentikasi
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String fcmToken = '/auth/fcm-token';

  // Modul Siswa
  static const String siswaKartu = '/siswa/kartu';
  static const String siswaDashboard = '/siswa/dashboard';
  static const String siswaRiwayat = '/siswa/presensi/riwayat';
  static const String siswaIzin = '/siswa/izin';
  static const String siswaSpikap = '/siswa/spikap';

  // Modul Guru & Wali Kelas
  static const String guruClasses = '/guru/classes';
  static const String guruPresensiToday = '/guru/presensi/today';
  static const String guruPresensiUpdate = '/guru/presensi/update';
  static const String guruSholatToday = '/guru/sholat-dhuhur/today';
  static const String guruSholatBulk = '/guru/sholat-dhuhur/bulk';
  static const String guruIzinPending = '/guru/izin/pending';
  static String guruIzinApprove(String id) => '/guru/izin/$id/approve';

  // Menu 3: Jurnal Mengajar (/portal-guru/jurnal-mengajar)
  static const String guruJurnalList = '/guru/jurnal-mengajar';
  static const String guruJurnalFormOptions =
      '/guru/jurnal-mengajar/form-options';
  static const String guruJurnalStudents = '/guru/jurnal-mengajar/students';
  static const String guruJurnalExport = '/guru/jurnal-mengajar/export';
  static String guruJurnalDetail(String id) => '/guru/jurnal-mengajar/$id';
  static const String guruJurnalCreate = '/guru/jurnal-mengajar';

  // Menu 4: Persetujuan Ijin (/portal-guru/ijin-kehadiran)
  static const String guruIjinList = '/guru/ijin-kehadiran';
  static const String guruIjinNotifCheck =
      '/guru/ijin-kehadiran/notification-check';
  static String guruIjinDetail(String id) => '/guru/ijin-kehadiran/$id';
  static String guruIjinApprove(String id) =>
      '/guru/ijin-kehadiran/$id/approve';
  static String guruIjinReject(String id) => '/guru/ijin-kehadiran/$id/reject';
  static String guruIjinReset(String id) => '/guru/ijin-kehadiran/$id/reset';

  // Menu 5: Guru Wali (SI-WALI) (/portal-guru/guru-wali/*)
  static const String guruWaliDashboard = '/guru/guru-wali/dashboard';
  static const String guruWaliJurnalList = '/guru/guru-wali/jurnal';
  static const String guruWaliJurnalIndividual =
      '/guru/guru-wali/jurnal/individual';
  static const String guruWaliJurnalKlasikal = '/guru/guru-wali/jurnal/klasikal';
  static String guruWaliJurnalDetail(String id) => '/guru/guru-wali/jurnal/$id';
  static String guruWaliJurnalRujukBk(String id) =>
      '/guru/guru-wali/jurnal/$id/rujuk-bk';

  static const String guruWaliKonsultasiList = '/guru/guru-wali/konsultasi';
  static String guruWaliKonsultasiDetail(String id) =>
      '/guru/guru-wali/konsultasi/$id';
  static String guruWaliKonsultasiPesan(String id) =>
      '/guru/guru-wali/konsultasi/$id/pesan';
  static String guruWaliKonsultasiJadwalkan(String id) =>
      '/guru/guru-wali/konsultasi/$id/jadwalkan';
  static String guruWaliKonsultasiBalas(String id) =>
      '/guru/guru-wali/konsultasi/$id/balas';
  static String guruWaliKonsultasiTolak(String id) =>
      '/guru/guru-wali/konsultasi/$id/tolak';
  static String guruWaliKonsultasiKonversiJurnal(String id) =>
      '/guru/guru-wali/konsultasi/$id/konversi-jurnal';

  static const String guruWaliPemantauan = '/guru/guru-wali/pemantauan';
  static const String guruWaliCetakPdf = '/guru/guru-wali/cetak/pdf';

  // Menu 6: Data Siswa (/portal-guru/data-siswa/*)
  static const String guruDataSiswaOptions = '/guru/data-siswa/options';
  static const String guruDataSiswaStudents = '/guru/data-siswa/students';
  static String guruDataSiswaDetail(String id) => '/guru/data-siswa/student/$id';
  static String guruDataSiswaUpdateBiodata(String id) =>
      '/guru/data-siswa/student/$id/biodata';
  static String guruDataSiswaUpdateNoHp(String id) =>
      '/guru/data-siswa/student/$id/no-hp';
  static String guruDataSiswaGantiPassword(String id) =>
      '/guru/data-siswa/student/$id/ganti-password';
  static String guruDataSiswaUploadFoto(String id) =>
      '/guru/data-siswa/student/$id/upload-foto';
  static String guruDataSiswaCetakKartu(String id) =>
      '/guru/data-siswa/student/$id/cetak-kartu';
  static String guruDataSiswaCetakBiodata(String id) =>
      '/guru/data-siswa/student/$id/cetak-biodata';
  static const String guruDataSiswaCetakKartuMassal =
      '/guru/data-siswa/cetak-kartu-massal';
  static const String guruDataSiswaCetakBiodataMassal =
      '/guru/data-siswa/cetak-biodata-massal';
}

