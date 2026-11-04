import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_kartu_model.dart';

/// Panel tombol aksi untuk kartu pelajar:
/// Scan fullscreen, unduh gambar kartu, unduh biodata, dan salin barcode.
class KartuActionPanel extends StatelessWidget {
  final SiswaKartuDigitalInfo info;
  final bool isSavingImage;
  final VoidCallback onOpenFullscreenBarcode;
  final VoidCallback onSaveCardAsImage;
  final VoidCallback onDownloadBiodata;
  final VoidCallback onCopyBarcode;

  const KartuActionPanel({
    super.key,
    required this.info,
    required this.isSavingImage,
    required this.onOpenFullscreenBarcode,
    required this.onSaveCardAsImage,
    required this.onDownloadBiodata,
    required this.onCopyBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Aksi & Unduhan Resmi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),

          // Tombol 1: Mode Scan Layar Penuh
          ElevatedButton.icon(
            onPressed: onOpenFullscreenBarcode,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            label: Text(
              'Buka Mode Scan Layar Penuh',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol 2: Simpan Gambar Kartu (Otomatis ke Download) & Unduh PDF
          ElevatedButton.icon(
            onPressed: isSavingImage ? null : onSaveCardAsImage,
            icon: isSavingImage
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_rounded, size: 20),
            label: Text(
              isSavingImage
                  ? 'Menyimpan Gambar...'
                  : 'Simpan Gambar Kartu (JPG)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669), // Emerald
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol 3: Unduh Biodata
          OutlinedButton.icon(
            onPressed: onDownloadBiodata,
            icon: const Icon(Icons.description_rounded, size: 18),
            label: Text(
              'Unduh Biodata',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol 4: Salin Barcode
          OutlinedButton.icon(
            onPressed: onCopyBarcode,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(
              'Salin Kode Barcode (${info.barcodeCode})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

