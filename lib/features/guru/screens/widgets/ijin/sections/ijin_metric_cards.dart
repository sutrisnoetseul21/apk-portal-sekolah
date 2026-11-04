import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Bilah Kartu Metrik Persetujuan Izin (Menunggu, Disetujui, Ditolak)
class IjinMetricCards extends StatelessWidget {
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final String activeTab;
  final ValueChanged<String> onTabSelected;

  const IjinMetricCards({
    super.key,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Menunggu',
            count: pendingCount,
            subtext: 'Perlu Aksi',
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            isActive: activeTab == 'pending',
            onTap: () => onTabSelected('pending'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            title: 'Disetujui',
            count: approvedCount,
            subtext: 'Terverifikasi',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF059669),
            bgColor: const Color(0xFFECFDF5),
            isActive: activeTab == 'approved',
            onTap: () => onTabSelected('approved'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            title: 'Ditolak',
            count: rejectedCount,
            subtext: 'Tidak Sah',
            icon: Icons.cancel_outlined,
            color: const Color(0xFF64748B),
            bgColor: const Color(0xFFF1F5F9),
            isActive: activeTab == 'rejected',
            onTap: () => onTabSelected('rejected'),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required String subtext,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: isActive ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? color.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              subtext,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

