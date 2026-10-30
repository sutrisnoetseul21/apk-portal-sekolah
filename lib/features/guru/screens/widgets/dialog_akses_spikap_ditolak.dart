import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal BottomSheet / Dialog Edukatif untuk Guru yang Tidak Memiliki Akses ke Modul SPIKAP
class DialogAksesSpikapDitolak extends StatelessWidget {
  final String currentRoleLabel;

  const DialogAksesSpikapDitolak({
    super.key,
    required this.currentRoleLabel,
  });

  static Future<void> show(BuildContext context, {required String currentRoleLabel}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DialogAksesSpikapDitolak(currentRoleLabel: currentRoleLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Ikon & Judul
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akses Khusus & Konfidensial',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Modul SPIKAP (Anti-Perundungan)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Tutup',
                icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Kotak Informasi Status Jabatan Saat Ini
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Peran Anda saat ini: ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Expanded(
                  child: Text(
                    currentRoleLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Sesuai regulasi pencegahan dan penanganan kekerasan di lingkungan satuan pendidikan (Permendikbudristek No. 46/2023), laporan kasus perundungan bersifat sangat rahasia dan hanya dapat dipantau oleh:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF334155),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 14),

          // Daftar Peran yang Berwenang
          _buildRoleItem(
            icon: Icons.school_rounded,
            color: const Color(0xFF2563EB),
            title: 'Kepala Sekolah',
            description:
                'Pengawasan komprehensif seluruh laporan sekolah dan dasbor analitik kasus.',
          ),
          const SizedBox(height: 10),
          _buildRoleItem(
            icon: Icons.volunteer_activism_rounded,
            color: const Color(0xFF059669),
            title: 'Guru Bimbingan Konseling (BK)',
            description:
                'Investigasi laporan umum tujuan BK, seluruh laporan darurat, dan kelas pantauannya.',
          ),
          const SizedBox(height: 10),
          _buildRoleItem(
            icon: Icons.supervisor_account_rounded,
            color: const Color(0xFF7C3AED),
            title: 'Wali Kelas Aktif',
            description:
                'Pemantauan dan tindak lanjut aduan siswa dari kelas binaan/ampualannya saja.',
          ),

          const SizedBox(height: 20),

          // Tombol Paham
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Saya Mengerti',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
