import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_presensi_kbm_model.dart';
import '../modals/sheet_kbm_siswa_subject_detail.dart';

/// Daftar Kartu Mata Pelajaran (11-12 Mapel) dengan Grid 2x2 Kotak Status Kehadiran
/// Mengacu pada tampilan /portal-siswa/jurnal-kbm (Hadir, Izin/Sakit, Alpa, Tidak Mengikuti)
class KbmSiswaSubjectList extends StatelessWidget {
  final List<SiswaKbmSubject> subjects;

  const KbmSiswaSubjectList({
    super.key,
    required this.subjects,
  });

  IconData _getSubjectIcon(String namaMapel) {
    final lower = namaMapel.toLowerCase();
    if (lower.contains('matematika')) return Icons.calculate_rounded;
    if (lower.contains('indonesia') ||
        lower.contains('inggirs') ||
        lower.contains('inggris') ||
        lower.contains('jawa')) {
      return Icons.translate_rounded;
    }
    if (lower.contains('informatika') ||
        lower.contains('komputer') ||
        lower.contains('tik')) {
      return Icons.computer_rounded;
    }
    if (lower.contains('alam') || lower.contains('ipa')) {
      return Icons.science_rounded;
    }
    if (lower.contains('sosial') || lower.contains('ips')) {
      return Icons.public_rounded;
    }
    if (lower.contains('agama') || lower.contains('pai')) {
      return Icons.menu_book_rounded;
    }
    if (lower.contains('jasmani') ||
        lower.contains('pjok') ||
        lower.contains('olahraga')) {
      return Icons.sports_volleyball_rounded;
    }
    if (lower.contains('pancasila') ||
        lower.contains('ppkn') ||
        lower.contains('pkn')) {
      return Icons.shield_rounded;
    }
    if (lower.contains('seni') ||
        lower.contains('budaya') ||
        lower.contains('prakarya')) {
      return Icons.palette_rounded;
    }
    if (lower.contains('konseling') || lower.contains('bk')) {
      return Icons.support_agent_rounded;
    }
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.layers_rounded,
                        size: 18,
                        color: Color(0xFF4F46E5),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Daftar Mata Pelajaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Klik mata pelajaran untuk melihat kronologi materi dan absensi:',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E7FF)),
              ),
              child: Text(
                '${subjects.length} Mapel',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4338CA),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...subjects.asMap().entries.map((entry) {
          final index = entry.key;
          final subject = entry.value;
          return _buildSubjectCard(context, subject, index);
        }),
      ],
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    SiswaKbmSubject subject,
    int index,
  ) {
    final iconBg = _getIconBgColor(index);
    final iconColor = _getIconColor(index);
    final icon = _getSubjectIcon(subject.namaMapel);
    final stats = subject.stats;
    final izinSakitTotal = stats.izin + stats.sakit;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            SheetKbmSiswaSubjectDetail.show(context, subject: subject);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Kartu Mapel (Ikon + Nama Mapel & Guru)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.namaMapel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  subject.guruPengampu.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!subject.hasData) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'Belum Ada Jurnal',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // 2. Breakdown Kehadiran Siswa Per Mapel (Kotak-Kotak 2x2)
                if (subject.hasData) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusBox(
                          label: 'HADIR',
                          value: '${stats.hadir} kali',
                          bgColor: const Color(0xFFECFDF5),
                          borderColor: const Color(0xFFA7F3D0),
                          labelColor: const Color(0xFF059669),
                          valueColor: const Color(0xFF047857),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusBox(
                          label: 'IZIN / SAKIT',
                          value: '$izinSakitTotal kali',
                          subtitle: izinSakitTotal > 0
                              ? '(${stats.izin} Izin, ${stats.sakit} Sakit)'
                              : null,
                          bgColor: const Color(0xFFEFF6FF),
                          borderColor: const Color(0xFFBFDBFE),
                          labelColor: const Color(0xFF2563EB),
                          valueColor: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusBox(
                          label: 'ALPA',
                          value: '${stats.alpa} kali',
                          bgColor: const Color(0xFFFFFBEB),
                          borderColor: const Color(0xFFFDE68A),
                          labelColor: const Color(0xFFD97706),
                          valueColor: const Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusBox(
                          label: 'TIDAK MENGIKUTI',
                          value: '${stats.tidakMengikuti} kali',
                          bgColor: const Color(0xFFFFF1F2),
                          borderColor: const Color(0xFFFECDD3),
                          labelColor: const Color(0xFFE11D48),
                          valueColor: const Color(0xFFBE123C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pertemuan Terdata:',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${stats.totalPertemuanTerdata} Pertemuan',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      'Belum ada catatan pertemuan KBM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // 3. Tombol Lihat Riwayat KBM
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lihat Riwayat KBM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF334155),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF475569),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBox({
    required String label,
    required String value,
    String? subtitle,
    required Color bgColor,
    required Color borderColor,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
