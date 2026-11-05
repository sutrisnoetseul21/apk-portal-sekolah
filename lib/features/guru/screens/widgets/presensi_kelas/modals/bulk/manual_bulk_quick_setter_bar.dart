import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class ManualBulkQuickSetterBar extends StatelessWidget {
  final String bulkDatang;
  final String bulkPulang;
  final bool enableCheckout;
  final ValueChanged<String?> onBulkDatangChanged;
  final ValueChanged<String?> onBulkPulangChanged;

  const ManualBulkQuickSetterBar({
    super.key,
    required this.bulkDatang,
    required this.bulkPulang,
    required this.enableCheckout,
    required this.onBulkDatangChanged,
    required this.onBulkPulangChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: bulkDatang.isEmpty ? null : bulkDatang,
                hint: const Text(
                  '⚡ Set Massal Datang',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'hadir', child: Text('⚡ Hadir Semua')),
                  DropdownMenuItem(value: 'telat', child: Text('Terlambat Semua')),
                  DropdownMenuItem(value: 'izin', child: Text('Izin Semua')),
                  DropdownMenuItem(value: 'sakit', child: Text('Sakit Semua')),
                  DropdownMenuItem(value: 'alpa', child: Text('Alpa Semua')),
                ],
                onChanged: onBulkDatangChanged,
              ),
            ),
          ),
        ),
        if (enableCheckout) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: bulkPulang.isEmpty ? null : bulkPulang,
                  hint: const Text(
                    '⚡ Set Massal Pulang',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'pulang', child: Text('⚡ Pulang Semua')),
                    DropdownMenuItem(value: 'izin', child: Text('Izin Semua')),
                    DropdownMenuItem(value: 'sakit', child: Text('Sakit Semua')),
                    DropdownMenuItem(value: 'alpa', child: Text('Alpa Semua')),
                  ],
                  onChanged: onBulkPulangChanged,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
