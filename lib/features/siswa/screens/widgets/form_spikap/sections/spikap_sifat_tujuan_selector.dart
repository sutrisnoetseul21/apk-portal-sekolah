import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Komponen pemilih sifat laporan (Darurat vs Biasa) dan tujuan penerima (BK vs Wali Kelas)
class SpikapSifatTujuanSelector extends StatelessWidget {
  final String sifatLaporan;
  final ValueChanged<String> onSifatChanged;
  final String tujuanPenerima;
  final ValueChanged<String> onTujuanChanged;

  const SpikapSifatTujuanSelector({
    super.key,
    required this.sifatLaporan,
    required this.onSifatChanged,
    required this.tujuanPenerima,
    required this.onTujuanChanged,
  });

  Widget _buildChoiceCard({
    required String title,
    required String desc,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFCBD5E1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? activeColor : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Sifat Laporan
        const Row(
          children: [
            Text(
              '1. Sifat Laporan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Color(0xFFE11D48),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildChoiceCard(
                title: '🚨 Darurat',
                desc: 'Butuh tindakan cepat hari ini',
                isSelected: sifatLaporan == 'darurat',
                activeColor: const Color(0xFFE11D48),
                onTap: () => onSifatChanged('darurat'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChoiceCard(
                title: 'Biasa',
                desc: 'Konseling & tindak lanjut',
                isSelected: sifatLaporan == 'biasa',
                activeColor: const Color(0xFF2563EB),
                onTap: () => onSifatChanged('biasa'),
              ),
            ),
          ],
        ),

        // 2. Tujuan Penerima (Hanya jika Biasa)
        if (sifatLaporan == 'biasa') ...[
          const SizedBox(height: 20),
          const Row(
            children: [
              Text(
                '2. Tujuan Laporan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildChoiceCard(
                  title: 'Guru BK',
                  desc: 'Bimbingan & Konseling',
                  isSelected: tujuanPenerima == 'guru_bk',
                  activeColor: const Color(0xFF2563EB),
                  onTap: () => onTujuanChanged('guru_bk'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceCard(
                  title: 'Wali Kelas',
                  desc: 'Wali kelas binaan Anda',
                  isSelected: tujuanPenerima == 'wali_kelas',
                  activeColor: const Color(0xFF2563EB),
                  onTap: () => onTujuanChanged('wali_kelas'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

