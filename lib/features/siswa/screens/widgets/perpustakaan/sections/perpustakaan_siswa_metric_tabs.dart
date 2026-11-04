import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Menu 3 Kotak Tab (Sedang Dipinjam, Riwayat Pinjam, Kunjungan)
class PerpustakaanSiswaMetricTabs extends StatelessWidget {
  final int selectedIndex;
  final int pinjamanAktifCount;
  final int riwayatCount;
  final int kunjunganCount;
  final int terlambatCount;
  final ValueChanged<int> onTabSelected;

  const PerpustakaanSiswaMetricTabs({
    super.key,
    required this.selectedIndex,
    required this.pinjamanAktifCount,
    required this.riwayatCount,
    required this.kunjunganCount,
    required this.terlambatCount,
    required this.onTabSelected,
  });

  Widget _buildMetricTabItem({
    required int index,
    required IconData icon,
    required String title,
    required int count,
    bool hasAlert = false,
    String? alertText,
  }) {
    final isSelected = selectedIndex == index;
    const activeColor = Color(0xFF4F46E5);

    return Semantics(
      button: true,
      label: '$title, $count item, ${isSelected ? 'terpilih' : 'tidak terpilih'}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabSelected(index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? activeColor : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? activeColor : const Color(0xFF64748B),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? activeColor : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? activeColor : const Color(0xFF64748B),
                  ),
                ),
                if (hasAlert && alertText != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alertText,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Kotak 1: Sedang Dipinjam
        Expanded(
          child: _buildMetricTabItem(
            index: 0,
            icon: Icons.auto_stories_rounded,
            title: 'Sedang Dipinjam',
            count: pinjamanAktifCount,
            hasAlert: terlambatCount > 0,
            alertText: '$terlambatCount terlambat',
          ),
        ),
        const SizedBox(width: 8),

        // Kotak 2: Riwayat Pinjam
        Expanded(
          child: _buildMetricTabItem(
            index: 1,
            icon: Icons.history_rounded,
            title: 'Riwayat Pinjam',
            count: riwayatCount,
          ),
        ),
        const SizedBox(width: 8),

        // Kotak 3: Riwayat Kunjungan
        Expanded(
          child: _buildMetricTabItem(
            index: 2,
            icon: Icons.badge_outlined,
            title: 'Kunjungan',
            count: kunjunganCount,
          ),
        ),
      ],
    );
  }
}

