import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab 2: Keamanan Akun & Pembaruan Kata Sandi Siswa
class TabProfilSiswaKeamanan extends StatelessWidget {
  final bool isTablet;
  final GlobalKey<FormState> formPasswordKey;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool showCurrentPassword;
  final bool showNewPassword;
  final bool showConfirmPassword;
  final VoidCallback onToggleShowCurrent;
  final VoidCallback onToggleShowNew;
  final VoidCallback onToggleShowConfirm;
  final bool isSavingPassword;
  final VoidCallback onSavePassword;

  const TabProfilSiswaKeamanan({
    super.key,
    required this.isTablet,
    required this.formPasswordKey,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.showCurrentPassword,
    required this.showNewPassword,
    required this.showConfirmPassword,
    required this.onToggleShowCurrent,
    required this.onToggleShowNew,
    required this.onToggleShowConfirm,
    required this.isSavingPassword,
    required this.onSavePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: formPasswordKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Color(0xFF4F46E5),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Perbarui Kata Sandi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  'Gunakan kata sandi baru minimal 8 karakter dengan kombinasi huruf dan angka agar akun Anda tetap aman.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 18),

                // Kata Sandi Saat Ini
                Text(
                  'Kata Sandi Saat Ini *',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: !showCurrentPassword,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF64748B)),
                    suffixIcon: IconButton(
                      tooltip: showCurrentPassword ? 'Sembunyikan sandi' : 'Tampilkan sandi',
                      icon: Icon(
                        showCurrentPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: onToggleShowCurrent,
                    ),
                    hintText: 'Masukkan kata sandi lama Anda',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Kata sandi saat ini wajib diisi.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Kata Sandi Baru
                Text(
                  'Kata Sandi Baru *',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.key_rounded, size: 20, color: Color(0xFF64748B)),
                    suffixIcon: IconButton(
                      tooltip: showNewPassword ? 'Sembunyikan sandi' : 'Tampilkan sandi',
                      icon: Icon(
                        showNewPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: onToggleShowNew,
                    ),
                    hintText: 'Minimal 8 karakter',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Kata sandi baru wajib diisi.';
                    }
                    if (v.length < 8) {
                      return 'Kata sandi baru minimal 8 karakter.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Konfirmasi Kata Sandi Baru
                Text(
                  'Ulangi Kata Sandi Baru *',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20, color: Color(0xFF64748B)),
                    suffixIcon: IconButton(
                      tooltip: showConfirmPassword ? 'Sembunyikan sandi' : 'Tampilkan sandi',
                      icon: Icon(
                        showConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 20,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: onToggleShowConfirm,
                    ),
                    hintText: 'Ketik ulang kata sandi baru',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi kata sandi baru wajib diisi.';
                    }
                    if (v != newPasswordController.text) {
                      return 'Konfirmasi kata sandi baru tidak cocok.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Tombol Simpan Sandi
                ElevatedButton.icon(
                  onPressed: isSavingPassword ? null : onSavePassword,
                  icon: isSavingPassword
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.lock_outline_rounded, size: 18),
                  label: Text(
                    isSavingPassword ? 'Memperbarui Sandi...' : 'Perbarui Kata Sandi',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5), // Indigo
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

