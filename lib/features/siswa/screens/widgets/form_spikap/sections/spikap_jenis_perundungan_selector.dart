import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Komponen pemilih jenis tindakan perundungan / kekerasan
class SpikapJenisPerundunganSelector extends StatelessWidget {
  final String selectedJenis;
  final ValueChanged<String> onJenisChanged;

  const SpikapJenisPerundunganSelector({
    super.key,
    required this.selectedJenis,
    required this.onJenisChanged,
  });

  @override
  Widget build(BuildContext context) {
    final list = [
      {
        'key': 'fisik',
        'label': 'Kekerasan Fisik',
        'desc': 'Pemukulan, dorongan, kontak fisik',
      },
      {
        'key': 'verbal',
        'label': 'Kekerasan Verbal',
        'desc': 'Ejekan, hinaan, ancaman, fitnah',
      },
      {
        'key': 'sosial',
        'label': 'Kekerasan Sosial',
        'desc': 'Pengucilan, intimidasi kelompok',
      },
      {
        'key': 'digital',
        'label': 'Cyberbullying',
        'desc': 'Pelecehan medsos, teror pesan digital',
      },
      {
        'key': 'lainnya',
        'label': 'Lainnya',
        'desc': 'Bentuk perselisihan / konflik lainnya',
      },
    ];

    return Column(
      children: list.map((item) {
        final isSel = selectedJenis == item['key'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onJenisChanged(item['key']!),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  width: isSel ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSel
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSel ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['label']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel
                                ? const Color(0xFF1D4ED8)
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          item['desc']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

