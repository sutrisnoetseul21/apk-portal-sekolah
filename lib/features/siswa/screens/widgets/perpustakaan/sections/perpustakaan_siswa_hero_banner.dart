import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_perpustakaan_model.dart';

/// Hero Banner Modern Perpustakaan Siswa
class PerpustakaanSiswaHeroBanner extends StatelessWidget {
  final SiswaPerpustakaanStudent? student;
  final String fallbackStudentName;
  final String fallbackIdentifier;

  const PerpustakaanSiswaHeroBanner({
    super.key,
    required this.student,
    required this.fallbackStudentName,
    required this.fallbackIdentifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF3730A3), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Perpustakaan Sekolah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cari buku yang ingin kamu pinjam dan pantau riwayat peminjamannya.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE0E7FF),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Student Info Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, size: 14, color: Color(0xFFC7D2FE)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${student?.name ?? fallbackStudentName} • Kelas ${student?.kelas ?? '-'} • NISN: ${student?.nisn ?? fallbackIdentifier}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

