import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/utils/image_compress_util.dart';
import '../../auth/screens/login_screen.dart';
import '../models/guru_profil_model.dart';
import '../services/guru_profil_service.dart';
import 'widgets/profil/sections/profil_hero_avatar_section.dart';
import 'widgets/profil/sections/profil_tab_selector.dart';
import 'widgets/profil/sheets/sheet_ganti_foto_profil.dart';
import 'widgets/profil/tabs/tab_profil_akademik.dart';
import 'widgets/profil/tabs/tab_profil_keamanan.dart';
import 'widgets/profil/tabs/tab_profil_kontak_biodata.dart';

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
  bool _isUploadingPhoto = false;

  // Form Keamanan Sandi Controllers
  final _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmController =
      TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isUpdatingPassword = false;

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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _newPasswordConfirmController.dispose();
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

      final updatedData = await _service.updateContact(
        email: email,
        noHp: noHp,
        micrositeUrl: microsite.isNotEmpty ? microsite : null,
      );

      if (mounted) {
        setState(() {
          _profilData = updatedData;
          _isSavingContact = false;
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
                    'Kontak profil berhasil diperbarui!',
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

  /// Membuka tautan microsite guru di peramban
  Future<void> _openMicrosite(String urlStr) async {
    final uri = Uri.tryParse(urlStr);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format tautan microsite tidak valid.')),
      );
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan microsite.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka peramban: $e')),
        );
      }
    }
  }

  void _onTapAvatar() {
    if (_isUploadingPhoto) return;
    if (_profilData == null) return;
    SheetGantiFotoProfil.show(
      context,
      data: _profilData!,
      onPickPhoto: _pickAndUploadPhoto,
      onRemovePhoto: _confirmRemovePhoto,
    );
  }

  /// Memilih dan mengunggah foto profil baru
  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final compressed = await ImageCompressUtil.pickAndCompressImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (compressed == null) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final result = await _service.uploadPhoto(compressed.file.path);

      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          if (_profilData != null) {
            _profilData = _profilData!.copyWith(
              teacher: _profilData!.teacher.copyWith(
                photoPath: result['photo_path'],
                photoUrl: result['photo_url'],
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
                    'Foto profil berhasil diperbarui!',
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
          _isUploadingPhoto = false;
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

  /// Menampilkan dialog konfirmasi hapus foto profil
  Future<void> _confirmRemovePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Hapus Foto Profil?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus foto profil dan kembali menggunakan avatar inisial nama?',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      await _service.removePhoto();

      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          if (_profilData != null) {
            _profilData = _profilData!.copyWith(
              teacher: _profilData!.teacher.copyWith(clearPhoto: true),
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
                    'Foto profil berhasil dihapus!',
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
          _isUploadingPhoto = false;
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

  /// Memperbarui kata sandi akun pendidik
  Future<void> _handleUpdatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      final currentPass = _currentPasswordController.text;
      final newPass = _newPasswordController.text;
      final confirmPass = _newPasswordConfirmController.text;

      await _service.updatePassword(
        currentPassword: currentPass,
        newPassword: newPass,
        newPasswordConfirmation: confirmPass,
      );

      if (mounted) {
        setState(() {
          _isUpdatingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _newPasswordConfirmController.clear();
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
                Icon(Icons.lock_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kata sandi berhasil diperbarui!',
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
          _isUpdatingPassword = false;
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

  /// Menampilkan dialog konfirmasi dan melakukan logout akun
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Keluar dari Akun?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: const Text(
          'Anda akan keluar dari sesi akun portal guru ini. Untuk mengakses fitur kembali, Anda perlu memasukkan email dan sandi.',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Ya, Keluar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FcmService.instance.unregisterToken();
      await SessionStorage.clearSession();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan saat logout: $e')),
        );
      }
    }
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
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
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
          ProfilHeroAvatarSection(
            data: data,
            isUploadingPhoto: _isUploadingPhoto,
            onTapAvatar: _onTapAvatar,
            onOpenMicrosite: _openMicrosite,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProfilTabSelector(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (idx) => setState(() => _selectedTabIndex = idx),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildActiveTabContent(data),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(GuruProfilData data) {
    switch (_selectedTabIndex) {
      case 0:
        return TabProfilKontakBiodata(
          data: data,
          formKey: _formKey,
          emailController: _emailController,
          noHpController: _noHpController,
          micrositeController: _micrositeController,
          isSavingContact: _isSavingContact,
          onSaveContact: _handleSaveContact,
          onOpenMicrosite: _openMicrosite,
        );
      case 1:
        return TabProfilAkademik(data: data);
      case 2:
        return TabProfilKeamanan(
          passwordFormKey: _passwordFormKey,
          currentPasswordController: _currentPasswordController,
          newPasswordController: _newPasswordController,
          newPasswordConfirmController: _newPasswordConfirmController,
          obscureCurrentPassword: _obscureCurrentPassword,
          obscureNewPassword: _obscureNewPassword,
          obscureConfirmPassword: _obscureConfirmPassword,
          onToggleObscureCurrent: () => setState(
            () => _obscureCurrentPassword = !_obscureCurrentPassword,
          ),
          onToggleObscureNew: () => setState(
            () => _obscureNewPassword = !_obscureNewPassword,
          ),
          onToggleObscureConfirm: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
          isUpdatingPassword: _isUpdatingPassword,
          onUpdatePassword: _handleUpdatePassword,
          schoolName: widget.schoolName,
          onLogout: _handleLogout,
        );
      default:
        return TabProfilKontakBiodata(
          data: data,
          formKey: _formKey,
          emailController: _emailController,
          noHpController: _noHpController,
          micrositeController: _micrositeController,
          isSavingContact: _isSavingContact,
          onSaveContact: _handleSaveContact,
          onOpenMicrosite: _openMicrosite,
        );
    }
  }
}
