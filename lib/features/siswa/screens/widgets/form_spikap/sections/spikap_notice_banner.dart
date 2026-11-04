import 'package:flutter/material.dart';

/// Banner pemberitahuan ruang aman dan perlindungan identitas pelapor SPIKAP
class SpikapNoticeBanner extends StatelessWidget {
  const SpikapNoticeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_rounded, color: Color(0xFFE11D48), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Layanan ini adalah ruang aman bagi Anda. Identitas dan laporan Anda dijaga dengan penuh tanggung jawab oleh pihak sekolah.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9F1239),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

