import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Komponen pemilih periode analitik kasus SPIKAP (30 Hari, 3 Bulan, 6 Bulan, 1 Tahun)
class SpikapAnalitikPeriodeSelector extends StatelessWidget {
  final String selectedPeriode;
  final List<Map<String, String>> periodeOptions;
  final ValueChanged<String> onPeriodeChanged;

  const SpikapAnalitikPeriodeSelector({
    super.key,
    required this.selectedPeriode,
    required this.periodeOptions,
    required this.onPeriodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.date_range_rounded,
            size: 18,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Text(
            'Periode: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: periodeOptions.map((opt) {
                  final isSelected = opt['key'] == selectedPeriode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(opt['label']!),
                      selected: isSelected,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFF1F5F9),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                      onSelected: (selected) {
                        if (selected && selectedPeriode != opt['key']) {
                          onPeriodeChanged(opt['key']!);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

