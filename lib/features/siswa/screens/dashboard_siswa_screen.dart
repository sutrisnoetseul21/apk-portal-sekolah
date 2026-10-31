import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/widgets/school_logo_widget.dart';
import '../../auth/screens/login_screen.dart';
import '../models/siswa_dashboard_model.dart';
import '../services/siswa_dashboard_service.dart';
import 'presensi_siswa_screen.dart';
import 'ijin_kehadiran_siswa_screen.dart';
import 'guru_wali_siswa_screen.dart';
import 'spikap_siswa_screen.dart';
import 'perpustakaan_siswa_screen.dart';
import 'kartu_siswa_screen.dart';
import 'profil_siswa_screen.dart';

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
    this.schoolName = 'SMP Negeri 3 Kedungreja',
    this.token,
    this.schoolLogoUrl,
    this.schoolLogoBase64,
    this.service,
  });

  @override
  State<DashboardSiswaScreen> createState() => _DashboardSiswaScreenState();
}

class _DashboardSiswaScreenState extends State<DashboardSiswaScreen> {
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
          if (summary.schoolLogoUrl != null && summary.schoolLogoUrl!.isNotEmpty) {
            _schoolLogoUrl = summary.schoolLogoUrl;
          }
        });
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
    final schoolName = _summary?.schoolName ?? widget.schoolName;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                schoolName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Kartu Pelajar Barcode Digital',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: barcodeData,
                      width: 260,
                      height: 90,
                      drawText: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'NISN: $nisn • $className',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Tutup'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _navigateToKartu();
                      },
                      icon: const Icon(Icons.badge_rounded, size: 16),
                      label: const Text('Buka Kartu & PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentAvatar(String name) {
    final clean = name.trim();
    final initial = clean.isNotEmpty ? clean[0].toUpperCase() : 'S';

    if (_studentPhotoUrl != null &&
        _studentPhotoUrl!.isNotEmpty &&
        !_studentPhotoUrl!.toLowerCase().endsWith('.svg')) {
      return Image.network(
        _studentPhotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitialAvatar(initial),
      );
    }

    return _buildInitialAvatar(initial);
  }

  Widget _buildInitialAvatar(String initial) {
    return Container(
      color: Colors.white.withValues(alpha: 0.25),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  void _navigateToPresensi() {
    final currentStudentName = _summary?.student.name ?? widget.studentName;
    final currentIdentifier = _summary?.student.nisn ?? widget.identifier;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PresensiSiswaScreen(
          identifier: currentIdentifier,
          studentName: currentStudentName,
          schoolName: _summary?.schoolName ?? widget.schoolName,
          token: widget.token,
          schoolLogoUrl: _schoolLogoUrl,
          schoolLogoBase64: _schoolLogoBase64,
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
          schoolName: _summary?.schoolName ?? widget.schoolName,
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
          schoolName: _summary?.schoolName ?? widget.schoolName,
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
          schoolName: _summary?.schoolName ?? widget.schoolName,
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
          schoolName: _summary?.schoolName ?? widget.schoolName,
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
          schoolName: _summary?.schoolName ?? widget.schoolName,
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
          schoolName: _summary?.schoolName ?? widget.schoolName,
          token: widget.token,
        ),
      ),
    );

    _fetchSummary();
  }

  /// Kartu Dinamis Status Presensi Masuk & Sholat Hari Ini
  Widget _buildTodayAttendanceCard() {
    final att = _summary?.todayAttendance;
    final sholat = _summary?.todaySholat;

    // Presensi Config
    Color attColor = const Color(0xFF64748B);
    IconData attIcon = Icons.radio_button_unchecked_rounded;
    String attTitle = 'Belum Presensi';
    String attSubtitle = 'Presensi Masuk';

    if (att != null) {
      if (att.status == 'hadir') {
        attColor = const Color(0xFF059669);
        attIcon = Icons.check_circle_outline_rounded;
        attTitle = 'Tepat Waktu';
        if (att.scanInTime != null) {
          attSubtitle = 'Masuk: ${att.scanInTime} WIB';
        }
      } else if (att.status == 'telat') {
        attColor = const Color(0xFFD97706);
        attIcon = Icons.access_time_rounded;
        attTitle = 'Terlambat ${att.lateMinutes}m';
        if (att.scanInTime != null) {
          attSubtitle = 'Masuk: ${att.scanInTime} WIB';
        }
      } else if (att.status == 'libur') {
        attColor = const Color(0xFF64748B);
        attIcon = Icons.weekend_outlined;
        attTitle = 'Hari Libur';
        attSubtitle = 'Kalender Sekolah';
      } else if (att.status == 'sakit') {
        attColor = const Color(0xFFE11D48);
        attIcon = Icons.local_hospital_outlined;
        attTitle = 'Sakit';
        attSubtitle = 'Ijin Terverifikasi';
      } else if (att.status == 'izin') {
        attColor = const Color(0xFF2563EB);
        attIcon = Icons.assignment_turned_in_outlined;
        attTitle = 'Izin';
        attSubtitle = 'Ijin Terverifikasi';
      } else if (att.status == 'alpa') {
        attColor = const Color(0xFFDC2626);
        attIcon = Icons.cancel_outlined;
        attTitle = 'Alpa';
        attSubtitle = 'Tidak Hadir';
      }
    }

    // Sholat Config
    Color sholatColor = const Color(0xFF64748B);
    IconData sholatIcon = Icons.mosque_outlined;
    String sholatTitle = 'Belum Ada Data';
    String sholatSubtitle = 'Sholat Dhuhur';

    if (sholat != null) {
      if (!sholat.enabled) {
        sholatColor = const Color(0xFF94A3B8);
        sholatIcon = Icons.info_outline;
        sholatTitle = 'Non-Aktif';
      } else if (sholat.status == 'berjamaah') {
        sholatColor = const Color(0xFF0D9488);
        sholatIcon = Icons.mosque_outlined;
        sholatTitle = 'Berjamaah';
      } else if (sholat.status == 'masbuk') {
        sholatColor = const Color(0xFFD97706);
        sholatIcon = Icons.mosque_outlined;
        sholatTitle = 'Masbuk';
      } else if (sholat.status == 'halangan') {
        sholatColor = const Color(0xFF7C3AED);
        sholatIcon = Icons.event_busy_outlined;
        sholatTitle = 'Halangan/Haid';
      } else if (sholat.status == 'libur') {
        sholatColor = const Color(0xFF64748B);
        sholatIcon = Icons.weekend_outlined;
        sholatTitle = 'Hari Libur';
      } else {
        sholatColor = const Color(0xFF64748B);
        sholatIcon = Icons.radio_button_unchecked_rounded;
        sholatTitle = 'Belum Presensi';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToPresensi,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
        children: [
          // Status Presensi Pagi
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: attColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(attIcon, color: attColor, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attSubtitle,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        attTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: attColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 12),
          // Status Sholat Dhuhur
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: sholatColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(sholatIcon, color: sholatColor, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sholatSubtitle,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        sholatTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: sholatColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
);
  }

  /// Grid Responsif 3 Kolom di Tablet dan 1 Kolom di HP
  Widget _buildResponsiveMenuGrid(BuildContext context, List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          // Smartphone: 1 Kolom
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cards,
          );
        }

        // Tablet / Layar Lebar: 3 Kolom per Baris
        const int crossAxisCount = 3;
        final List<Widget> rows = [];
        for (int i = 0; i < cards.length; i += crossAxisCount) {
          final List<Widget> rowItems = [];
          for (int j = 0; j < crossAxisCount; j++) {
            if (i + j < cards.length) {
              rowItems.add(
                Expanded(child: cards[i + j]),
              );
            } else {
              rowItems.add(const Expanded(child: SizedBox.shrink()));
            }
            if (j < crossAxisCount - 1) {
              rowItems.add(const SizedBox(width: 12));
            }
          }
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rowItems,
              ),
            ),
          );
          rows.add(const SizedBox(height: 12));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
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
                    _summary?.schoolName ?? widget.schoolName,
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

              // =========================================================
              // 1. HERO WELCOME CARD PELAJAR (DENGAN AVATAR DI KANAN)
              // =========================================================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF1D4ED8),
                      Color(0xFF1E40AF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PORTAL SISWA & PELAJAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Hai, $currentStudentName!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NISN: $currentIdentifier • $currentClassName',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Semangat belajar! Pantau kehadiran, ibadah sholat, dan ajukan permohonan ijin secara mandiri dari aplikasi ini.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Avatar Siswa
                    GestureDetector(
                      onTap: _navigateToProfil,
                      child: Tooltip(
                        message: 'Buka Profil Siswa',
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _buildStudentAvatar(currentStudentName),
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              right: 1,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =========================================================
              // 2. KARTU CEPAT BARCODE PELAJAR DIGITAL
              // =========================================================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon Scan Box
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Kartu Pelajar Barcode',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF0284C7)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Scan barcode di gerbang masuk sekolah & peminjaman perpustakaan.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _showBarcodeFullscreen,
                      icon: const Icon(Icons.fullscreen_rounded, size: 18),
                      label: const Text('Buka', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // =========================================================
              // 3. KARTU STATUS PRESENSI HARI INI
              // =========================================================
              _buildTodayAttendanceCard(),

              const SizedBox(height: 20),

              // =========================================================
              // 4. HEADER PINTASAN 7 MENU PORTAL SISWA
              // =========================================================
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

              // =========================================================
              // 5. DAFTAR 7 MENU SISWA (RESPONSIF 3 KOLOM DI TABLET)
              // =========================================================
              _buildResponsiveMenuGrid(
                context,
                [
                  // MENU 1: Presensi
                  _SiswaMenuBoxCard(
                    number: 1,
                    title: 'Presensi & Akademik',
                    description:
                        'Pantau catatan kehadiran harian, jam scan masuk/pulang, sholat dhuhur, dan matriks kalender bulanan.',
                    badgeText: 'Kalender & Rekap',
                    icon: Icons.calendar_month_rounded,
                    accentColor: const Color(0xFF059669),
                    primaryActionLabel: 'Buka Presensi',
                    onTap: _navigateToPresensi,
                  ),

                  // MENU 2: Pengajuan Ijin Kehadiran
                  _SiswaMenuBoxCard(
                    number: 2,
                    title: 'Pengajuan Ijin Kehadiran',
                    description:
                        'Kirim permohonan ijin atau sakit secara online dilengkapi foto surat dokter (kompresi otomatis hemat kuota).',
                    badgeText: (_summary?.quickStats.pendingLeavesCount ?? 0) > 0
                        ? '${_summary!.quickStats.pendingLeavesCount} Menunggu'
                        : 'Ijin / Sakit Online',
                    icon: Icons.assignment_outlined,
                    accentColor: const Color(0xFFE11D48),
                    primaryActionLabel: 'Ajukan Ijin',
                    onTap: _navigateToIjinKehadiran,
                  ),

                  // MENU 3: SI-WALI
                  _SiswaMenuBoxCard(
                    number: 3,
                    title: 'Guru Wali (SI-WALI)',
                    description:
                        'Ruang aman bercerita dan konsultasi dengan Guru Wali asuh Anda, serta info bimbingan klasikal kelas.',
                    badgeText: (_summary?.quickStats.activeCounselingCount ?? 0) > 0
                        ? '${_summary!.quickStats.activeCounselingCount} Sesi Aktif'
                        : 'Ruang Cerita & Bimbingan',
                    icon: Icons.favorite_border_rounded,
                    accentColor: const Color(0xFF2563EB),
                    primaryActionLabel: 'Buka SI-WALI',
                    onTap: _navigateToGuruWali,
                  ),

                  // MENU 4: SPIKAP
                  _SiswaMenuBoxCard(
                    number: 4,
                    title: 'SPIKAP (Karakter & Lapor)',
                    description:
                        'Layanan pengaduan anti-perundungan aman (opsi anonim) dan transparansi buku saku catatan karakter.',
                    badgeText: (_summary?.quickStats.spikapReportsCount ?? 0) > 0
                        ? '${_summary!.quickStats.spikapReportsCount} Laporan'
                        : 'Anti-Perundungan',
                    icon: Icons.shield_outlined,
                    accentColor: const Color(0xFFDC2626),
                    primaryActionLabel: 'Buka SPIKAP',
                    onTap: _navigateToSpikap,
                  ),

                  // MENU 5: Perpustakaan
                  _SiswaMenuBoxCard(
                    number: 5,
                    title: 'Perpustakaan Siswa',
                    description:
                        'Cek status buku yang sedang Anda pinjam, riwayat pengembalian, dan histori kunjungan perpustakaan.',
                    badgeText: (_summary?.quickStats.activeLoansCount ?? 0) > 0
                        ? '${_summary!.quickStats.activeLoansCount} Buku Dipinjam'
                        : 'Pinjaman & Literasi',
                    icon: Icons.local_library_outlined,
                    accentColor: const Color(0xFFD97706),
                    primaryActionLabel: 'Buka Perpustakaan',
                    onTap: _navigateToPerpustakaan,
                  ),

                  // MENU 6: Kartu Pelajar & Cetak PDF
                  _SiswaMenuBoxCard(
                    number: 6,
                    title: 'Kartu Pelajar & Unduh PDF',
                    description:
                        'Tampilan kartu barcode Code 128 resmi sekolah dan fitur unduh berkas PDF kartu pelajar siap cetak.',
                    badgeText: 'Barcode & Cetak PDF',
                    icon: Icons.badge_outlined,
                    accentColor: const Color(0xFF7C3AED),
                    primaryActionLabel: 'Lihat Kartu PDF',
                    onTap: _navigateToKartu,
                  ),

                  // MENU 7: Profil Saya
                  _SiswaMenuBoxCard(
                    number: 7,
                    title: 'Profil Saya',
                    description:
                        'Lihat biodata resmi, data orang tua/wali, perbarui nomor HP WhatsApp, dan ganti kata sandi akun.',
                    badgeText: 'Biodata & Sandi',
                    icon: Icons.person_outline_rounded,
                    accentColor: const Color(0xFF0284C7),
                    primaryActionLabel: 'Buka Profil',
                    onTap: _navigateToProfil,
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget Kartu Kotak Menu Portal Siswa
class _SiswaMenuBoxCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String badgeText;
  final IconData icon;
  final Color accentColor;
  final String primaryActionLabel;
  final VoidCallback onTap;

  const _SiswaMenuBoxCard({
    required this.number,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.icon,
    required this.accentColor,
    required this.primaryActionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accentColor, size: 23),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        badgeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      primaryActionLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Colors.white,
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
