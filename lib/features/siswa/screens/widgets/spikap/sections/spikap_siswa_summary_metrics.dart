import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/siswa_spikap_model.dart';

/// Grid 2 Baris x 3 Kolom Kotak Metrik SPIKAP
class SpikapSiswaSummaryMetrics extends StatelessWidget {
  final SiswaSpikapCounts? counts;
  final String activeMetric;
  final ValueChanged<String> onSelectMetric;

  const SpikapSiswaSummaryMetrics({
    super.key,
    required this.counts,
    required this.activeMetric,
    required this.onSelectMetric,
  });

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
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Baris 1: Status Aduan (3 Kotak: Semua Aduan, Diterima, Investigasi)
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Semua Aduan',
                  count: counts?.total ?? 0,
                  icon: Icons.shield_outlined,
                  color: const Color(0xFFE11D48),
                  bg: const Color(0xFFFFF1F2),
                  isSelected: activeMetric == 'all',
                  onTap: () => onSelectMetric('all'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Diterima',
                  count: counts?.diterima ?? 0,
                  icon: Icons.hourglass_top_rounded,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFFFBEB),
                  isSelected: activeMetric == 'diterima',
                  onTap: () => onSelectMetric('diterima'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Investigasi',
                  count: counts?.dalamInvestigasi ?? 0,
                  icon: Icons.policy_rounded,
                  color: const Color(0xFF0284C7),
                  bg: const Color(0xFFF0F9FF),
                  isSelected: activeMetric == 'dalam_investigasi',
                  onTap: () => onSelectMetric('dalam_investigasi'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Baris 2: Kelanjutan Status & Sifat (3 Kotak: Selesai, Darurat, Biasa)
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Selesai',
                  count: counts?.selesai ?? 0,
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFECFDF5),
                  isSelected: activeMetric == 'selesai',
                  onTap: () => onSelectMetric('selesai'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Darurat',
                  count: counts?.darurat ?? 0,
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFEF2F2),
                  isSelected: activeMetric == 'darurat',
                  onTap: () => onSelectMetric('darurat'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Biasa',
                  count: counts?.biasa ?? 0,
                  icon: Icons.info_outline_rounded,
                  color: const Color(0xFF7C3AED),
                  bg: const Color(0xFFF5F3FF),
                  isSelected: activeMetric == 'biasa',
                  onTap: () => onSelectMetric('biasa'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

