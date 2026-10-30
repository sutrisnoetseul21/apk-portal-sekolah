import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../models/guru_profil_model.dart';
import '../services/guru_profil_service.dart';

/// Layar Menu 9: Profil Saya & Akun Pendidik (/portal-guru/profil)
class ProfilGuruScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;
  final int initialTab;

  const ProfilGuruScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    required this.schoolName,
    this.initialTab = 0,
  });

  @override
  State<ProfilGuruScreen> createState() => _ProfilGuruScreenState();
}

class _ProfilGuruScreenState extends State<ProfilGuruScreen> {
  late final GuruProfilService _service;

  // State Profil
  GuruProfilData? _profilData;
  bool _isLoading = true;
  String? _errorMessage;

  // Tab State: 0 (Kontak & Bio), 1 (Akademik), 2 (Keamanan)
  late int _selectedTabIndex;

  // Form Kontak Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _micrositeController = TextEditingController();
  bool _isSavingContact = false;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab.clamp(0, 2);
    _service = GuruProfilService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    _fetchProfile();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _noHpController.dispose();
    _micrositeController.dispose();
    super.dispose();
  }

  /// Memuat data profil guru dari server
  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getProfile();
      if (mounted) {
        setState(() {
          _profilData = data;
          _isLoading = false;
          _emailController.text = data.user.email;
          _noHpController.text = data.teacher.noHp.isNotEmpty
              ? data.teacher.noHp
              : data.user.noHp;
          _micrositeController.text = data.teacher.micrositeUrl ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  /// Menyimpan pembaruan kontak & microsite
  Future<void> _handleSaveContact() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isSavingContact = true;
    });

    try {
      final email = _emailController.text.trim();
      final noHp = _noHpController.text.trim();
      final microsite = _micrositeController.text.trim();

      await _service.updateContact(
        email: email,
        noHp: noHp,
        micrositeUrl: microsite.isNotEmpty ? microsite : null,
      );

      if (mounted) {
        setState(() {
          _isSavingContact = false;
          if (_profilData != null) {
            _profilData = _profilData!.copyWith(
              user: _profilData!.user.copyWith(email: email, noHp: noHp),
              teacher: _profilData!.teacher.copyWith(
                noHp: noHp,
                micrositeUrl: microsite.isNotEmpty ? microsite : null,
              ),
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Informasi kontak dan microsite berhasil diperbarui!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSavingContact = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.toString().replaceFirst('Exception: ', ''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  /// Membuka tautan eksternal (microsite guru) di browser
  Future<void> _openMicrosite(String urlStr) async {
    final cleanUrl = urlStr.trim();
    if (cleanUrl.isEmpty) return;

    final uri = Uri.tryParse(
      cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')
          ? cleanUrl
          : 'https://$cleanUrl',
    );

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan microsite tidak valid.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka tautan: $cleanUrl'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Hook untuk pengelolaan foto profil (akan dilengkapi penuh di Tahap 4)
  void _onTapAvatar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur unggah dan hapus foto profil akan aktif di Tahap 4.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali ke Beranda',
          onPressed: () => Navigator.pop(context, _profilData),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil & Akun Pendidik',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              widget.schoolName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Profil',
            onPressed: _fetchProfile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        color: AppColors.primary,
        child: _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading && _profilData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Memuat data profil pendidik...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _profilData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_rounded,
                  color: Color(0xFFDC2626),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Profil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF991B1B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF7F1D1D),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                onPressed: _fetchProfile,
              ),
            ],
          ),
        ),
      );
    }

    final data = _profilData!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. HERO PROFILE CARD
          _buildHeroProfileCard(data),

          const SizedBox(height: 16),

          // 2. SEGMENTED TABS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSegmentedTabs(),
          ),

          const SizedBox(height: 16),

          // 3. TAB VIEW CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildActiveTabContent(data),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. HERO PROFILE CARD (BANNER + AVATAR + IDENTITAS GURU)
  // =========================================================================

  Widget _buildHeroProfileCard(GuruProfilData data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Banner Gradasi Atas
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A8A), // Dark Indigo
                  Color(0xFF2563EB), // Royal Blue
                  Color(0xFF0284C7), // Sky Blue
                ],
              ),
            ),
            child: Stack(
              children: [
                // Ornamen Lingkaran
                Positioned(
                  right: -20,
                  top: -30,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'PORTAL GURU • AKUN RESMI',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Badge Peran Kanan Atas
                Positioned(
                  right: 14,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: data.akademik.isWaliKelas
                          ? const Color(0xFF059669)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      data.roleBadgeLabel,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Area Avatar & Detail Pendidik
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(
              children: [
                // Avatar Offset ke Banner
                Transform.translate(
                  offset: const Offset(0, -42),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _onTapAvatar,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 3.5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: data.teacher.hasPhoto
                              ? CachedNetworkImage(
                                  imageUrl: data.teacher.photoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: const Color(0xFFE2E8F0),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      _buildInitialAvatar(data),
                                )
                              : _buildInitialAvatar(data),
                        ),
                      ),
                      // Tombol Kamera Mini
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: GestureDetector(
                          onTap: _onTapAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Nama & Status
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Column(
                    children: [
                      Text(
                        data.displayName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Badge Tenaga Pendidik Aktif
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tenaga Pendidik Aktif',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF065F46),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Baris Chips Info Singkat
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMiniChip(
                            icon: Icons.badge_outlined,
                            label: 'NIP: ${data.teacher.nip}',
                            color: const Color(0xFF475569),
                            bgColor: const Color(0xFFF1F5F9),
                          ),
                          if (data.teacher.noHp.isNotEmpty)
                            _buildMiniChip(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: 'WA: ${data.teacher.noHp}',
                              color: const Color(0xFF047857),
                              bgColor: const Color(0xFFECFDF5),
                            ),
                          _buildMiniChip(
                            icon: Icons.alternate_email_rounded,
                            label: data.user.email,
                            color: const Color(0xFF1D4ED8),
                            bgColor: const Color(0xFFEFF6FF),
                          ),
                          if (data.teacher.hasMicrosite)
                            InkWell(
                              onTap: () =>
                                  _openMicrosite(data.teacher.micrositeUrl!),
                              borderRadius: BorderRadius.circular(10),
                              child: _buildMiniChip(
                                icon: Icons.link_rounded,
                                label: 'Microsite Guru ↗',
                                color: const Color(0xFF6D28D9),
                                bgColor: const Color(0xFFF5F3FF),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(GuruProfilData data) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
        ),
      ),
      child: Center(
        child: Text(
          data.initial,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. SEGMENTED TABS (KONTAK & BIO, AKADEMIK, KEAMANAN)
  // =========================================================================

  Widget _buildSegmentedTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTabPill(
            index: 0,
            title: 'Kontak & Bio',
            icon: Icons.person_outline_rounded,
          ),
          _buildTabPill(
            index: 1,
            title: 'Akademik',
            icon: Icons.school_outlined,
          ),
          _buildTabPill(
            index: 2,
            title: 'Keamanan',
            icon: Icons.lock_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 3. ACTIVE TAB CONTENT SELECTOR
  // =========================================================================

  Widget _buildActiveTabContent(GuruProfilData data) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildTabKontakDanBio(data);
      case 1:
        return _buildTabAkademik(data);
      case 2:
        return _buildTabKeamanan(data);
      default:
        return _buildTabKontakDanBio(data);
    }
  }

  // =========================================================================
  // TAB 1: FORM KONTAK, BIODATA RESMI & MICROSITE
  // =========================================================================

  Widget _buildTabKontakDanBio(GuruProfilData data) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 1: Data Resmi Sekolah (Read-Only)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Identitas Resmi Pendidik',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'READ ONLY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Field Nama Lengkap
                _buildReadOnlyField(
                  label: 'Nama Lengkap',
                  value: data.displayName,
                  icon: Icons.person_rounded,
                  helperText: 'Nama resmi terdaftar di database kurikulum.',
                ),
                const SizedBox(height: 12),

                // Field NIP
                _buildReadOnlyField(
                  label: 'NIP (Nomor Induk Pegawai)',
                  value: data.teacher.nip,
                  icon: Icons.badge_rounded,
                  helperText: 'NIP resmi sebagai aparatur/tenaga pendidik.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Card 2: Form Kontak & Microsite (Editable)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.contact_mail_outlined,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kontak & Tautan Komunikasi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Perbarui alamat email login dan nomor WhatsApp Anda:',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Email Login
                Text(
                  'Alamat Email Login *',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                    hintText: 'nama@sekolah.sch.id',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Alamat email wajib diisi.';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Format email tidak valid.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Input WhatsApp
                Text(
                  'Nomor WhatsApp / HP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noHpController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    hintText: '081234567890',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  validator: (v) {
                    if (v != null && v.trim().length > 20) {
                      return 'Nomor HP maksimal 20 digit.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  'Digunakan untuk notifikasi sistem presensi & komunikasi siswa.',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                ),

                const SizedBox(height: 18),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 16),

                // Input Microsite Guru
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tautan Microsite Guru',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (_micrositeController.text.trim().isNotEmpty)
                      InkWell(
                        onTap: () =>
                            _openMicrosite(_micrositeController.text),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Buka Tautan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.open_in_new_rounded,
                                size: 12,
                                color: Color(0xFF7C3AED),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _micrositeController,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.link_rounded,
                      size: 18,
                      color: Color(0xFF7C3AED),
                    ),
                    hintText:
                        'https://sites.google.com/view/nama-guru atau Canva',
                    filled: true,
                    fillColor: const Color(0xFFFAF5FF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                    ),
                  ),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final val = v.trim();
                      if (!val.startsWith('http://') &&
                          !val.startsWith('https://')) {
                        return 'Tautan harus diawali dengan http:// atau https://';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tautan ditampilkan di Akademik > Microsite Sekolah agar siswa dapat mengakses bahan ajar Anda.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF94A3B8),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 22),

                // Tombol Simpan Kontak
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSavingContact ? null : _handleSaveContact,
                  child: _isSavingContact
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Simpan Perubahan Kontak & Microsite',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
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
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required String helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: const Color(0xFF64748B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : '-',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const Icon(
                Icons.lock_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          helperText,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 2: PENUGASAN AKADEMIK (DISELESAIKAN PENUH DI TAHAP 5)
  // =========================================================================

  Widget _buildTabAkademik(GuruProfilData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                color: Color(0xFF2563EB),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Penugasan Akademik',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              if (data.akademik.tahunAjaran != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    data.akademik.tahunAjaran!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data penugasan wali kelas, mata pelajaran, dan jabatan dikelola terpusat oleh Administrator Kurikulum.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF92400E),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Teaser Daftar Mapel
          Text(
            'Mata Pelajaran yang Diampu:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          if (data.akademik.mapelDiampu.isEmpty)
            const Text(
              'Belum ada mata pelajaran terdaftar pada tahun ajaran ini.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
            )
          else
            ...data.akademik.mapelDiampu.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      m,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 3: KEAMANAN KATA SANDI (DISELESAIKAN PENUH DI TAHAP 5)
  // =========================================================================

  Widget _buildTabKeamanan(GuruProfilData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Keamanan & Kata Sandi Akun',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Formulir ganti password akun dan pengelolaan sesi keamanan login akan aktif sepenuhnya pada Tahap 5.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
