import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/widgets/school_logo_widget.dart';
import '../../auth/screens/login_screen.dart';

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

  const DashboardSiswaScreen({
    super.key,
    required this.studentName,
    required this.identifier,
    this.schoolName = 'SMP Negeri 3 Kedungreja',
    this.token,
    this.schoolLogoUrl,
    this.schoolLogoBase64,
  });

  @override
  State<DashboardSiswaScreen> createState() => _DashboardSiswaScreenState();
}

class _DashboardSiswaScreenState extends State<DashboardSiswaScreen> {
  String? _schoolLogoUrl;
  String? _schoolLogoBase64;
  String? _studentPhotoUrl;
  String _className = 'Kelas 8A';

  @override
  void initState() {
    super.initState();
    _schoolLogoUrl = widget.schoolLogoUrl;
    _schoolLogoBase64 = widget.schoolLogoBase64;
    _loadStoredSession();
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

  void _showStepNotice(String menuTitle, int stepNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Menu $stepNumber: $menuTitle sedang disiapkan untuk tahap berikutnya.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showBarcodeFullscreen() {
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
                widget.schoolName,
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
                      data: widget.identifier.trim().isNotEmpty
                          ? widget.identifier.trim()
                          : '1234567890',
                      width: 260,
                      height: 90,
                      drawText: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.studentName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'NISN: ${widget.identifier} • $_className',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup Barcode'),
                ),
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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                          'Hai, ${widget.studentName}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NISN: ${widget.identifier} • $_className',
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
                    onTap: () => _showStepNotice('Profil Saya', 7),
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
                              child: _buildStudentAvatar(widget.studentName),
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
                        const Row(
                          children: [
                            Text(
                              'Kartu Pelajar Barcode',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.verified_rounded, size: 14, color: Color(0xFF0284C7)),
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
            Container(
              padding: const EdgeInsets.all(16),
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
                  // Status Pagi
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFF059669),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Presensi Masuk',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              Text(
                                'Tepat Waktu',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF059669),
                                ),
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
                            color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.mosque_outlined,
                            color: Color(0xFF0D9488),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sholat Dhuhur',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              Text(
                                'Berjamaah',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0D9488),
                                ),
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
                Text(
                  'Pintasan Menu Portal Siswa',
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
                  onTap: () => _showStepNotice('Presensi & Akademik', 1),
                ),

                // MENU 2: Pengajuan Ijin Kehadiran
                _SiswaMenuBoxCard(
                  number: 2,
                  title: 'Pengajuan Ijin Kehadiran',
                  description:
                      'Kirim permohonan ijin atau sakit secara online dilengkapi foto surat dokter (kompresi otomatis hemat kuota).',
                  badgeText: 'Ijin / Sakit Online',
                  icon: Icons.assignment_outlined,
                  accentColor: const Color(0xFFE11D48),
                  primaryActionLabel: 'Ajukan Ijin',
                  onTap: () => _showStepNotice('Pengajuan Ijin Kehadiran', 2),
                ),

                // MENU 3: SI-WALI
                _SiswaMenuBoxCard(
                  number: 3,
                  title: 'Guru Wali (SI-WALI)',
                  description:
                      'Ruang aman bercerita dan konsultasi dengan Guru Wali asuh Anda, serta info bimbingan klasikal kelas.',
                  badgeText: 'Ruang Cerita & Bimbingan',
                  icon: Icons.favorite_border_rounded,
                  accentColor: const Color(0xFF2563EB),
                  primaryActionLabel: 'Buka SI-WALI',
                  onTap: () => _showStepNotice('Guru Wali (SI-WALI)', 3),
                ),

                // MENU 4: SPIKAP
                _SiswaMenuBoxCard(
                  number: 4,
                  title: 'SPIKAP (Karakter & Lapor)',
                  description:
                      'Layanan pengaduan anti-perundungan aman (opsi anonim) dan transparansi buku saku catatan karakter.',
                  badgeText: 'Anti-Perundungan',
                  icon: Icons.shield_outlined,
                  accentColor: const Color(0xFFDC2626),
                  primaryActionLabel: 'Buka SPIKAP',
                  onTap: () => _showStepNotice('SPIKAP', 4),
                ),

                // MENU 5: Perpustakaan
                _SiswaMenuBoxCard(
                  number: 5,
                  title: 'Perpustakaan Siswa',
                  description:
                      'Cek status buku yang sedang Anda pinjam, riwayat pengembalian, dan histori kunjungan perpustakaan.',
                  badgeText: 'Pinjaman & Literasi',
                  icon: Icons.local_library_outlined,
                  accentColor: const Color(0xFFD97706),
                  primaryActionLabel: 'Buka Perpustakaan',
                  onTap: () => _showStepNotice('Perpustakaan', 5),
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
                  onTap: () => _showStepNotice('Kartu Pelajar & PDF', 6),
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
                  onTap: () => _showStepNotice('Profil Saya', 7),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withValues(alpha: 0.2)),
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
