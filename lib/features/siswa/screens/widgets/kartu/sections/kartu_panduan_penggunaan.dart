import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kartu Informasi & Panduan Penggunaan Barcode Kartu Pelajar.
class KartuPanduanPenggunaan extends StatelessWidget {
  const KartuPanduanPenggunaan({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF4338CA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tips Pemindaian Barcode',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF312E81),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTipRow(
            Icons.brightness_high_rounded,
            'Pastikan kecerahan layar HP cukup terang saat dihadapkan ke alat scanner gerbang.',
          ),
          _buildTipRow(
            Icons.straighten_rounded,
            'Jaga jarak layar HP sekitar 10-15 cm tegak lurus dengan moncong pemindai barcode.',
          ),
          _buildTipRow(
            Icons.print_outlined,
            'Berkas PDF kartu pelajar siap dicetak pada kertas foto tebal atau kartu PVC standar ID-1.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF3730A3),
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

