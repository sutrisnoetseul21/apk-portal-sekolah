import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/session_storage.dart';
import '../../guru/screens/dashboard_guru_screen.dart';
import '../../siswa/screens/dashboard_siswa_screen.dart';
import 'login_screen.dart';

/// Splash Screen pembuka aplikasi: Menampilkan Logo Sekolah dan Nama Sekolah dinamis
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _schoolName = AppConfig.appName;
  Uint8List? _logoBytes;
  String? _logoBase64;
  String? _logoUrl;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Accept': 'application/json'},
    ),
  );

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Muat info sekolah (Logo & Nama) langsung saat splash screen terbuka
    _fetchSchoolInfoAndNavigate();
  }

  Future<void> _fetchSchoolInfoAndNavigate() async {
    final savedSession = await SessionStorage.getSession();

    try {
      final response = await _dio.get('${AppConfig.baseUrl}/school-info');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && mounted) {
          final String? fetchedName = data['nama_sekolah']?.toString();
          final String? fetchedBase64 = data['logo_base64']?.toString();
          final String? fetchedUrl = data['logo_url']?.toString();

          Uint8List? decodedBytes;
          if (fetchedBase64 != null && fetchedBase64.isNotEmpty) {
            try {
              final cleanBase64 = fetchedBase64.contains(',')
                  ? fetchedBase64.split(',').last
                  : fetchedBase64;
              decodedBytes = base64Decode(cleanBase64);
              // Pre-decode gambar ke memori raster sebelum ditampilkan agar tidak pernah kotak putih
              if (mounted) {
                await precacheImage(MemoryImage(decodedBytes), context);
              }
            } catch (_) {}
          }

          if (mounted) {
            setState(() {
              if (fetchedName != null && fetchedName.isNotEmpty) {
                _schoolName = fetchedName;
              }
              _logoBase64 = fetchedBase64;
              _logoBytes = decodedBytes;
              if (fetchedUrl != null && fetchedUrl.isNotEmpty) {
                _logoUrl = fetchedUrl;
              }
            });
          }
        }
      }
    } catch (_) {
      // Fallback offline aman
    }

    // Tahan tampilan Splash Screen sebentar setelah logo siap
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    // Jika sesi login sudah tersimpan di perangkat, langsung masuk ke Portal tanpa login ulang
    if (savedSession != null) {
      final targetSchool = _schoolName.isNotEmpty
          ? _schoolName
          : savedSession.schoolName;
      final Widget targetDashboard = savedSession.role == 'siswa'
          ? DashboardSiswaScreen(
              studentName: savedSession.name,
              identifier: savedSession.identifier,
              schoolName: targetSchool,
            )
          : DashboardGuruScreen(
              teacherName: savedSession.name,
              identifier: savedSession.identifier,
              roleLabel: savedSession.roleLabel,
              schoolName: targetSchool,
              token: savedSession.token,
            );

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => targetDashboard,
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => LoginScreen(
          initialSchoolName: _schoolName,
          initialLogoBytes: _logoBytes,
          initialLogoBase64: _logoBase64,
          initialLogoUrl: _logoUrl,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildSplashLogo() {
    if (_logoBytes != null) {
      return Image.memory(
        _logoBytes!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _buildDefaultLogo(),
      );
    }

    if (_logoUrl != null && _logoUrl!.isNotEmpty) {
      return Image.network(
        _logoUrl!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _buildDefaultLogo(),
      );
    }

    return _buildDefaultLogo();
  }

  Widget _buildDefaultLogo() {
    return Image.asset(
      'assets/images/logo_sekolah.png',
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => Icon(
        Icons.school_rounded,
        size: 56,
        color: AppColors.primary,
        semanticLabel: 'Logo Sekolah',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),

              // Logo & Nama Sekolah di Bagian Awal (Splash Screen)
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Logo Sekolah
                      Container(
                        width: 108,
                        height: 108,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child: _buildSplashLogo(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nama Sekolah di Bawah Logo
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _schoolName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer & Versi
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Versi ${AppConfig.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
