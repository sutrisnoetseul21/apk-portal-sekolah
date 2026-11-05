import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/konsultasi_guru_wali_model.dart';

class ChatTopicBanner extends StatelessWidget {
  final KonsultasiGuruWaliItem item;

  const ChatTopicBanner({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    Color badgeColor = const Color(0xFFB45309);
    Color badgeBg = const Color(0xFFFEF3C7);
    if (item.statusPengajuan == 'Dijadwalkan') {
      badgeColor = const Color(0xFF1D4ED8);
      badgeBg = const Color(0xFFDBEAFE);
    } else if (item.statusPengajuan == 'Selesai' || item.statusPengajuan == 'Dikonversi ke Jurnal') {
      badgeColor = const Color(0xFF047857);
      badgeBg = const Color(0xFFD1FAE5);
    } else if (item.statusPengajuan == 'Ditolak') {
      badgeColor = const Color(0xFFB91C1C);
      badgeBg = const Color(0xFFFEE2E2);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  item.statusPengajuan,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
              Text(
                item.createdAtFormatted,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.topikKonsultasi,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          if (item.jadwalPastiFormatted != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event_available_rounded, size: 14, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                Text(
                  'Jadwal Tatap Muka: ${item.jadwalPastiFormatted}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
