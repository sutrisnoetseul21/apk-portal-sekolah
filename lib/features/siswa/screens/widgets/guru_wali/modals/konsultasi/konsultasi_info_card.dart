import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_guru_wali_model.dart';

class KonsultasiInfoCard extends StatelessWidget {
  final SiswaKonsultasiItem item;

  const KonsultasiInfoCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Guru Wali: ${item.guruName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.statusLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          if (item.formattedJadwalPasti != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 16,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 6),
                Text(
                  'Jadwal: ${item.formattedJadwalPasti}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            item.detail,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
