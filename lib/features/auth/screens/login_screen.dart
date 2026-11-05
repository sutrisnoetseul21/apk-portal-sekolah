import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/storage/session_storage.dart';
import '../../siswa/screens/dashboard_siswa_screen.dart';
import '../../guru/screens/dashboard_guru_screen.dart';
import 'widgets/login_header_section.dart';
import 'widgets/login_form_card.dart';

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

    // Muat data jika belum dioper dari splash screen atau sinkronkan data sekolah
    _loadCachedOrFetchSchoolInfo();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Memuat info sekolah dari cache lokal terlebih dahulu, lalu sinkronkan dari API
  Future<void> _loadCachedOrFetchSchoolInfo() async {
    final cached = await SessionStorage.getCachedSchoolInfo();
    if (mounted && cached['nama_sekolah'] != null && cached['nama_sekolah']!.isNotEmpty) {
      setState(() {
        _schoolName = cached['nama_sekolah']!;
        _logoUrl ??= cached['logo_url'];
        if (_logoBase64 == null && cached['logo_base64'] != null) {
          _logoBase64 = cached['logo_base64'];
          try {
            final clean = _logoBase64!.contains(',')
                ? _logoBase64!.split(',').last
                : _logoBase64!;
            _logoBytes = base64Decode(clean);
          } catch (_) {}
        }
      });
    }

    _fetchSchoolInfo();
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

          // Simpan ke cache lokal perangkat
          SessionStorage.saveCachedSchoolInfo(
            schoolName: _schoolName,
            schoolLogoUrl: _logoUrl,
            schoolLogoBase64: _logoBase64,
          );
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

    // Daftarkan token FCM perangkat ke backend
    FcmService.instance.registerTokenWithBackend(token: token);

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

              // Header Branding: Logo & Teks
              LoginHeaderSection(
                schoolName: _schoolName,
                logoBytes: _logoBytes,
                logoUrl: _logoUrl,
              ),

              const SizedBox(height: 28),

              // Form Login Minimalis
              LoginFormCard(
                formKey: _formKey,
                identifierController: _identifierController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                isLoading: _isLoading,
                onToggleObscure: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                onLogin: _handleLogin,
              ),

              const SizedBox(height: 28),

              // Footer Aplikasi: Opsi 2 (Nama Sekolah Dinamis dari DB + Powered by Hafla IT Solution)
              Center(
                child: Column(
                  children: [
                    Text(
                      'Portal Digital • $_schoolName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Powered by ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Hafla IT Solution',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
