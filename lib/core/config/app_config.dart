/// Konfigurasi Utama Aplikasi Mobile
///
/// Nilai konstanta di bawah ini diinjeksi saat build APK (Beda Sekolah Beda APK).
/// Contoh: flutter build apk --dart-define=BASE_URL="https://smpn1sampang.sch.id/api/v1"
class AppConfig {
  /// Base URL API Laravel Backend
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://coba.haflaitsolution.my.id/api/v1',
  );

  /// Nama Aplikasi yang ditampilkan di UI
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'SMP Negeri 3 Kedungreja',
  );

  /// Kode Unik / NPSN Sekolah
  static const String schoolCode = String.fromEnvironment(
    'SCHOOL_CODE',
    defaultValue: '20528990',
  );

  /// Warna Primer Sekolah (Format Hex: 0xFF1E40AF)
  static const int primaryColorHex = int.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: 0xFF1E40AF, // Biru Navy Elegan
  );

  /// Versi Aplikasi
  static const String appVersion = '1.0.0';

  /// Timeout Jaringan (Milidetik)
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

