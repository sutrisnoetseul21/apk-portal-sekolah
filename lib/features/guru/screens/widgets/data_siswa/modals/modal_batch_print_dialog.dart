import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal bottom sheet untuk opsi cetak dan unduh massal PDF rombel
class ModalBatchPrintDialog {
  static void show({
    required BuildContext context,
    required String className,
    required VoidCallback onPrintKartuMassal,
    required VoidCallback onPrintBiodataMassal,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cetak / Unduh Massal Rombel',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Format PDF resmi untuk rombel $className',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Opsi 1: Cetak Kartu Siswa 1 Rombel
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.print_rounded,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  title: Text(
                    'Cetak Kartu Pelajar 1 Kelas (PDF)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Kartu barcode seluruh siswa kelas ini'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onPrintKartuMassal();
                  },
                ),

                const Divider(height: 1),

                // Opsi 2: Unduh Biodata Lengkap 1 Rombel
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  title: Text(
                    'Unduh Biodata Siswa 1 Kelas (PDF)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Rekap lembar biodata resmi seluruh siswa'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onPrintBiodataMassal();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

