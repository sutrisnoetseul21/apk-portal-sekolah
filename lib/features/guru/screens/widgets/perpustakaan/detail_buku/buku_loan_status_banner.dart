import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/perpustakaan_models.dart';

class BukuLoanStatusBanner extends StatelessWidget {
  final BukuItem buku;
  final Function(String url) onOpenPdf;

  const BukuLoanStatusBanner({
    super.key,
    required this.buku,
    required this.onOpenPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (buku.dipinjamOlehSaya) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFFB45309), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sedang Anda Pinjam',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                      if (buku.earliestReturnDate != null)
                        Text(
                          'Batas pengembalian: ${buku.earliestReturnDate}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ] else if (buku.eksemplarTersediaCount == 0 &&
            buku.earliestReturnDate != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    color: Color(0xFFBE123C), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semua Eksemplar Sedang Dipinjam',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color(0xFFBE123C),
                        ),
                      ),
                      Text(
                        'Estimasi tersedia kembali sekitar: ${buku.earliestReturnDate}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF9F1239),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Action: Tombol Baca PDF jika tersedia
        if (buku.hasPdf &&
            buku.filePdfUrl != null &&
            buku.filePdfUrl!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              onPressed: () => onOpenPdf(buku.filePdfUrl!),
              icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
              label: Text(
                'Baca E-Book Digital (PDF)',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
