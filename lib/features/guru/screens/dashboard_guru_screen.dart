import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/widgets/school_logo_widget.dart';
import '../../auth/screens/login_screen.dart';
import '../../notification/screens/notification_inbox_screen.dart';
import '../models/guru_profil_model.dart';
import 'data_siswa_screen.dart';
import 'guru_wali_screen.dart';
import 'ijin_kehadiran_screen.dart';
import 'jurnal_mengajar_screen.dart';
import 'perpustakaan_screen.dart';
import 'presensi_kelas_screen.dart';
import 'presensi_sholat_dhuhur_screen.dart';
import 'profil_guru_screen.dart';
import 'spikap_screen.dart';
import 'widgets/dashboard/grid/dashboard_guru_menu_grid.dart';
import 'widgets/dashboard/sections/dashboard_guru_hero_banner.dart';
import 'widgets/dashboard/sections/dashboard_guru_notification_banners.dart';
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
    this.schoolName = '',
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
                    widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName,
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Welcome Card Guru
              DashboardGuruHeroBanner(
                displayName: displayName,
                teacherPhotoUrl: _teacherPhotoUrl,
                onTapProfile: () => _openProfilMenu(),
              ),

              // 2. In-App Notification Banners (Pending Leave & Konsultasi)
              DashboardGuruNotificationBanners(
                pendingLeaveCount: _pendingLeaveCount,
                pendingKonsultasiCount: _pendingKonsultasiCount,
                onTapLeave: _openIjinMenu,
                onTapKonsultasi: _openGuruWaliMenu,
              ),

              const SizedBox(height: 20),

              // 3. Header Pintasan 9 Menu Utama
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

              // 4. Grid 9 Menu Portal Guru (1 Kolom HP / 3 Kolom Tablet)
              DashboardGuruMenuGrid(
                kelasAmpuCount: _kelasAmpuCount,
                enableSholatDhuhur: _enableSholatDhuhur,
                jurnalHariIniCount: _jurnalHariIniCount,
                totalJurnalCount: _totalJurnalCount,
                pendingLeaveCount: _pendingLeaveCount,
                approvedLeaveCount: _approvedLeaveCount,
                rejectedLeaveCount: _rejectedLeaveCount,
                pendingKonsultasiCount: _pendingKonsultasiCount,
                activeBooksCount: _activeBooksCount,
                spikapCount: _spikapCount,
                spikapDaruratCount: _spikapDaruratCount,
                canAccessSpikap: _canAccessSpikap,
                onTapPresensi: _openPresensiMenu,
                onTapSholat: _openSholatDhuhurMenu,
                onTapJurnal: _openJurnalMengajarMenu,
                onTapIjin: _openIjinMenu,
                onTapGuruWali: _openGuruWaliMenu,
                onTapDataSiswa: _openDataSiswaMenu,
                onTapSpikap: _openSpikapMenu,
                onTapPerpustakaan: _openPerpustakaanMenu,
                onTapProfil: () => _openProfilMenu(),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
