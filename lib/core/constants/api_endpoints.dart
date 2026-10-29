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
}

