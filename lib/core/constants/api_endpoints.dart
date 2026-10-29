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
  static const String guruJurnalCreate = '/guru/jurnal/create';
}

