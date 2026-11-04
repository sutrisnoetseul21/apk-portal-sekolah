import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/siswa_guru_wali_model.dart';

/// Ringkasan Metrik Interaktif SI-WALI Siswa
class SiwaliSummaryMetrics extends StatelessWidget {
  final SiswaGuruWaliCounts? counts;
  final int currentTabIndex;
  final String statusFilter;
  final String jenisKlasikalFilter;
  final ValueChanged<String> onSelectKonsultasiStatus;
  final ValueChanged<String> onSelectKlasikalJenis;

  const SiwaliSummaryMetrics({
    super.key,
    required this.counts,
    required this.currentTabIndex,
    required this.statusFilter,
    required this.jenisKlasikalFilter,
    required this.onSelectKonsultasiStatus,
    required this.onSelectKlasikalJenis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Baris 1: Konsultasi Mandiri (3 kotak: Konsultasi, Menunggu, Dijadwalkan)
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                title: 'Konsultasi',
                count: counts?.semua ?? 0,
                icon: Icons.chat_bubble_outline_rounded,
                color: const Color(0xFF2563EB),
                bg: const Color(0xFFEFF6FF),
                isSelected: currentTabIndex == 0 && statusFilter == 'all',
                onTap: () => onSelectKonsultasiStatus('all'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                title: 'Menunggu',
                count: counts?.menunggu ?? 0,
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFD97706),
                bg: const Color(0xFFFFFBEB),
                isSelected: currentTabIndex == 0 && statusFilter == 'menunggu',
                onTap: () => onSelectKonsultasiStatus('menunggu'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                title: 'Dijadwalkan',
                count: counts?.dijadwalkan ?? 0,
                icon: Icons.event_available_rounded,
                color: const Color(0xFF0284C7),
                bg: const Color(0xFFF0F9FF),
                isSelected: currentTabIndex == 0 && statusFilter == 'dijadwalkan',
                onTap: () => onSelectKonsultasiStatus('dijadwalkan'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Baris 2: Selesai, Klasikal, Kelompok Kecil (3 kotak)
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                title: 'Selesai',
                count: counts?.selesai ?? 0,
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF059669),
                bg: const Color(0xFFECFDF5),
                isSelected: currentTabIndex == 0 && statusFilter == 'selesai',
                onTap: () => onSelectKonsultasiStatus('selesai'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                title: 'Klasikal',
                count: counts?.klasikal ?? 0,
                icon: Icons.groups_outlined,
                color: const Color(0xFF7C3AED),
                bg: const Color(0xFFF5F3FF),
                isSelected: currentTabIndex == 1 &&
                    jenisKlasikalFilter == 'Klasikal',
                onTap: () => onSelectKlasikalJenis('Klasikal'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                title: 'Kelompok Kecil',
                count: counts?.kelompokKecil ?? 0,
                icon: Icons.group_work_outlined,
                color: const Color(0xFF0D9488),
                bg: const Color(0xFFF0FDFA),
                isSelected: currentTabIndex == 1 &&
                    jenisKlasikalFilter == 'Kelompok Kecil',
                onTap: () => onSelectKlasikalJenis('Kelompok Kecil'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? bg.withValues(alpha: 0.5) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? bg.withValues(alpha: 0.4) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withValues(alpha: 0.14)
                    : const Color(0xFF1E293B).withValues(alpha: 0.03),
                blurRadius: isSelected ? 6 : 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

