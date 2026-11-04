import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';

/// Daftar Presensi Harian: Filter Chips, Empty/Congratulation Banner, & Kartu Siswa Mobile
class PresensiDailyAttendance extends StatelessWidget {
  final List<Map<String, dynamic>> filteredStudents;
  final Map<String, dynamic> todayStats;
  final String dailyFilter;
  final ValueChanged<String> onDailyFilterChanged;
  final int totalStudents;
  final bool isNotifBelumActive;
  final bool isNotifTelatActive;
  final void Function(String id, String name) onOpenStudentDetail;
  final void Function(Map<String, dynamic> student, String type) onOpenWaModal;
  final void Function(Map<String, dynamic> student) onOpenSingleInputModal;

  const PresensiDailyAttendance({
    super.key,
    required this.filteredStudents,
    required this.todayStats,
    required this.dailyFilter,
    required this.onDailyFilterChanged,
    required this.totalStudents,
    required this.isNotifBelumActive,
    required this.isNotifTelatActive,
    required this.onOpenStudentDetail,
    required this.onOpenWaModal,
    required this.onOpenSingleInputModal,
  });

  @override
  Widget build(BuildContext context) {
    final total = (todayStats['total'] as num?)?.toInt() ?? totalStudents;
    final belum = (todayStats['belum'] as num?)?.toInt() ?? 0;
    final hadir = (todayStats['hadir'] as num?)?.toInt() ?? 0;
    final telat = (todayStats['telat'] as num?)?.toInt() ?? 0;
    final izinSakit =
        ((todayStats['sakit'] as num?)?.toInt() ?? 0) +
        ((todayStats['izin'] as num?)?.toInt() ?? 0);
    final alpa = (todayStats['alpa'] as num?)?.toInt() ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Baris Filter Chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  count: total,
                  value: 'all',
                  activeColor: const Color(0xFF1E293B),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Belum Absen',
                  count: belum,
                  value: 'belum',
                  activeColor: const Color(0xFFE11D48),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Hadir',
                  count: hadir,
                  value: 'hadir',
                  activeColor: const Color(0xFF059669),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Telat',
                  count: telat,
                  value: 'telat',
                  activeColor: const Color(0xFFD97706),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Sakit / Izin',
                  count: izinSakit,
                  value: 'izin',
                  activeColor: const Color(0xFF7C3AED),
                ),
                if (alpa > 0) ...[
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    label: 'Alpa',
                    count: alpa,
                    value: 'alpa',
                    activeColor: const Color(0xFF334155),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Banner Spesial jika Filter 'Belum Absen' dipilih dan nilainya 0
        if (dailyFilter == 'belum' && belum == 0)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Colors.white, Color(0xFFF0FDFA)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Luar Biasa! Semua Siswa Sudah Presensi 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tidak ada siswa yang belum hadir hari ini. Seluruh $total siswa telah terdata dalam sistem presensi.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => onDailyFilterChanged('all'),
                  child: const Text(
                    'Tampilkan Semua Siswa',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        else if (filteredStudents.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'Tidak ada siswa yang sesuai dengan filter pencarian.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...filteredStudents.map((student) => _buildMobileStudentCard(student)),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required String value,
    required Color activeColor,
  }) {
    final isSelected = dailyFilter == value;
    return GestureDetector(
      onTap: () => onDailyFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStudentCard(Map<String, dynamic> student) {
    final id = student['id']?.toString() ?? '';
    final name = student['name']?.toString() ?? '-';
    final nisn = student['nisn']?.toString() ?? '-';
    final today = Map<String, dynamic>.from(student['today'] ?? {});
    final status = today['status']?.toString() ?? 'belum';
    final scanDatang = today['scan_time']?.toString();
    final scanPulang = today['scan_out_time']?.toString();
    final lateMinutes = (today['late_minutes'] as num?)?.toInt() ?? 0;
    final note = today['note']?.toString();

    Color avatarBg;
    Color avatarFg;
    Color badgeBg;
    Color badgeFg;
    String badgeText;

    switch (status) {
      case 'hadir':
        avatarBg = const Color(0xFFD1FAE5);
        avatarFg = const Color(0xFF047857);
        badgeBg = const Color(0xFFD1FAE5);
        badgeFg = const Color(0xFF065F46);
        badgeText = scanDatang != null && scanDatang.isNotEmpty
            ? 'Hadir ($scanDatang)'
            : 'Hadir';
        break;
      case 'telat':
        avatarBg = const Color(0xFFFEF3C7);
        avatarFg = const Color(0xFFB45309);
        badgeBg = const Color(0xFFFEF3C7);
        badgeFg = const Color(0xFF92400E);
        badgeText = lateMinutes > 0 ? 'Telat (${lateMinutes}m)' : 'Telat';
        break;
      case 'izin':
        avatarBg = const Color(0xFFEDE9FE);
        avatarFg = const Color(0xFF6D28D9);
        badgeBg = const Color(0xFFDBEAFE);
        badgeFg = const Color(0xFF1E40AF);
        badgeText = 'Izin';
        break;
      case 'sakit':
        avatarBg = const Color(0xFFEDE9FE);
        avatarFg = const Color(0xFF6D28D9);
        badgeBg = const Color(0xFFEDE9FE);
        badgeFg = const Color(0xFF5B21B6);
        badgeText = 'Sakit';
        break;
      case 'alpa':
        avatarBg = const Color(0xFFFEE2E2);
        avatarFg = const Color(0xFFB91C1C);
        badgeBg = const Color(0xFF334155);
        badgeFg = Colors.white;
        badgeText = 'Alpa';
        break;
      default:
        avatarBg = const Color(0xFFFFE4E6);
        avatarFg = const Color(0xFFBE123C);
        badgeBg = const Color(0xFFFFE4E6);
        badgeFg = const Color(0xFF9F1239);
        badgeText = 'Belum Absen';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Inisial 2 Huruf
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: avatarBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.length >= 2
                      ? name.substring(0, 2).toUpperCase()
                      : name.toUpperCase(),
                  style: TextStyle(
                    color: avatarFg,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              // Nama Siswa & NISN
              Expanded(
                child: GestureDetector(
                  onTap: () => onOpenStudentDetail(id, name),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NISN: $nisn',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Badge Status Kehadiran
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badgeFg,
                  ),
                ),
              ),
            ],
          ),

          // Catatan / Note jika ada
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Text(
                'Catatan: $note',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],

          // Jam Scan Pulang jika ada
          if (scanPulang != null && scanPulang.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Scan Pulang: $scanPulang WIB',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Footer Aksi Cepat: Detail Siswa | WA Ortu / WA Telat | Input Presensi / Ubah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => onOpenStudentDetail(id, name),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      Text(
                        'Detail Siswa',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  if (status == 'belum' && isNotifBelumActive)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => onOpenWaModal(student, 'belum'),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.chat_rounded,
                                size: 13.5,
                                color: Color(0xFF047857),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'WA Ortu',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (status == 'telat' && isNotifTelatActive)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => onOpenWaModal(student, 'telat'),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.chat_rounded,
                                size: 13.5,
                                color: Color(0xFFB45309),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'WA Telat',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () => onOpenSingleInputModal(student),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'belum'
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status == 'belum' ? 'Input Presensi' : 'Ubah',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: status == 'belum'
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

