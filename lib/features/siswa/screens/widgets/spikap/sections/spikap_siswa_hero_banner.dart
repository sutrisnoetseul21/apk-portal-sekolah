import 'package:flutter/material.dart';
import '../../models/siswa_spikap_model.dart';

/// Hero Banner dan Hotline Perlindungan Kerahasiaan SPIKAP Siswa
class SpikapSiswaHeroBanner extends StatelessWidget {
  final SiswaSpikapBranding? branding;

  const SpikapSiswaHeroBanner({
    super.key,
    required this.branding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Hero Gradient Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFF9F1239)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33E11D48),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lencana Hero SPIKAP
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded, size: 12, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'SPIKAP • Ruang Aman & Layanan Pengaduan Murid',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branding?.namaAplikasi ?? 'SPIKAP',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          branding?.subJudul ?? 'Anti-Perundungan & Pengaduan Siswa',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                branding?.penjelasan ??
                    'Ruang aman, nyaman, dan terlindungi kerahasiaannya untuk menyampaikan aduan perundungan, kekerasan fisik/verbal, atau perselisihan di sekolah.',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. Hotline Kerahasiaan Terjamin
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFFE11D48), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Perlindungan Kerahasiaan Terjamin',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9F1239),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Untuk situasi darurat/kritis, pilih opsi "🚨 Darurat" agar laporan langsung diteruskan hari ini juga ke Kepala Sekolah dan Tim Penanganan Kekerasan.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF881337), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

