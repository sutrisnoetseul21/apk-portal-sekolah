import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Komponen pemilih tanggal mulai dan stepper durasi hari permohonan izin
class FormIjinDatePickerSection extends StatelessWidget {
  final String formattedStartDate;
  final String formattedEndDate;
  final int durationDays;
  final VoidCallback onSelectStartDate;
  final ValueChanged<int> onUpdateDuration;

  const FormIjinDatePickerSection({
    super.key,
    required this.formattedStartDate,
    required this.formattedEndDate,
    required this.durationDays,
    required this.onSelectStartDate,
    required this.onUpdateDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Waktu & Durasi Izin',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Tanggal Mulai
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onSelectStartDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal Mulai',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedStartDate,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.grey,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Stepper Durasi Hari
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Durasi Pengajuan',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$durationDays Hari',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      tooltip: 'Kurangi 1 Hari',
                      onPressed: durationDays > 1 ? () => onUpdateDuration(-1) : null,
                    ),
                    Text(
                      '$durationDays',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      tooltip: 'Tambah 1 Hari',
                      onPressed: durationDays < 30 ? () => onUpdateDuration(1) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (durationDays > 1) ...[
            const Divider(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 16,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Berlaku s.d. $formattedEndDate',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

