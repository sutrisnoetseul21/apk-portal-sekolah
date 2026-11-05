import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_presensi_kbm_model.dart';
import '../modals/sheet_kbm_siswa_subject_detail.dart';

/// Daftar Kartu Mata Pelajaran (11-12 Mapel) dengan Statistik Pertemuan Terdata
class KbmSiswaSubjectList extends StatelessWidget {
  final List<SiswaKbmSubject> subjects;

  const KbmSiswaSubjectList({
    super.key,
    required this.subjects,
  });

  IconData _getSubjectIcon(String namaMapel) {
    final lower = namaMapel.toLowerCase();
    if (lower.contains('matematika')) return Icons.calculate_rounded;
    if (lower.contains('indonesia') || lower.contains('inggirs') || lower.contains('inggris') || lower.contains('jawa')) {
      return Icons.translate_rounded;
    }
    if (lower.contains('informatika') || lower.contains('komputer') || lower.contains('tik')) {
      return Icons.computer_rounded;
    }
    if (lower.contains('alam') || lower.contains('ipa')) return Icons.science_rounded;
    if (lower.contains('sosial') || lower.contains('ips')) return Icons.public_rounded;
    if (lower.contains('agama') || lower.contains('pai')) return Icons.menu_book_rounded;
    if (lower.contains('jasmani') || lower.contains('pjok') || lower.contains('olahraga')) {
      return Icons.sports_volleyball_rounded;
    }
    if (lower.contains('pancasila') || lower.contains('ppkn') || lower.contains('pkn')) {
      return Icons.shield_rounded;
    }
    if (lower.contains('seni') || lower.contains('budaya') || lower.contains('prakarya')) {
      return Icons.palette_rounded;
    }
    if (lower.contains('konseling') || lower.contains('bk')) return Icons.support_agent_rounded;
    return Icons.auto_stories_rounded;
  }

  Color _getIconBgColor(int index) {
    const colors = [
      Color(0xFFEEF2FF), // Indigo
      Color(0xFFECFDF5), // Emerald
      Color(0xFFEFF6FF), // Blue
      Color(0xFFFEF3C7), // Amber
      Color(0xFFF3E8FF), // Purple
      Color(0xFFFCE7F3), // Pink
      Color(0xFFE0F2FE), // Sky
      Color(0xFFFFEDD5), // Orange
    ];
    return colors[index % colors.length];
  }

  Color _getIconColor(int index) {
    const colors = [
      Color(0xFF4F46E5), // Indigo
      Color(0xFF059669), // Emerald
      Color(0xFF2563EB), // Blue
      Color(0xFFD97706), // Amber
      Color(0xFF7C3AED), // Purple
      Color(0xFFDB2777), // Pink
      Color(0xFF0284C7), // Sky
      Color(0xFFEA580C), // Orange
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: Column(
            children: [
              Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                'Tidak Ada Mata Pelajaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Data rombongan belajar Anda belum terdaftar di sistem pengajaran.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mata Pelajaran Anda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              '${subjects.length} Mapel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...subjects.asMap().entries.map((entry) {
          final index = entry.key;
          final subject = entry.value;
          return _buildSubjectCard(context, subject, index);
        }),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, SiswaKbmSubject subject, int index) {
    final iconBg = _getIconBgColor(index);
    final iconColor = _getIconColor(index);
    final icon = _getSubjectIcon(subject.namaMapel);
    final stats = subject.stats;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            SheetKbmSiswaSubjectDetail.show(context, subject: subject);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),

                // Mapel & Guru
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.namaMapel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subject.guruPengampu.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (subject.hasData) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${stats.totalPertemuanTerdata} Pertemuan',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Belum Ada Jurnal',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Badge Kehadiran / Aksi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (subject.hasData) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: stats.persentaseKehadiran >= 85
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stats.persentaseKehadiran.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: stats.persentaseKehadiran >= 85
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.hadir}/${stats.totalPertemuanTerdata} Hadir',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
