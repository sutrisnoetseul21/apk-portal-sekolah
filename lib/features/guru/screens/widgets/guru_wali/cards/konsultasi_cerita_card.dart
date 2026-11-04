import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/konsultasi_guru_wali_model.dart';

/// Kartu Item Konsultasi Siswa (Ruang Aman Cerita Guru Wali)
class KonsultasiCeritaCard extends StatelessWidget {
  final KonsultasiGuruWaliItem item;
  final VoidCallback onOpenChat;

  const KonsultasiCeritaCard({
    super.key,
    required this.item,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeBg;
    Color badgeText;
    switch (item.statusPengajuan) {
      case 'Menunggu Konfirmasi':
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFB45309);
        break;
      case 'Dijadwalkan':
        badgeBg = const Color(0xFFDBEAFE);
        badgeText = const Color(0xFF1D4ED8);
        break;
      case 'Selesai':
      case 'Dikonversi ke Jurnal':
        badgeBg = const Color(0xFFD1FAE5);
        badgeText = const Color(0xFF047857);
        break;
      default:
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFB91C1C);
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpenChat,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.statusPengajuan,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: badgeText,
                      ),
                    ),
                  ),
                  Text(
                    item.createdAtFormatted,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                item.studentName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '${item.kelasName} • Mode: ${item.modeKonsultasi} • [${item.kategoriPendampingan}]',
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 6),

              Text(
                item.topikKonsultasi,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.detailPermasalahan,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 10),

              // Action Button: Buka Percakapan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.unreadMessagesCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.unreadMessagesCount} Pesan Baru',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton.icon(
                    onPressed: onOpenChat,
                    icon: const Icon(Icons.forum_rounded, size: 14),
                    label: const Text(
                      'Buka Obrolan',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

