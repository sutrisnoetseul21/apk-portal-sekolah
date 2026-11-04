import 'package:flutter/material.dart';

/// Action Bar Cepat Guru Wali (+ Klasikal, Pemantauan, PDF)
class GuruWaliActionBar extends StatelessWidget {
  final VoidCallback onTambahKlasikal;
  final VoidCallback onBukaPemantauan;
  final VoidCallback onCetakPdf;

  const GuruWaliActionBar({
    super.key,
    required this.onTambahKlasikal,
    required this.onBukaPemantauan,
    required this.onCetakPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tombol + Bimbingan Klasikal
        Expanded(
          flex: 4,
          child: ElevatedButton.icon(
            onPressed: onTambahKlasikal,
            icon: const Icon(Icons.group_add_rounded, size: 16),
            label: const Text(
              '+ Klasikal',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Tombol Pemantauan Progres
        Expanded(
          flex: 4,
          child: OutlinedButton.icon(
            onPressed: onBukaPemantauan,
            icon: const Icon(Icons.bar_chart_rounded,
                size: 16, color: Color(0xFF334155)),
            label: const Text(
              'Pemantauan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Tombol Cetak PDF
        Expanded(
          flex: 3,
          child: OutlinedButton.icon(
            onPressed: onCetakPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded,
                size: 15, color: Color(0xFFDC2626)),
            label: const Text(
              'PDF',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFFECACA)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

