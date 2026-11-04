import 'package:flutter/material.dart';

/// Segmented Tab Switcher Guru Wali: Siswa Asuh, Riwayat Jurnal, Ruang Cerita
class GuruWaliTabSwitcher extends StatelessWidget {
  final int activeTabIndex;
  final int totalSiswaAktif;
  final int pendingCeritaCount;
  final ValueChanged<int> onTabChanged;

  const GuruWaliTabSwitcher({
    super.key,
    required this.activeTabIndex,
    required this.totalSiswaAktif,
    required this.pendingCeritaCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // Tab 0: Siswa Asuh
          _buildSegmentButton(
            index: 0,
            label: 'Siswa Asuh',
            count: totalSiswaAktif,
          ),

          // Tab 1: Riwayat Jurnal
          _buildSegmentButton(
            index: 1,
            label: 'Riwayat Jurnal',
            count: null,
          ),

          // Tab 2: Ruang Aman Cerita
          _buildSegmentButton(
            index: 2,
            label: 'Ruang Cerita',
            count: pendingCeritaCount > 0 ? pendingCeritaCount : null,
            isAlertCount: pendingCeritaCount > 0,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String label,
    int? count,
    bool isAlertCount = false,
  }) {
    final isSelected = activeTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTabChanged(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF64748B),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isAlertCount
                        ? const Color(0xFFDC2626)
                        : (isSelected
                            ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                            : const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isAlertCount
                          ? Colors.white
                          : (isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF475569)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

