import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/storage/session_storage.dart';
import '../../../core/utils/image_compress_util.dart';
import '../../auth/screens/login_screen.dart';
import '../models/siswa_profil_model.dart';
import '../services/siswa_profil_service.dart';
import 'widgets/profil/sections/profil_siswa_hero_header.dart';
import 'widgets/profil/sections/profil_siswa_error_state.dart';
import 'widgets/profil/sheets/sheet_ganti_foto_profil_siswa.dart';
import 'widgets/profil/dialogs/dialog_konfirmasi_hapus_foto_siswa.dart';
import 'widgets/profil/dialogs/dialog_konfirmasi_logout_siswa.dart';
import 'widgets/profil/tabs/tab_profil_siswa_biodata.dart';
import 'widgets/profil/tabs/tab_profil_siswa_keamanan.dart';

/// Layar Menu 7: Profil Saya & Akun Pelajar
class ProfilSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;
  final SiswaProfilService? service;

  const ProfilSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = '',
    this.token,
    this.service,
  });

  @override
  State<ProfilSiswaScreen> createState() => _ProfilSiswaScreenState();
}

class _ProfilSiswaScreenState extends State<ProfilSiswaScreen>
    with SingleTickerProviderStateMixin {
  late SiswaProfilService _service;
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;
  SiswaProfilDetail? _profil;

  // Form Kontak
  final _formKontakKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _noHpController;
  late TextEditingController _noHpOrangTuaController;
  bool _isSavingKontak = false;

  // Form Ganti Password
  final _formPasswordKey = GlobalKey<FormState>();
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isSavingPassword = false;

  // Foto Profil State
  bool _isUploadingFoto = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _service = widget.service ??
        SiswaProfilService.create(
          token: widget.token,
          identifier: widget.identifier,
        );

    _addressController = TextEditingController();
    _noHpController = TextEditingController();
    _noHpOrangTuaController = TextEditingController();

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _loadProfil();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressController.dispose();
    _noHpController.dispose();
    _noHpOrangTuaController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfil() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _service.getProfilInfo(identifier: widget.identifier);
      if (mounted) {
        setState(() {
          _profil = res.data;
          _isLoading = false;

          if (_profil != null) {
            _addressController.text = _profil!.address;
            _noHpController.text = _profil!.noHp;
            _noHpOrangTuaController.text =
                _profil!.noHpOrangTua != '-' ? _profil!.noHpOrangTua : '';
          }
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

  Future<void> _saveKontak() async {
    if (!_formKontakKey.currentState!.validate()) return;

    setState(() => _isSavingKontak = true);

    try {
      final res = await _service.updateKontak(
        identifier: widget.identifier,
        address: _addressController.text.trim(),
        noHp: _noHpController.text.trim(),
      );

      await _loadProfil();

      if (mounted) {
        setState(() {
          _isSavingKontak = false;
        });

        final msg = res['message']?.toString() ?? 'Alamat & nomor HP berhasil diperbarui!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    msg,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingKontak = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e.toString().replaceFirst('Exception: ', ''),
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final compressed = await ImageCompressUtil.pickAndCompressImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (compressed == null) return;

      setState(() => _isUploadingFoto = true);

      await _service.updateFoto(
        photoFile: File(compressed.file.path),
        identifier: widget.identifier,
      );

      await _loadProfil();

      if (mounted) {
        setState(() {
          _isUploadingFoto = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Foto profil berhasil diunggah!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingFoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
            ),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    final confirmed = await DialogKonfirmasiHapusFotoSiswa.show(context);
    if (confirmed != true) return;

    setState(() => _isUploadingFoto = true);

    try {
      await _service.hapusFoto(identifier: widget.identifier);

      await _loadProfil();

      if (mounted) {
        setState(() {
          _isUploadingFoto = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Foto profil berhasil dihapus.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingFoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
            ),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    SheetGantiFotoProfilSiswa.show(
      context,
      hasExistingPhoto: _profil?.photoUrl != null && _profil!.photoUrl!.isNotEmpty,
      onPickPhoto: _pickAndUploadPhoto,
      onRemovePhoto: _removePhoto,
    );
  }

  Future<void> _savePassword() async {
    if (!_formPasswordKey.currentState!.validate()) return;

    setState(() => _isSavingPassword = true);

    try {
      await _service.updatePassword(
        identifier: widget.identifier,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        setState(() {
          _isSavingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kata sandi berhasil diperbarui!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingPassword = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
            ),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await DialogKonfirmasiLogoutSiswa.show(context);
    if (confirmed != true) return;

    try {
      await FcmService.instance.unregisterTokenWithBackend();
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
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Profil Saya & Akun',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0284C7), // Sky 600
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Segarkan data profil',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadProfil,
          ),
          IconButton(
            tooltip: 'Keluar dari akun',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfil,
        color: const Color(0xFF0284C7),
        child: _buildBody(isTablet),
      ),
    );
  }

  Widget _buildBody(bool isTablet) {
    if (_isLoading && _profil == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat data profil pelajar...',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _profil == null) {
      return ProfilSiswaErrorState(
        errorMessage: _errorMessage!,
        onRetry: _loadProfil,
      );
    }

    final profil = _profil!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // 1. HERO HEADER WITH AVATAR & BADGES
          ProfilSiswaHeroHeader(
            profil: profil,
            isUploadingFoto: _isUploadingFoto,
            onShowPhotoOptions: _showPhotoOptions,
          ),

          // 2. TAB BAR
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0284C7),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF0284C7),
              indicatorWeight: 3,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.person_outline_rounded, size: 20),
                  text: 'Biodata & Kontak',
                ),
                Tab(
                  icon: Icon(Icons.lock_outline_rounded, size: 20),
                  text: 'Keamanan Sandi',
                ),
              ],
            ),
          ),

          // 3. TAB VIEW CONTENT
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 16,
              vertical: 20,
            ),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                if (_tabController.index == 0) {
                  return TabProfilSiswaBiodata(
                    profil: profil,
                    isTablet: isTablet,
                    formKontakKey: _formKontakKey,
                    addressController: _addressController,
                    noHpController: _noHpController,
                    noHpOrangTuaController: _noHpOrangTuaController,
                    isSavingKontak: _isSavingKontak,
                    onSaveKontak: _saveKontak,
                  );
                } else {
                  return TabProfilSiswaKeamanan(
                    isTablet: isTablet,
                    formPasswordKey: _formPasswordKey,
                    currentPasswordController: _currentPasswordController,
                    newPasswordController: _newPasswordController,
                    confirmPasswordController: _confirmPasswordController,
                    showCurrentPassword: _showCurrentPassword,
                    showNewPassword: _showNewPassword,
                    showConfirmPassword: _showConfirmPassword,
                    onToggleShowCurrent: () => setState(
                      () => _showCurrentPassword = !_showCurrentPassword,
                    ),
                    onToggleShowNew: () => setState(
                      () => _showNewPassword = !_showNewPassword,
                    ),
                    onToggleShowConfirm: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword,
                    ),
                    isSavingPassword: _isSavingPassword,
                    onSavePassword: _savePassword,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
