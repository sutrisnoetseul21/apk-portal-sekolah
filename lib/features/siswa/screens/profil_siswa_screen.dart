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
import 'widgets/profil/sheets/sheet_ganti_foto_profil_siswa.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Hapus Foto Profil?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus foto profil dan kembali menggunakan inisial nama?',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Hapus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFE11D48), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Keluar dari Aplikasi?',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Anda akan keluar dari sesi akun pelajar ini. Sesi login tersimpan akan dibersihkan.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text('Ya, Keluar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

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
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_rounded,
                  color: Color(0xFFE11D48),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Profil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF9F1239),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFFBE123C),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadProfil,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
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
