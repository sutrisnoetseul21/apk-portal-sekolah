import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Model data sesi login pengguna yang tersimpan di perangkat
class SavedUserSession {
  final String role;
  final String name;
  final String identifier;
  final String roleLabel;
  final String? token;
  final String schoolName;
  final String? schoolLogoUrl;
  final String? schoolLogoBase64;

  const SavedUserSession({
    required this.role,
    required this.name,
    required this.identifier,
    required this.roleLabel,
    this.token,
    required this.schoolName,
    this.schoolLogoUrl,
    this.schoolLogoBase64,
  });
}

/// Penyimpanan sesi login permanen agar pengguna tidak perlu login berulang kali
/// kecuali menekan tombol Logout secara eksplisit.
class SessionStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyRole = 'auth_role';
  static const String _keyName = 'auth_name';
  static const String _keyIdentifier = 'auth_identifier';
  static const String _keyRoleLabel = 'auth_role_label';
  static const String _keyToken = 'auth_token';
  static const String _keySchoolName = 'auth_school_name';
  static const String _keySchoolLogoUrl = 'auth_school_logo_url';
  static const String _keySchoolLogoBase64 = 'auth_school_logo_base64';

  // Fallback in-memory jika platform web/linux membatasi secure storage
  static SavedUserSession? _memoryFallback;

  /// Simpan sesi setelah login berhasil
  static Future<void> saveSession({
    required String role,
    required String name,
    required String identifier,
    required String roleLabel,
    String? token,
    required String schoolName,
    String? schoolLogoUrl,
    String? schoolLogoBase64,
  }) async {
    _memoryFallback = SavedUserSession(
      role: role,
      name: name,
      identifier: identifier,
      roleLabel: roleLabel,
      token: token,
      schoolName: schoolName,
      schoolLogoUrl: schoolLogoUrl,
      schoolLogoBase64: schoolLogoBase64,
    );

    try {
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyRole, value: role);
      await _storage.write(key: _keyName, value: name);
      await _storage.write(key: _keyIdentifier, value: identifier);
      await _storage.write(key: _keyRoleLabel, value: roleLabel);
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: _keyToken, value: token);
      } else {
        await _storage.delete(key: _keyToken);
      }
      await _storage.write(key: _keySchoolName, value: schoolName);
      if (schoolLogoUrl != null && schoolLogoUrl.isNotEmpty) {
        await _storage.write(key: _keySchoolLogoUrl, value: schoolLogoUrl);
      } else {
        await _storage.delete(key: _keySchoolLogoUrl);
      }
      if (schoolLogoBase64 != null && schoolLogoBase64.isNotEmpty) {
        await _storage.write(key: _keySchoolLogoBase64, value: schoolLogoBase64);
      } else {
        await _storage.delete(key: _keySchoolLogoBase64);
      }
    } catch (_) {
      // Tetap aman menggunakan _memoryFallback jika storage gagal diakses
    }
  }

  /// Ambil sesi yang tersimpan saat aplikasi dibuka
  static Future<SavedUserSession?> getSession() async {
    try {
      final isLoggedIn = await _storage.read(key: _keyIsLoggedIn);
      final identifier = await _storage.read(key: _keyIdentifier);

      if (isLoggedIn == 'true' &&
          identifier != null &&
          identifier.trim().isNotEmpty) {
        final role = await _storage.read(key: _keyRole) ?? 'guru';
        final name = await _storage.read(key: _keyName) ?? identifier;
        final roleLabel =
            await _storage.read(key: _keyRoleLabel) ?? 'Wali Kelas / Guru';
        final token = await _storage.read(key: _keyToken);
        final schoolName =
            await _storage.read(key: _keySchoolName) ??
            'SMP Negeri 3 Kedungreja';
        final schoolLogoUrl = await _storage.read(key: _keySchoolLogoUrl);
        final schoolLogoBase64 = await _storage.read(key: _keySchoolLogoBase64);

        return SavedUserSession(
          role: role,
          name: name,
          identifier: identifier,
          roleLabel: roleLabel,
          token: token,
          schoolName: schoolName,
          schoolLogoUrl: schoolLogoUrl,
          schoolLogoBase64: schoolLogoBase64,
        );
      }
    } catch (_) {}

    return _memoryFallback;
  }

  /// Hapus sesi HANYA ketika pengguna menekan tombol Logout sendiri
  static Future<void> clearSession() async {
    _memoryFallback = null;
    try {
      await _storage.delete(key: _keyIsLoggedIn);
      await _storage.delete(key: _keyRole);
      await _storage.delete(key: _keyName);
      await _storage.delete(key: _keyIdentifier);
      await _storage.delete(key: _keyRoleLabel);
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keySchoolName);
      await _storage.delete(key: _keySchoolLogoUrl);
      await _storage.delete(key: _keySchoolLogoBase64);
    } catch (_) {}
  }
}

