import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Kartu Item Jurnal Mengajar
class JurnalItemCard extends StatelessWidget {
  final Map<String, dynamic> jurnal;
  final bool isSupervisor;
  final VoidCallback onDetail;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const JurnalItemCard({
    super.key,
    required this.jurnal,
    required this.isSupervisor,
    required this.onDetail,
    this.onEdit,
    this.onDelete,
  });

  static const Color _indigoPrimary = Color(0xFF4F46E5);
  static const Color _purpleAccent = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final tanggalFormatted =
        '${jurnal['tanggal_formatted'] ?? jurnal['tanggal']}';
    final jamKeLabel = '${jurnal['jam_ke_label'] ?? ''}';
    final className = '${jurnal['class_name'] ?? '-'}';
    final mapelName = '${jurnal['mata_pelajaran_name'] ?? '-'}';
    final teacherName = '${jurnal['teacher_name'] ?? '-'}';
    final materi = '${jurnal['materi'] ?? '-'}';
    final uraian = '${jurnal['uraian_materi'] ?? '-'}';
    final refleksi = '${jurnal['refleksi'] ?? ''}'.trim();
    final totalSiswa = int.tryParse('${jurnal['total_siswa'] ?? 0}') ?? 0;
    final totalHadir = int.tryParse('${jurnal['total_hadir'] ?? 0}') ?? 0;
    final totalTidakMengikuti =
        int.tryParse('${jurnal['total_tidak_mengikuti'] ?? 0}') ?? 0;
    final persentase = '${jurnal['persentase_kehadiran'] ?? 0}';
    final canEdit = jurnal['can_edit'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges Header
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadgePill(
                '📅 $tanggalFormatted',
                const Color(0xFFF1F5F9),
                const Color(0xFF1E293B),
              ),
              _buildBadgePill(
                '⏰ $jamKeLabel',
                _indigoPrimary.withValues(alpha: 0.1),
                _indigoPrimary,
              ),
              _buildBadgePill(
                '🎓 Kelas $className',
                const Color(0xFFECFDF5),
                const Color(0xFF065F46),
              ),
              _buildBadgePill(
                '📖 $mapelName',
                _purpleAccent.withValues(alpha: 0.1),
                _purpleAccent,
              ),
              if (isSupervisor && teacherName.isNotEmpty)
                _buildBadgePill(
                  '👤 $teacherName',
                  const Color(0xFFFFFBEB),
                  const Color(0xFF92400E),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Materi Pokok
          Text(
            materi,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Uraian Aktivitas KBM
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(
              uraian,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                height: 1.45,
              ),
            ),
          ),

          // Refleksi Guru jika ada
          if (refleksi.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF334155),
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Refleksi / Catatan Tindak Lanjut: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF78350F),
                            ),
                          ),
                          TextSpan(text: refleksi),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 24),

          // Footer: Kehadiran & Tombol Aksi
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TINGKAT KEHADIRAN',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '$totalHadir/$totalSiswa',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($persentase%)',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: totalTidakMengikuti > 0
                                ? const Color(0xFFFFE4E6)
                                : const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            totalTidakMengikuti > 0
                                ? '$totalTidakMengikuti Tidak Hadir'
                                : '✓ Semua Hadir',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: totalTidakMengikuti > 0
                                  ? const Color(0xFF9F1239)
                                  : const Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol Detail Presensi Sesi
              IconButton(
                onPressed: onDetail,
                tooltip: 'Lihat Detail Kehadiran Siswa',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Color(0xFF475569),
                ),
              ),

              if (canEdit && onEdit != null && onDelete != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Edit Jurnal',
                  style: IconButton.styleFrom(
                    backgroundColor: _indigoPrimary.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: _indigoPrimary.withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: _indigoPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Hapus Jurnal',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F2),
                    side: const BorderSide(color: Color(0xFFFECDD3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildBadgePill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

