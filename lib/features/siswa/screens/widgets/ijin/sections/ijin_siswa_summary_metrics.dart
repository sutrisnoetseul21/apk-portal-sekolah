import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_ijin_model.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Ringkasan metrik 6 kotak status & kategori permohonan izin siswa
class IjinSiswaSummaryMetrics extends StatelessWidget {
  final SiswaIjinCounts? counts;
  final String selectedStatus;
  final String selectedType;
  final void Function(String status, String type) onFilterChanged;

  const IjinSiswaSummaryMetrics({
    super.key,
    required this.counts,
    required this.selectedStatus,
    required this.selectedType,
    required this.onFilterChanged,
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
                color: isSelected ? color.withValues(alpha: 0.14) : const Color(0xFF1E293B).withValues(alpha: 0.03),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          // Baris 1: Status Utama (3 kotak: Total, Menunggu, Disetujui)
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Total Izin',
                  count: counts?.total ?? 0,
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                  isSelected: selectedStatus == 'all' && selectedType == 'all',
                  onTap: () {
                    if (selectedStatus != 'all' || selectedType != 'all') {
                      onFilterChanged('all', 'all');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Menunggu',
                  count: counts?.pending ?? 0,
                  icon: Icons.hourglass_top_rounded,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFFFBEB),
                  isSelected: selectedStatus == 'pending' && selectedType == 'all',
                  onTap: () {
                    if (selectedStatus != 'pending' || selectedType != 'all') {
                      onFilterChanged('pending', 'all');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Disetujui',
                  count: counts?.approved ?? 0,
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFECFDF5),
                  isSelected: selectedStatus == 'approved' && selectedType == 'all',
                  onTap: () {
                    if (selectedStatus != 'approved' || selectedType != 'all') {
                      onFilterChanged('approved', 'all');
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Baris 2: Ditolak & Kategori (3 kotak: Ditolak, Sakit, Izin)
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Ditolak',
                  count: counts?.rejected ?? 0,
                  icon: Icons.cancel_outlined,
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFEF2F2),
                  isSelected: selectedStatus == 'rejected' && selectedType == 'all',
                  onTap: () {
                    if (selectedStatus != 'rejected' || selectedType != 'all') {
                      onFilterChanged('rejected', 'all');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Sakit',
                  count: counts?.sakit ?? 0,
                  icon: Icons.medical_services_outlined,
                  color: const Color(0xFF0284C7),
                  bg: const Color(0xFFF0F9FF),
                  isSelected: selectedType == 'sakit',
                  onTap: () {
                    if (selectedType != 'sakit') {
                      onFilterChanged('all', 'sakit');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Izin',
                  count: counts?.ijin ?? 0,
                  icon: Icons.mail_outline_rounded,
                  color: const Color(0xFF7C3AED),
                  bg: const Color(0xFFF5F3FF),
                  isSelected: selectedType == 'ijin',
                  onTap: () {
                    if (selectedType != 'ijin') {
                      onFilterChanged('all', 'ijin');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

