import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Bar Navigasi Pagination Jurnal Mengajar
class JurnalPaginationBar extends StatelessWidget {
  final int currentPage;
  final int lastPage;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  const JurnalPaginationBar({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.totalItems,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 18),
            label: const Text('Sebelumnya', style: TextStyle(fontSize: 12)),
          ),
          Text(
            'Hal $currentPage / $lastPage ($totalItems)',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          OutlinedButton.icon(
            onPressed: currentPage < lastPage
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: const Text('Berikutnya', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

