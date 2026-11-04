import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_profil_model.dart';

/// Tab 1: Biodata Akademik & Formulir Alamat/Kontak Siswa
class TabProfilSiswaBiodata extends StatelessWidget {
  final SiswaProfilDetail profil;
  final bool isTablet;
  final GlobalKey<FormState> formKontakKey;
  final TextEditingController addressController;
  final TextEditingController noHpController;
  final TextEditingController noHpOrangTuaController;
  final bool isSavingKontak;
  final VoidCallback onSaveKontak;

  const TabProfilSiswaBiodata({
    super.key,
    required this.profil,
    required this.isTablet,
    required this.formKontakKey,
    required this.addressController,
    required this.noHpController,
    required this.noHpOrangTuaController,
    required this.isSavingKontak,
    required this.onSaveKontak,
  });

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom 1: Data Akademik Read-Only
          Expanded(
            flex: 5,
            child: _buildAkademikCard(),
          ),
          const SizedBox(width: 20),
          // Kolom 2: Form Kontak
          Expanded(
            flex: 5,
            child: _buildFormKontakCard(),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAkademikCard(),
        const SizedBox(height: 20),
        _buildFormKontakCard(),
      ],
    );
  }

  /// Kartu Informasi Akademik Resmi (Read-Only)
  Widget _buildAkademikCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Identitas Akademik',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      'Terkunci',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 14),

          _buildInfoRow('Nama Lengkap', profil.name),
          _buildInfoRow('NISN', profil.nisn),
          _buildInfoRow('NIS', profil.nis),
          _buildInfoRow('Tempat, Tanggal Lahir', profil.birthInfo),
          _buildInfoRow('Jenis Kelamin', '${profil.genderLabel} (${profil.gender})'),
          _buildInfoRow('Agama', profil.religion),
          _buildInfoRow('Email Akun', profil.email),
          _buildInfoRow('Barcode ID', profil.barcodeCode),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          Text(
            'DATA ORANG TUA / WALI',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _buildInfoRow('Nama Ayah', profil.namaAyah),
          _buildInfoRow('Pekerjaan Ayah', profil.pekerjaanAyah),
          _buildInfoRow('Nama Ibu', profil.namaIbu),
          _buildInfoRow('Pekerjaan Ibu', profil.pekerjaanIbu),
          if (profil.namaWali.isNotEmpty && profil.namaWali != '-')
            _buildInfoRow('Nama Wali', profil.namaWali),

          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perubahan data akademik hanya dapat diajukan melalui Tata Usaha Sekolah.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu Formulir Pengkinian Alamat & No. HP
  Widget _buildFormKontakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        key: formKontakKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.contact_phone_rounded,
                    color: Color(0xFF059669),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Alamat & Kontak Domisili',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 16),

            // Alamat Domisili
            Text(
              'Alamat Tempat Tinggal *',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: addressController,
              maxLines: 3,
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tuliskan nama dusun/jalan, RT/RW, desa/kelurahan, kecamatan...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.all(14),
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
                if (v == null || v.trim().isEmpty) {
                  return 'Alamat tempat tinggal tidak boleh kosong.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Nomor HP Siswa
            Text(
              'Nomor HP / WhatsApp Siswa',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: noHpController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_android_rounded, size: 20, color: Color(0xFF64748B)),
                hintText: 'Contoh: 081234567890',
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
            ),

            const SizedBox(height: 16),

            // Nomor HP Orang Tua / Wali (Read-Only / Disabled untuk Siswa)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Nomor HP Orang Tua / Wali',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded, size: 10, color: Color(0xFF64748B)),
                      const SizedBox(width: 3),
                      Text(
                        'Wali Kelas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: noHpOrangTuaController,
              readOnly: true,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.contact_phone_outlined, size: 20, color: Color(0xFF94A3B8)),
                suffixIcon: const Tooltip(
                  message: 'Hanya dapat diubah oleh Wali Kelas / Admin',
                  child: Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                ),
                hintText: 'Belum diisi oleh wali kelas',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                helperText: 'Nomor HP orang tua diinput & diperbarui oleh Wali Kelas / Admin Sekolah',
                helperStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
                helperMaxLines: 2,
              ),
            ),

            const SizedBox(height: 20),

            // Tombol Simpan
            ElevatedButton.icon(
              onPressed: isSavingKontak ? null : onSaveKontak,
              icon: isSavingKontak
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                isSavingKontak ? 'Menyimpan...' : 'Simpan Perubahan Kontak',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669), // Emerald
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
    );
  }
}

