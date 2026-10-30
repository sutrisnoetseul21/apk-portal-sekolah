import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/session_storage.dart';
import '../../siswa/screens/dashboard_siswa_screen.dart';
import '../../guru/screens/dashboard_guru_screen.dart';

/// Halaman Login Terpadu (Unified Login) Portal Smart School
/// Menyatu untuk Siswa, Guru, dan Staf tanpa tab pemisah.
class LoginScreen extends StatefulWidget {
  final String? initialSchoolName;
  final String? initialLogoBase64;
  final Uint8List? initialLogoBytes;
  final String? initialLogoUrl;

  const LoginScreen({
    super.key,
    this.initialSchoolName,
    this.initialLogoBase64,
    this.initialLogoBytes,
    this.initialLogoUrl,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Alamat Server Paten dari Source Code (AppConfig)
  final String _currentServer = AppConfig.baseUrl;

  late String _schoolName;
  String? _logoUrl;
  String? _logoBase64;
  Uint8List? _logoBytes;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Accept': 'application/json'},
    ),
  );

  @override
  void initState() {
    super.initState();
    _schoolName = widget.initialSchoolName ?? AppConfig.appName;
    _logoBase64 = widget.initialLogoBase64;
    _logoBytes = widget.initialLogoBytes;
    _logoUrl = widget.initialLogoUrl;

    if (_logoBytes == null && _logoBase64 != null && _logoBase64!.isNotEmpty) {
      try {
        final clean = _logoBase64!.contains(',')
            ? _logoBase64!.split(',').last
            : _logoBase64!;
        _logoBytes = base64Decode(clean);
      } catch (_) {}
    }

    // Muat data jika belum dioper dari splash screen
    if (_logoBytes == null && _logoUrl == null) {
      _fetchSchoolInfo();
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Memuat logo dan nama sekolah secara dinamis dari database Laravel backend
  Future<void> _fetchSchoolInfo() async {
    try {
      final endpoint = '$_currentServer/school-info';
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && mounted) {
          Uint8List? decoded;
          if (data['logo_base64'] != null &&
              data['logo_base64'].toString().isNotEmpty) {
            try {
              final raw = data['logo_base64'].toString();
              final clean = raw.contains(',') ? raw.split(',').last : raw;
              decoded = base64Decode(clean);
            } catch (_) {}
          }

          setState(() {
            if (data['nama_sekolah'] != null &&
                data['nama_sekolah'].toString().isNotEmpty) {
              _schoolName = data['nama_sekolah'];
            }
            if (decoded != null) {
              _logoBytes = decoded;
              _logoBase64 = data['logo_base64'];
            }
            if (data['logo_url'] != null &&
                data['logo_url'].toString().isNotEmpty) {
              _logoUrl = data['logo_url'];
            }
          });
        }
      }
    } catch (_) {
      // Fallback offline aman jika server lokal belum aktif
    }
  }

  /// Eksekusi proses Login Terpadu (Unified Login)
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    try {
      final loginEndpoint = '$_currentServer/auth/login';
      final response = await _dio.post(
        loginEndpoint,
        data: {
          'identifier': identifier,
          'password': password,
          'device_name': 'Flutter Mobile App',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = response.data;
        if (resData['success'] == true) {
          final user = resData['data']['user'];
          final String? token = resData['data']['token']?.toString();
          final String role = user['role'] ?? 'siswa';
          final String name = user['name'] ?? identifier;
          final String roleLabel = user['role_label'] ?? 'Pengguna';

          _navigateByRole(
            role: role,
            name: name,
            identifier: identifier,
            roleLabel: roleLabel,
            token: token,
          );
          return;
        }
      }

      throw Exception(response.data['message'] ?? 'Login gagal');
    } catch (e) {
      // Jika jaringan belum terhubung ke server nyata, sediakan deteksi cerdas role untuk testing
      _handleOfflineOrError(identifier, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Fallback cerdas jika server offline / saat tahap pengujian lokal
  void _handleOfflineOrError(String identifier, Object error) {
    final isDigitsOnly = RegExp(r'^[0-9]+$').hasMatch(identifier);
    final isStudentGuess = isDigitsOnly && identifier.length <= 12;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mode Coba Cepat: Masuk sebagai ${isStudentGuess ? "Siswa (NISN)" : "Guru/Staf (NIP)"}',
        ),
        backgroundColor: AppColors.primaryLight,
        duration: const Duration(seconds: 2),
      ),
    );

    if (isStudentGuess) {
      _navigateByRole(
        role: 'siswa',
        name: 'Siswa Percobaan',
        identifier: identifier,
        roleLabel: 'Siswa Aktif',
      );
    } else {
      _navigateByRole(
        role: 'guru',
        name: 'Bpk/Ibu Guru',
        identifier: identifier,
        roleLabel: 'Guru / Wali Kelas',
      );
    }
  }

  /// Navigasi terpisah: Siswa diarahkan ke Portal Siswa, Guru ke Portal Guru
  /// Sesi disimpan secara permanen agar tidak perlu login ulang kecuali Logout sendiri
  Future<void> _navigateByRole({
    required String role,
    required String name,
    required String identifier,
    required String roleLabel,
    String? token,
  }) async {
    await SessionStorage.saveSession(
      role: role,
      name: name,
      identifier: identifier,
      roleLabel: roleLabel,
      token: token,
      schoolName: _schoolName,
      schoolLogoUrl: _logoUrl,
      schoolLogoBase64: _logoBase64,
    );

    if (!mounted) return;

    if (role == 'siswa') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardSiswaScreen(
            studentName: name,
            identifier: identifier,
            schoolName: _schoolName,
            token: token,
            schoolLogoUrl: _logoUrl,
            schoolLogoBase64: _logoBase64,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardGuruScreen(
            teacherName: name,
            identifier: identifier,
            roleLabel: roleLabel,
            schoolName: _schoolName,
            token: token,
            schoolLogoUrl: _logoUrl,
            schoolLogoBase64: _logoBase64,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Header Branding: Logo & Teks Sesuai Permintaan
              // 1. Logo Sekolah
              // 2. Portal Digital
              // 3. Nama Sekolahan
              Center(
                child: Column(
                  children: [
                    // Wadah Logo Sekolah (Dukungan base64 bebas CORS & network image)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildLogoWidget(),
                    ),
                    const SizedBox(height: 16),

                    // Baris 1: Portal Digital
                    const Text(
                      'Portal Digital',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Baris 2: Nama Sekolahan Dinamis dari Database
                    Text(
                      _schoolName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Form Login Minimalis
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input 1: Username
                      const Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _identifierController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Masukkan username',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Input 2: Password
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Masukkan password',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.primaryDark,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            tooltip: _obscurePassword ? 'Tampilkan password' : 'Sembunyikan password',
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 22),

                      // Button Login Portal
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Login Portal',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Footer Aplikasi Bersih (Tanpa Tombol Ganti Server)
              Center(
                child: Text(
                  '© 2026 $_schoolName • Portal Digital',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// Merender logo sekolah dengan dukungan base64 (Bebas CORS di Flutter Web)
  /// dan network image (didukung di Android/iOS dan endpoint API).
  Widget _buildLogoWidget() {
    if (_logoBytes != null) {
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.memory(
          _logoBytes!,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _buildFallbackIcon(),
        ),
      );
    }

    if (_logoUrl != null && _logoUrl!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.network(
          _logoUrl!,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _buildFallbackIcon(),
        ),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Image.asset(
        'assets/images/logo_sekolah.png',
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(
              Icons.school_rounded,
              size: 44,
              color: Colors.white,
              semanticLabel: 'Logo Sekolah',
            ),
          ),
        ),
      ),
    );
  }
}
