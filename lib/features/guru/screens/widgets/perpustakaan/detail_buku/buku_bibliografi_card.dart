import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/perpustakaan_models.dart';

class BukuBibliografiCard extends StatelessWidget {
  final BukuItem buku;

  const BukuBibliografiCard({
    super.key,
    required this.buku,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Bibliografi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInfoRow('Penerbit', buku.penerbit),
              _buildDivider(),
              _buildInfoRow(
                  'Tahun Terbit', buku.tahunTerbit?.toString() ?? '-'),
              _buildDivider(),
              _buildInfoRow('ISBN', buku.isbn ?? '-'),
              _buildDivider(),
              _buildInfoRow('Lokasi Rak', buku.lokasiRak),
              _buildDivider(),
              _buildInfoRow(
                'Nomor Panggil',
                buku.callNumber?.replaceAll('\n', ' ') ?? '-',
              ),
              if (buku.klasifikasiDdc != null) ...[
                _buildDivider(),
                _buildInfoRow(
                  'Klasifikasi DDC',
                  '${buku.klasifikasiDdc!.kodeDdc ?? ''} - ${buku.klasifikasiDdc!.namaKlasifikasi ?? ''}',
                ),
              ],
              if (buku.mataPelajaran != null) ...[
                _buildDivider(),
                _buildInfoRow(
                  'Mata Pelajaran',
                  buku.mataPelajaran!.namaMapel ?? '-',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 12, color: Colors.grey.shade200);
  }
}
