import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_kartu_model.dart';

/// Sisi Belakang Kartu Pelajar Digital (Ketentuan Kartu, Masa Berlaku & Pengesahan Kepala Sekolah)
class KartuPelajarBackView extends StatelessWidget {
  final SiswaKartuDigitalInfo info;

  const KartuPelajarBackView({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Slate Dark
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Sisi Belakang
            Row(
              children: [
                const Icon(
                  Icons.policy_rounded,
                  color: Color(0xFFFCD34D),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'KETENTUAN KARTU PELAJAR',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFCD34D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 12),

            // Butir Peraturan
            _buildRuleItem('1',
                'Kartu ini merupakan tanda pengenal sah peserta didik ${info.schoolName}.'),
            _buildRuleItem('2',
                'Wajib dibawa setiap hari aktif sekolah untuk keperluan presensi barcode gerbang & transaksi perpustakaan.'),
            _buildRuleItem('3',
                'Dilarang meminjamkan, merusak, mencoret, atau menggandakan kartu tanpa persetujuan sekolah.'),
            _buildRuleItem('4',
                'Jika kartu fisik rusak/hilang, siswa dapat menunjukkan kartu digital ini atau mengunduh ulang berkas PDF resminya.'),

            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 12),

            // Pengesahan Kepala Sekolah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masa Berlaku:',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Selama Menjadi Siswa Aktif',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Kepala Sekolah,',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      info.principalName,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    if (info.principalNip.isNotEmpty &&
                        info.principalNip != '-')
                      Text(
                        'NIP. ${info.principalNip}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildRuleItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

