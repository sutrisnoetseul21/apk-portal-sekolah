import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Modal Bottom Sheet Rincian Detail Jurnal KBM & Kehadiran Siswa
class SheetDetailJurnalKbm {
  static const Color _indigoPrimary = Color(0xFF4F46E5);
  static const Color _purpleAccent = Color(0xFF7C3AED);

  static Future<void> show(
    BuildContext context, {
    required Dio dio,
    required Map<String, dynamic> jurnal,
    String? identifier,
  }) async {
    final id = '${jurnal['id']}';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.5,
          maxChildSize: 0.94,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: FutureBuilder<Response<dynamic>>(
                future: dio.get(
                  '/guru/jurnal-mengajar/$id',
                  queryParameters: {'identifier': ?identifier},
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _indigoPrimary),
                    );
                  }
                  if (snapshot.hasError || snapshot.data?.data == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Gagal memuat detail presensi sesi KBM: ${snapshot.error ?? ''}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final body = snapshot.data!.data as Map;
                  final data = Map<String, dynamic>.from(
                    body['data'] as Map? ?? {},
                  );
                  final detail = Map<String, dynamic>.from(
                    data['jurnal'] as Map? ?? jurnal,
                  );
                  final students = (data['students'] as List? ?? [])
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList();

                  return Column(
                    children: [
                      // Header Modal
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 14, 16, 16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_indigoPrimary, _purpleAccent],
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(26),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${detail['materi'] ?? '-'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${detail['tanggal_formatted'] ?? detail['tanggal']} • ${detail['jam_ke_label'] ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(18),
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildBadgePill(
                                  '🎓 Kelas ${detail['class_name'] ?? '-'}',
                                  const Color(0xFFECFDF5),
                                  const Color(0xFF065F46),
                                ),
                                _buildBadgePill(
                                  '📖 ${detail['mata_pelajaran_name'] ?? '-'}',
                                  const Color(0xFFEEF2FF),
                                  _indigoPrimary,
                                ),
                                _buildBadgePill(
                                  '👥 Hadir: ${detail['total_hadir']}/${detail['total_siswa']} (${detail['persentase_kehadiran']}%)',
                                  const Color(0xFFF0FDF4),
                                  const Color(0xFF15803D),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'URAIAN AKTIVITAS KBM:',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${detail['uraian_materi'] ?? '-'}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if ('${detail['refleksi'] ?? ''}'
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'REFLEKSI / TINDAK LANJUT GURU:',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${detail['refleksi']}',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF78350F),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            Text(
                              'RINCIAN KEHADIRAN SISWA (${students.length} Siswa)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...students.asMap().entries.map((entry) {
                              final s = entry.value;
                              final isHadir = '${s['status_jurnal']}' == 'hadir';
                              final ket = '${s['keterangan'] ?? ''}'.trim();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isHadir
                                      ? Colors.white
                                      : const Color(0xFFFFF1F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isHadir
                                        ? AppColors.border
                                        : const Color(0xFFFECDD3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${entry.key + 1}.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${s['name'] ?? '-'}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (ket.isNotEmpty)
                                            Text(
                                              ket,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFFBE123C),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isHadir
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFFFE4E6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isHadir
                                            ? '✓ Hadir KBM'
                                            : '✕ Tidak Mengikuti',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          color: isHadir
                                              ? const Color(0xFF047857)
                                              : const Color(0xFFBE123C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
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

