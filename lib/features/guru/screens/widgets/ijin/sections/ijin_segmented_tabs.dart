import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Segmented Tabs Filter Status Izin (Semua, Menunggu, Disetujui, Ditolak)
class IjinSegmentedTabs extends StatelessWidget {
  final String activeTab;
  final int pendingCount;
  final ValueChanged<String> onTabChanged;

  const IjinSegmentedTabs({
    super.key,
    required this.activeTab,
    required this.pendingCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'key': 'all', 'label': 'Semua', 'badge': 0},
      {'key': 'pending', 'label': 'Menunggu', 'badge': pendingCount},
      {'key': 'approved', 'label': 'Disetujui', 'badge': 0},
      {'key': 'rejected', 'label': 'Ditolak', 'badge': 0},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: tabs.map((t) {
          final isSelected = activeTab == t['key'];
          final badge = (t['badge'] as num?)?.toInt() ?? 0;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (activeTab != t['key']) {
                  onTabChanged(t['key'] as String);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
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
                      t['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF475569),
                      ),
                    ),
                    if (badge > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

