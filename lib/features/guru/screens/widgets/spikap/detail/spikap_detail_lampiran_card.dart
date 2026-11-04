import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/spikap_models.dart';

/// Card galeri lampiran bukti kasus SPIKAP (foto & video)
class SpikapDetailLampiranCard extends StatelessWidget {
  final List<SpikapLampiranItem> lampiran;
  final ValueChanged<SpikapLampiranItem> onImageTap;
  final ValueChanged<SpikapLampiranItem> onVideoTap;

  const SpikapDetailLampiranCard({
    super.key,
    required this.lampiran,
    required this.onImageTap,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lampiran.isEmpty) return const SizedBox.shrink();

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
          Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                size: 16,
                color: Color(0xFF059669),
              ),
              const SizedBox(width: 6),
              Text(
                'Lampiran Bukti (${lampiran.length} Berkas)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: lampiran.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final lamp = lampiran[index];
                final isFoto = lamp.tipeFile == 'foto';
                return InkWell(
                  onTap: () {
                    if (isFoto) {
                      onImageTap(lamp);
                    } else {
                      onVideoTap(lamp);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (isFoto)
                          CachedNetworkImage(
                            imageUrl: lamp.url,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF94A3B8),
                            ),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 36,
                                  color: Color(0xFFDC2626),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Putar Video',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              lamp.ukuranLabel,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '* Ketuk foto untuk memperbesar atau video untuk memutar',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

