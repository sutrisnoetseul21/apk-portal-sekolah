import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/perpustakaan_models.dart';

class BukuEksemplarListSection extends StatelessWidget {
  final BukuItem buku;

  const BukuEksemplarListSection({
    super.key,
    required this.buku,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Eksemplar Fisik',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${buku.eksemplarTersediaCount} dari ${buku.totalEksemplar} Tersedia',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (buku.eksemplar.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                'Belum ada data eksemplar terdaftar untuk buku ini.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...buku.eksemplar.map((eks) => _buildEksemplarCard(eks)),
      ],
    );
  }

  Widget _buildEksemplarCard(EksemplarBukuItem eks) {
    final bool isTersedia = eks.status.toLowerCase() == 'tersedia';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTersedia ? Colors.grey.shade200 : Colors.pink.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTersedia ? Colors.teal.shade50 : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 20,
              color: isTersedia ? Colors.teal.shade700 : Colors.amber.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eks.kodeEksemplar,
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Kondisi: ${eks.kondisiFisik.toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isTersedia
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isTersedia ? 'Tersedia' : eks.status.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isTersedia
                    ? const Color(0xFF047857)
                    : const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
