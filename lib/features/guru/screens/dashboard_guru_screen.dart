import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/widgets/school_logo_widget.dart';
import '../../auth/screens/login_screen.dart';
import 'jurnal_mengajar_screen.dart';
import 'ijin_kehadiran_screen.dart';
import 'presensi_kelas_screen.dart';
import 'presensi_sholat_dhuhur_screen.dart';
import 'guru_wali_screen.dart';
import 'data_siswa_screen.dart';
import 'spikap_screen.dart';
import 'perpustakaan_screen.dart';
import 'profil_guru_screen.dart';
import '../models/guru_profil_model.dart';
import 'widgets/dialog_akses_spikap_ditolak.dart';

/// Beranda Utama Portal Guru (Tanpa Navigasi Kiri / Sidebar)
/// Menampilkan 9 Menu Kotak-Kotak mengacu pada /portal-guru
class DashboardGuruScreen extends StatefulWidget {
  final String teacherName;
  final String identifier;
  final String roleLabel;
  final String schoolName;
  final String? token;
  final String? schoolLogoUrl;
  final String? schoolLogoBase64;
  final String? teacherPhotoUrl;

  const DashboardGuruScreen({
    super.key,
    required this.teacherName,
    required this.identifier,
    this.roleLabel = 'Wali Kelas / Guru',
    this.schoolName = 'SMP Negeri 3 Kedungreja',
    this.token,
    this.schoolLogoUrl,
    this.schoolLogoBase64,
    this.teacherPhotoUrl,
  });

  @override
  State<DashboardGuruScreen> createState() => _DashboardGuruScreenState();
}

class _DashboardGuruScreenState extends State<DashboardGuruScreen> {
  int _kelasAmpuCount = 0;
  int _jurnalHariIniCount = 0;
  int _totalJurnalCount = 0;
  int _pendingLeaveCount = 0;
  int _approvedLeaveCount = 0;
  int _rejectedLeaveCount = 0;
  int _activeBooksCount = 0;
  int _pendingKonsultasiCount = 0;
  int _spikapCount = 0;
  bool _canAccessSpikap = false;
  String _spikapRoleLabel = 'Guru Mata Pelajaran';
  int _spikapDaruratCount = 0;
  bool _enableSholatDhuhur = true;
  String? _resolvedTeacherName;
  String? _schoolLogoUrl;
  String? _schoolLogoBase64;
  String? _teacherPhotoUrl;

  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _resolvedTeacherName = widget.teacherName;
    _schoolLogoUrl = widget.schoolLogoUrl;
    _schoolLogoBase64 = widget.schoolLogoBase64;
    _teacherPhotoUrl = widget.teacherPhotoUrl;

    _loadStoredLogo();

    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Accept': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
          if (widget.identifier.isNotEmpty)
            'X-User-Identifier': widget.identifier,
        },
      ),
    );
    _fetchSummary();
  }

  Future<void> _loadStoredLogo() async {
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

  Future<void> _fetchSummary() async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/guru/dashboard-summary',
        queryParameters: {'identifier': widget.identifier},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final d = response.data['data'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            if (d['teacher_name'] != null &&
                d['teacher_name'].toString().isNotEmpty) {
              _resolvedTeacherName = d['teacher_name'].toString();
            }
            if (d['photo_url'] != null &&
                d['photo_url'].toString().isNotEmpty) {
              _teacherPhotoUrl = d['photo_url'].toString();
            }
            _kelasAmpuCount = (d['kelas_ampu_count'] as num?)?.toInt() ?? 0;
            _jurnalHariIniCount =
                (d['jurnal_hari_ini_count'] as num?)?.toInt() ?? 0;
            _totalJurnalCount =
                (d['total_jurnal_count'] as num?)?.toInt() ?? 0;
            _pendingLeaveCount =
                (d['pending_leave_count'] as num?)?.toInt() ?? 0;
            _approvedLeaveCount =
                (d['approved_leave_count'] as num?)?.toInt() ?? 0;
            _rejectedLeaveCount =
                (d['rejected_leave_count'] as num?)?.toInt() ?? 0;
            _activeBooksCount =
                (d['active_books_count'] as num?)?.toInt() ?? 0;
            _pendingKonsultasiCount =
                (d['pending_konsultasi_count'] as num?)?.toInt() ?? 0;
            _spikapCount = (d['spikap_count'] as num?)?.toInt() ?? 0;
            _canAccessSpikap = d['can_access_spikap'] == true;
            _spikapRoleLabel =
                d['spikap_role_label']?.toString() ?? 'Guru Mata Pelajaran';
            _spikapDaruratCount =
                (d['spikap_darurat_count'] as num?)?.toInt() ?? 0;
            _enableSholatDhuhur = d['enable_sholat_dhuhur'] != false;
          });
        }
      }
    } catch (_) {}
  }

  void _openPresensiMenu() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PresensiKelasScreen(
              teacherName: _resolvedTeacherName ?? widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
            ),
          ),
        )
        .then((_) => _fetchSummary());
  }

  void _openSholatDhuhurMenu() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PresensiSholatDhuhurScreen(
              teacherName: _resolvedTeacherName ?? widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
            ),
          ),
        )
        .then((_) => _fetchSummary());
  }

  void _openJurnalMengajarMenu() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => JurnalMengajarScreen(
              teacherName: _resolvedTeacherName ?? widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
            ),
          ),
        )
        .then((_) => _fetchSummary());
  }

  void _openIjinMenu() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => IjinKehadiranScreen(
              teacherName: _resolvedTeacherName ?? widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
            ),
          ),
        )
        .then((_) => _fetchSummary());
  }

  void _openGuruWaliMenu() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => GuruWaliScreen(
              teacherName: _resolvedTeacherName ?? widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
            ),
          ),
        )
        .then((_) => _fetchSummary());
  }

  void _openDataSiswaMenu() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => DataSiswaScreen(
              teacherName: _resolvedTeacherName ?? widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
            ),
          ),
        )
        .then((_) => _fetchSummary());
  }

  void _openSpikapMenu() {
    if (!_canAccessSpikap) {
      DialogAksesSpikapDitolak.show(
        context,
        currentRoleLabel: _spikapRoleLabel,
      );
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SpikapScreen(
              teacherName: _resolvedTeacherName ?? widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
            ),
          ),
        )
        .then((_) => _fetchSummary());
  }

  void _openPerpustakaanMenu() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PerpustakaanScreen(
              teacherName: _resolvedTeacherName ?? widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
            ),
          ),
        )
        .then((_) => _fetchSummary());
  }

  void _openProfilMenu({int initialTab = 0}) {
    Navigator.of(context)
        .push<GuruProfilData?>(
          MaterialPageRoute(
            builder: (_) => ProfilGuruScreen(
              teacherName: _resolvedTeacherName ?? widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
              initialTab: initialTab,
            ),
          ),
        )
        .then((updated) {
          if (updated != null && mounted) {
            setState(() {
              _resolvedTeacherName = updated.displayName;
            });
          }
          _fetchSummary();
        });
  }

  Widget _buildTeacherAvatar(String name) {
    if (_teacherPhotoUrl != null && _teacherPhotoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _teacherPhotoUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _buildAvatarInitial(name),
      );
    }
    return _buildAvatarInitial(name);
  }

  Widget _buildAvatarInitial(String name) {
    final clean = name.trim();
    final initial = clean.isNotEmpty ? clean[0].toUpperCase() : 'G';
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

  Widget _buildResponsiveMenuGrid(BuildContext context, List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mode Smartphone Portrait: 1 Kolom
        if (constraints.maxWidth < 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cards,
          );
        }

        // Mode Tablet / Layar Lebar: Grid 3 Kolom per Baris
        const int crossAxisCount = 3;
        final List<Widget> rows = [];
        for (int i = 0; i < cards.length; i += crossAxisCount) {
          final List<Widget> rowItems = [];
          for (int j = 0; j < crossAxisCount; j++) {
            if (i + j < cards.length) {
              rowItems.add(
                Expanded(
                  child: cards[i + j],
                ),
              );
            } else {
              // Placeholder kosong agar kartu tidak meregang sendirian
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
    final displayName = _resolvedTeacherName ?? widget.teacherName;

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
                    'Portal Guru',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.schoolName,
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
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: _fetchSummary,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profil Saya',
            onPressed: () => _openProfilMenu(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar Portal',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: const Text(
                    'Keluar dari Portal?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  content: const Text(
                    'Apakah Anda yakin ingin keluar dari akun Portal Guru?',
                    style: TextStyle(fontSize: 13),
                  ),
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =========================================================
              // 1. HERO WELCOME CARD (Mengacu pada /portal-guru)
              // =========================================================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4F46E5),
                      AppColors.primary,
                      Color(0xFF3730A3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PORTAL GURU',
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
                            'Selamat Datang, $displayName!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Kelola absensi kelas binaan, tanggapi permohonan ijin siswa, pendampingan SI-WALI, dan akses layanan akademik dari satu tempat.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Foto Avatar Guru di Kanan
                    GestureDetector(
                      onTap: () => _openProfilMenu(),
                      child: Tooltip(
                        message: 'Buka Profil Saya',
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _buildTeacherAvatar(displayName),
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
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
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

              // IN-APP NOTIFICATION BANNER (Jika ada permohonan pending baru)
              if (_pendingLeaveCount > 0) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDA4AF)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Permohonan Izin Menunggu',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF9F1239),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ada $_pendingLeaveCount permohonan siswa yang membutuhkan persetujuan Anda.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF881337),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _openIjinMenu,
                        child: const Text(
                          'Tinjau',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // IN-APP NOTIFICATION BANNER (Jika ada konsultasi/cerita siswa baru)
              if (_pendingKonsultasiCount > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.forum_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ruang Aman Cerita: Pesan Baru',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ada $_pendingKonsultasiCount murid binaan mengirim pesan atau permohonan konsultasi.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _openGuruWaliMenu,
                        child: const Text(
                          'Buka',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // =========================================================
              // 2. HEADER PINTASAN 9 MENU KOTAK-KOTAK (TANPA SIDEBAR KIRI)
              // =========================================================
              const Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Pintasan Menu Utama Guru',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                'Akses cepat ke modul operasional harian guru dan wali kelas:',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 14),

              // =========================================================
              // 3. DAFTAR 9 KOTAK MENU PORTAL GURU (RESPONSIF: 3 KOLOM DI TABLET)
              // =========================================================
              _buildResponsiveMenuGrid(
                context,
                [
                  // MENU 1: Presensi (Aktif Penuh - Tahap 1)
                  _PortalMenuBoxCard(
                    number: 1,
                    title: 'Presensi',
                    description:
                        'Pantau absensi harian siswa, matriks bulanan, input manual, kirim WA ortu, dan cetak laporan presensi kelas.',
                    badgeText: '$_kelasAmpuCount Kelas',
                    icon: Icons.verified_user_outlined,
                    accentColor: const Color(0xFF059669),
                    primaryActionLabel: 'Buka Presensi Kelas',
                    isReady: true,
                    onTap: _openPresensiMenu,
                  ),

                  // MENU 2: Presensi Sholat Dhuhur
                  if (_enableSholatDhuhur)
                    _PortalMenuBoxCard(
                      number: 2,
                      title: 'Presensi Sholat Dhuhur',
                      description:
                          'Pencatatan kehadiran sholat dhuhur berjamaah, sinkron izin/alpa presensi pagi, serta rekapitulasi kepatuhan ibadah.',
                      badgeText: 'Ibadah Berjamaah',
                      icon: Icons.mosque_outlined,
                      accentColor: const Color(0xFF0D9488),
                      primaryActionLabel: 'Buka Presensi Sholat',
                      isReady: true,
                      onTap: _openSholatDhuhurMenu,
                    ),

                  // MENU 3: Jurnal Mengajar
                  _PortalMenuBoxCard(
                    number: 3,
                    title: 'Jurnal Mengajar',
                    description:
                        'Dokumentasi materi pembelajaran harian, pencatatan kehadiran siswa per jam pelajaran, dan unduh rekap PDF.',
                    badgeText: _jurnalHariIniCount > 0
                        ? '$_jurnalHariIniCount Terisi Hari Ini'
                        : '$_totalJurnalCount Total Jurnal',
                    icon: Icons.menu_book_rounded,
                    accentColor: const Color(0xFF4F46E5),
                    primaryActionLabel: 'Buka Jurnal Mengajar',
                    isReady: true,
                    onTap: _openJurnalMengajarMenu,
                  ),

                  // MENU 4: Persetujuan Ijin
                  _PortalMenuBoxCard(
                    number: 4,
                    title: 'Persetujuan Ijin',
                    description:
                        'Tinjau dan proses permohonan ijin atau sakit siswa (Diterima: $_approvedLeaveCount • Ditolak: $_rejectedLeaveCount • Menunggu: $_pendingLeaveCount).',
                    badgeText: _pendingLeaveCount > 0
                        ? '$_pendingLeaveCount Pending'
                        : 'Bersih',
                    icon: Icons.assignment_turned_in_outlined,
                    accentColor: const Color(0xFFE11D48),
                    primaryActionLabel: 'Buka Persetujuan',
                    isReady: true,
                    onTap: _openIjinMenu,
                  ),

                  // MENU 5: Guru Wali (SI-WALI)
                  _PortalMenuBoxCard(
                    number: 5,
                    title: 'Guru Wali (SI-WALI)',
                    description:
                        'Kelola kelompok dampingan Permen 11/2025, tulis jurnal bimbingan, ruang aman bercerita, dan pantau rekam jejak murid.',
                    badgeText: _pendingKonsultasiCount > 0
                        ? '$_pendingKonsultasiCount Menunggu Cerita'
                        : 'Permen 11/2025',
                    icon: Icons.favorite_border_rounded,
                    accentColor: const Color(0xFF2563EB),
                    primaryActionLabel: 'Buka SI-WALI',
                    isReady: true,
                    onTap: _openGuruWaliMenu,
                  ),

                  // MENU 6: Data Siswa
                  _PortalMenuBoxCard(
                    number: 6,
                    title: 'Data Siswa',
                    description:
                        'Kelola data siswa binaan Anda, lihat informasi kontak orang tua, dan pratinjau kartu pelajar QR/Barcode.',
                    badgeText: 'QR & Barcode',
                    icon: Icons.badge_outlined,
                    accentColor: const Color(0xFF7C3AED),
                    primaryActionLabel: 'Buka Data Siswa',
                    isReady: true,
                    onTap: _openDataSiswaMenu,
                  ),

                  // MENU 7: SPIKAP
                  _PortalMenuBoxCard(
                    number: 7,
                    title: 'SPIKAP (Anti-Perundungan)',
                    description:
                        'Layanan penanganan perundungan siswa, pantau aduan masuk, dan investigasi tindak lanjut.',
                    badgeText: !_canAccessSpikap
                        ? 'Akses Khusus (BK/Wali/KS)'
                        : (_spikapDaruratCount > 0
                            ? '$_spikapDaruratCount Darurat 🚨'
                            : '$_spikapCount Laporan'),
                    icon: Icons.shield_outlined,
                    accentColor: !_canAccessSpikap
                        ? const Color(0xFF64748B)
                        : const Color(0xFFDC2626),
                    primaryActionLabel: !_canAccessSpikap
                        ? 'Lihat Ketentuan Akses'
                        : 'Buka SPIKAP',
                    isReady: true,
                    onTap: _openSpikapMenu,
                  ),

                  // MENU 8: Perpustakaan
                  _PortalMenuBoxCard(
                    number: 8,
                    title: 'Perpustakaan',
                    description:
                        'Cari koleksi katalog perpustakaan sekolah, pantau pinjaman buku aktif, riwayat kunjungan, dan peminjaman siswa kelas binaan.',
                    badgeText: _activeBooksCount > 0
                        ? '$_activeBooksCount Dipinjam'
                        : 'Katalog & Koleksi',
                    icon: Icons.local_library_outlined,
                    accentColor: const Color(0xFFD97706),
                    primaryActionLabel: 'Buka Perpustakaan',
                    isReady: true,
                    onTap: _openPerpustakaanMenu,
                  ),

                  // MENU 9: Profil Saya
                  _PortalMenuBoxCard(
                    number: 9,
                    title: 'Profil Saya',
                    description:
                        'Lihat informasi NIP, penugasan akademik, perbarui foto, email, tautan microsite, dan ganti kata sandi akun.',
                    badgeText: 'Biodata & Akun',
                    icon: Icons.person_outline_rounded,
                    accentColor: const Color(0xFF0284C7),
                    primaryActionLabel: 'Lihat Profil',
                    isReady: true,
                    onTap: _openProfilMenu,
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget Kotak Menu Portal Guru (Mengikuti desain Card di /portal-guru)
class _PortalMenuBoxCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String badgeText;
  final IconData icon;
  final Color accentColor;
  final String primaryActionLabel;
  final bool isReady;
  final VoidCallback onTap;

  const _PortalMenuBoxCard({
    required this.number,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.icon,
    required this.accentColor,
    required this.primaryActionLabel,
    this.isReady = false,
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
          color: isReady
              ? accentColor.withValues(alpha: 0.45)
              : AppColors.border,
          width: isReady ? 1.5 : 1.0,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
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
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: isReady ? accentColor : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: isReady
                      ? null
                      : Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      primaryActionLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isReady
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: isReady ? Colors.white : const Color(0xFF334155),
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
