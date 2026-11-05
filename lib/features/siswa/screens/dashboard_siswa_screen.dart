import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/widgets/school_logo_widget.dart';
import '../../auth/screens/login_screen.dart';
import '../../notification/screens/notification_inbox_screen.dart';
import '../models/siswa_dashboard_model.dart';
import '../services/siswa_dashboard_service.dart';
import 'guru_wali_siswa_screen.dart';
import 'ijin_kehadiran_siswa_screen.dart';
import 'kartu_siswa_screen.dart';
import 'perpustakaan_siswa_screen.dart';
import 'presensi_siswa_screen.dart';
import 'profil_siswa_screen.dart';
import 'spikap_siswa_screen.dart';
import 'widgets/dashboard/grid/dashboard_siswa_menu_grid.dart';
import 'widgets/dashboard/modals/dialog_quick_barcode.dart';
import 'widgets/dashboard/sections/dashboard_siswa_barcode_card.dart';
import 'widgets/dashboard/sections/dashboard_siswa_hero_banner.dart';
import 'widgets/dashboard/sections/dashboard_today_attendance_card.dart';

/// Beranda Utama Portal Siswa & Akun Pelajar
/// Menampilkan 7 Menu Kotak-Kotak Pintasan mengacu pada /portal-siswa/*
/// dengan dukungan Layout Responsif (1 Kolom di HP, 3 Kolom di Tablet)
class DashboardSiswaScreen extends StatefulWidget {
  final String studentName;
  final String identifier;
  final String schoolName;
  final String? token;
  final String? schoolLogoUrl;
  final String? schoolLogoBase64;
  final SiswaDashboardService? service;

  const DashboardSiswaScreen({
    super.key,
    required this.studentName,
    required this.identifier,
    this.schoolName = '',
    this.token,
    this.schoolLogoUrl,
    this.schoolLogoBase64,
    this.service,
  });

  @override
  State<DashboardSiswaScreen> createState() => _DashboardSiswaScreenState();
}

class _DashboardSiswaScreenState extends State<DashboardSiswaScreen> {
  late String _schoolName;
  String? _schoolLogoUrl;
  String? _schoolLogoBase64;
  String? _studentPhotoUrl;
  String _className = 'Kelas Siswa';
  bool _isLoading = true;
  String? _errorMessage;
  SiswaDashboardSummary? _summary;
  late SiswaDashboardService _service;

  @override
  void initState() {
    super.initState();
    _schoolName = widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName;
    _schoolLogoUrl = widget.schoolLogoUrl;
    _schoolLogoBase64 = widget.schoolLogoBase64;
    _initService();
    _loadStoredSession();
    _fetchSummary();
  }

  void _initService() {
    _service = widget.service ??
        SiswaDashboardService.create(
          token: widget.token,
          identifier: widget.identifier,
        );
  }

  Future<void> _fetchSummary() async {
    try {
      if (mounted) setState(() => _errorMessage = null);
      final summary = await _service.getDashboardSummary(identifier: widget.identifier);
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
          _className = summary.student.className;
          _studentPhotoUrl = summary.student.avatarUrl;
          if (summary.schoolName.isNotEmpty) {
            _schoolName = summary.schoolName;
          }
          if (summary.schoolLogoUrl != null && summary.schoolLogoUrl!.isNotEmpty) {
            _schoolLogoUrl = summary.schoolLogoUrl;
          }
        });

        // Simpan / perbarui ke SessionStorage agar sinkron
        if (_schoolName.isNotEmpty && _schoolName != AppConfig.appName) {
          SessionStorage.saveSession(
            role: 'siswa',
            name: summary.student.name.isNotEmpty ? summary.student.name : widget.studentName,
            identifier: widget.identifier,
            roleLabel: 'Siswa Aktif',
            token: widget.token,
            schoolName: _schoolName,
            schoolLogoUrl: _schoolLogoUrl,
            schoolLogoBase64: _schoolLogoBase64,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _loadStoredSession() async {
    try {
      final session = await SessionStorage.getSession();
      if (session != null && mounted) {
        setState(() {
          if (_schoolName.isEmpty && session.schoolName.isNotEmpty) {
            _schoolName = session.schoolName;
          }
          _schoolLogoUrl ??= session.schoolLogoUrl;
          _schoolLogoBase64 ??= session.schoolLogoBase64;
        });
      }
    } catch (_) {}
  }

  void _showBarcodeFullscreen() {
    final studentName = _summary?.student.name ?? widget.studentName;
    final nisn = _summary?.student.nisn ?? widget.identifier;
    final className = _summary?.student.className ?? _className;
    final barcodeData = (_summary?.student.barcodeCode.isNotEmpty == true)
        ? _summary!.student.barcodeCode
        : (widget.identifier.trim().isNotEmpty ? widget.identifier.trim() : '1234567890');

    DialogQuickBarcode.show(
      context,
      schoolName: _schoolName,
      studentName: studentName,
      nisn: nisn,
      className: className,
      barcodeData: barcodeData,
      onOpenFullCard: _navigateToKartu,
    );
  }

  void _navigateToPresensi({int initialTabIndex = 0}) {
    final currentStudentName = _summary?.student.name ?? widget.studentName;
    final currentIdentifier = _summary?.student.nisn ?? widget.identifier;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PresensiSiswaScreen(
          identifier: currentIdentifier,
          studentName: currentStudentName,
          schoolName: _schoolName,
          token: widget.token,
          schoolLogoUrl: _schoolLogoUrl,
          schoolLogoBase64: _schoolLogoBase64,
          initialTabIndex: initialTabIndex,
        ),
      ),
    );
  }

  void _navigateToIjinKehadiran() async {
    final currentStudentName = _summary?.student.name ?? widget.studentName;
    final currentIdentifier = _summary?.student.nisn ?? widget.identifier;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IjinKehadiranSiswaScreen(
          identifier: currentIdentifier,
          studentName: currentStudentName,
          schoolName: _schoolName,
          token: widget.token,
          schoolLogoUrl: _schoolLogoUrl,
          schoolLogoBase64: _schoolLogoBase64,
        ),
      ),
    );

    _fetchSummary();
  }

  void _navigateToGuruWali() async {
    final currentStudentName = _summary?.student.name ?? widget.studentName;
    final currentIdentifier = _summary?.student.nisn ?? widget.identifier;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuruWaliSiswaScreen(
          identifier: currentIdentifier,
          studentName: currentStudentName,
          schoolName: _schoolName,
          token: widget.token,
        ),
      ),
    );

    _fetchSummary();
  }

  void _navigateToSpikap() async {
    final currentStudentName = _summary?.student.name ?? widget.studentName;
    final currentIdentifier = _summary?.student.nisn ?? widget.identifier;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpikapSiswaScreen(
          identifier: currentIdentifier,
          studentName: currentStudentName,
          schoolName: _schoolName,
          token: widget.token,
        ),
      ),
    );

    _fetchSummary();
  }

  void _navigateToPerpustakaan() async {
    final currentStudentName = _summary?.student.name ?? widget.studentName;
    final currentIdentifier = _summary?.student.nisn ?? widget.identifier;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PerpustakaanSiswaScreen(
          identifier: currentIdentifier,
          studentName: currentStudentName,
          schoolName: _schoolName,
          token: widget.token,
        ),
      ),
    );

    _fetchSummary();
  }

  void _navigateToKartu() async {
    final currentStudentName = _summary?.student.name ?? widget.studentName;
    final currentIdentifier = _summary?.student.nisn ?? widget.identifier;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KartuSiswaScreen(
          identifier: currentIdentifier,
          studentName: currentStudentName,
          schoolName: _schoolName,
          token: widget.token,
        ),
      ),
    );

    _fetchSummary();
  }

  void _navigateToProfil() async {
    final currentStudentName = _summary?.student.name ?? widget.studentName;
    final currentIdentifier = _summary?.student.nisn ?? widget.identifier;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilSiswaScreen(
          identifier: currentIdentifier,
          studentName: currentStudentName,
          schoolName: _schoolName,
          token: widget.token,
        ),
      ),
    );

    _fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    final currentStudentName = _summary?.student.name ?? widget.studentName;
    final currentIdentifier = _summary?.student.nisn ?? widget.identifier;
    final currentClassName = _summary?.student.className ?? _className;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SchoolLogoWidget(
              size: 36,
              logoUrl: _schoolLogoUrl,
              logoBase64: _schoolLogoBase64,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Portal Siswa',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _schoolName,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Pusat Notifikasi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationInboxScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profil Saya',
            onPressed: _navigateToProfil,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: _fetchSummary,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar Portal',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  title: const Text('Keluar dari Portal Siswa?'),
                  content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Ya, Keluar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FcmService.instance.unregisterTokenWithBackend();
                await SessionStorage.clearSession();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSummary,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading && _summary == null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(minHeight: 3),
                ),

              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                        ),
                      ),
                      TextButton(
                        onPressed: _fetchSummary,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Coba Lagi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

              // 1. Hero Welcome Card Pelajar
              DashboardSiswaHeroBanner(
                studentName: currentStudentName,
                identifier: currentIdentifier,
                className: currentClassName,
                studentPhotoUrl: _studentPhotoUrl,
                onTapProfile: _navigateToProfil,
              ),

              const SizedBox(height: 16),

              // 2. Kartu Cepat Barcode Pelajar Digital
              DashboardSiswaBarcodeCard(
                onOpenBarcode: _showBarcodeFullscreen,
              ),

              const SizedBox(height: 14),

              // 3. Kartu Status Presensi Hari Ini
              DashboardTodayAttendanceCard(
                attendance: _summary?.todayAttendance,
                sholat: _summary?.todaySholat,
                onTapAttendance: () => _navigateToPresensi(initialTabIndex: 0),
                onTapSholat: () => _navigateToPresensi(initialTabIndex: 1),
              ),

              const SizedBox(height: 20),

              // 4. Header Pintasan 7 Menu Portal Siswa
              const Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pintasan Menu Portal Siswa',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                'Akses cepat layanan akademik dan kesiswaan mandiri:',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 14),

              // 5. Daftar 7 Menu Siswa (Responsif 1 Kolom HP / 3 Kolom Tablet)
              DashboardSiswaMenuGrid(
                summary: _summary,
                onTapPresensi: _navigateToPresensi,
                onTapIjin: _navigateToIjinKehadiran,
                onTapGuruWali: _navigateToGuruWali,
                onTapSpikap: _navigateToSpikap,
                onTapPerpustakaan: _navigateToPerpustakaan,
                onTapKartu: _navigateToKartu,
                onTapProfil: _navigateToProfil,
              ),

              const SizedBox(height: 24),

              // Footer Aplikasi (Portal Digital • Nama Sekolah + Powered by Hafla IT Solution)
              Center(
                child: Column(
                  children: [
                    Text(
                      'Portal Digital • ${_schoolName.isNotEmpty ? _schoolName : AppConfig.appName}',
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
                    const SizedBox(height: 4),
                    Text(
                      'Versi ${AppConfig.appVersion}',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
