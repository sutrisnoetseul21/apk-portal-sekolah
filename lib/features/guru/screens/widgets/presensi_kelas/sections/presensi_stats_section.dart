import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Bagian Statistik Presensi (Rekap Harian / Bulanan, Grid 2x2 Gradient Card, Switcher & Pencarian)
class PresensiStatsSection extends StatelessWidget {
  final String rekapMode;
  final ValueChanged<String> onRekapModeChanged;
  final String todayDateLabel;
  final String selectedMonthLabel;
  final Map<String, dynamic> todayStats;
  final Map<String, dynamic> classMonthlyStats;
  final String dailyFilter;
  final ValueChanged<String> onDailyFilterChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;
  final int totalStudents;

  const PresensiStatsSection({
    super.key,
    required this.rekapMode,
    required this.onRekapModeChanged,
    required this.todayDateLabel,
    required this.selectedMonthLabel,
    required this.todayStats,
    required this.classMonthlyStats,
    required this.dailyFilter,
    required this.onDailyFilterChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchQueryChanged,
    required this.totalStudents,
  });

  @override
  Widget build(BuildContext context) {
    final total = (todayStats['total'] as num?)?.toInt() ?? totalStudents;
    final hadir = (todayStats['hadir'] as num?)?.toInt() ?? 0;
    final telat = (todayStats['telat'] as num?)?.toInt() ?? 0;
    final sakit = (todayStats['sakit'] as num?)?.toInt() ?? 0;
    final izin = (todayStats['izin'] as num?)?.toInt() ?? 0;
    final alpa = (todayStats['alpa'] as num?)?.toInt() ?? 0;
    final belum = (todayStats['belum'] as num?)?.toInt() ?? 0;
    final persenHadir =
        (todayStats['persentase_hadir'] as num?)?.toInt() ?? 0;

    final mMax = (classMonthlyStats['max_possible'] as num?)?.toInt() ?? 0;
    final mHadir = (classMonthlyStats['hadir'] as num?)?.toInt() ?? 0;
    final mTelat = (classMonthlyStats['telat'] as num?)?.toInt() ?? 0;
    final mSakit = (classMonthlyStats['sakit'] as num?)?.toInt() ?? 0;
    final mIzin = (classMonthlyStats['izin'] as num?)?.toInt() ?? 0;
    final mAlpa = (classMonthlyStats['alpa'] as num?)?.toInt() ?? 0;
    final mEffDays =
        (classMonthlyStats['effective_days'] as num?)?.toInt() ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Judul & Toggle Mode (Rekap Harian / Rekap Bulanan)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      rekapMode == 'harian'
                          ? 'Rekapitulasi Harian'
                          : 'Rekapitulasi Bulanan',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: rekapMode == 'harian'
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      rekapMode == 'harian' ? 'Hari Ini' : '1 Bulan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: rekapMode == 'harian'
                            ? const Color(0xFF065F46)
                            : const Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Pill Toggle Rekap Harian / Bulanan
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeToggleBtn('Harian', 'harian'),
                  _buildModeToggleBtn('Bulanan', 'bulanan'),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Sub-judul informasi
        if (rekapMode == 'harian')
          Text(
            'Presensi: $todayDateLabel • Total: $total Siswa • Kehadiran: $persenHadir%',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          )
        else
          Text(
            'Potensi Maksimal: $mMax ($total Siswa × $mEffDays Hari Efektif • $selectedMonthLabel)',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

        const SizedBox(height: 12),

        // Grid 2x2 Kartu Statistik Berwarna
        if (rekapMode == 'harian')
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Hadir Tepat Waktu',
                      mainValue: '$hadir',
                      subValue: '/ $total',
                      badgeText: total > 0
                          ? '${((hadir / total) * 100).round()}%'
                          : '0%',
                      icon: Icons.check_circle_outline_rounded,
                      colors: const [Color(0xFF10B981), Color(0xFF0D9488)],
                      isSelected: dailyFilter == 'hadir',
                      onTap: () {
                        onDailyFilterChanged(
                          dailyFilter == 'hadir' ? 'all' : 'hadir',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Terlambat',
                      mainValue: '$telat',
                      subValue: '/ $total',
                      badgeText: telat > 0 ? 'Telat' : 'Nihil',
                      icon: Icons.access_time_rounded,
                      colors: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                      isSelected: dailyFilter == 'telat',
                      onTap: () {
                        onDailyFilterChanged(
                          dailyFilter == 'telat' ? 'all' : 'telat',
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Sakit / Izin',
                      mainValue: '${sakit + izin}',
                      subValue: '/ $total',
                      badgeText: '${sakit}S • ${izin}I',
                      icon: Icons.description_outlined,
                      colors: const [Color(0xFFF43F5E), Color(0xFFDB2777)],
                      isSelected: dailyFilter == 'izin',
                      onTap: () {
                        onDailyFilterChanged(
                          dailyFilter == 'izin' ? 'all' : 'izin',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Belum Absen',
                      mainValue: '$belum',
                      subValue: '/ $total',
                      badgeText: belum == 0 ? '✓ Tuntas' : 'Perlu Tindakan',
                      footerNote: alpa > 0 ? '• $alpa Alpa hari ini' : null,
                      icon: belum == 0
                          ? Icons.verified_rounded
                          : Icons.warning_amber_rounded,
                      colors: belum == 0
                          ? const [Color(0xFF4F46E5), Color(0xFF6D28D9)]
                          : const [Color(0xFF334155), Color(0xFF0F172A)],
                      isSelected: dailyFilter == 'belum',
                      onTap: () {
                        onDailyFilterChanged(
                          dailyFilter == 'belum' ? 'all' : 'belum',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Total Hadir',
                      mainValue: '$mHadir',
                      subValue: '/ $mMax',
                      badgeText: mMax > 0
                          ? '${((mHadir / mMax) * 100).toStringAsFixed(1)}%'
                          : '0%',
                      icon: Icons.check_circle_outline_rounded,
                      colors: const [Color(0xFF10B981), Color(0xFF0D9488)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Total Telat',
                      mainValue: '$mTelat',
                      subValue: '/ $mMax',
                      badgeText: 'Bulan Ini',
                      icon: Icons.access_time_rounded,
                      colors: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Total Sakit/Izin',
                      mainValue: '${mSakit + mIzin}',
                      subValue: '/ $mMax',
                      badgeText: '${mSakit}S • ${mIzin}I',
                      icon: Icons.description_outlined,
                      colors: const [Color(0xFFF43F5E), Color(0xFFDB2777)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Total Alpa',
                      mainValue: '$mAlpa',
                      subValue: '/ $mMax',
                      badgeText: 'Tanpa Ket.',
                      icon: Icons.report_problem_outlined,
                      colors: const [Color(0xFF475569), Color(0xFF334155)],
                    ),
                  ),
                ],
              ),
            ],
          ),

        const SizedBox(height: 16),

        // Tab Switcher Harian / Bulanan
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onRekapModeChanged('harian'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: rekapMode == 'harian'
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 15,
                          color: rekapMode == 'harian'
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Presensi Hari Ini ($total)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: rekapMode == 'harian'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onRekapModeChanged('bulanan'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: rekapMode == 'bulanan'
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grid_on_rounded,
                          size: 15,
                          color: rekapMode == 'bulanan'
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tabel Matriks Bulanan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: rekapMode == 'bulanan'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Kolom Pencarian Nama Siswa / NISN
        TextField(
          controller: searchController,
          onChanged: onSearchQueryChanged,
          decoration: InputDecoration(
            hintText: 'Cari nama siswa / NISN...',
            hintStyle: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 19,
              color: AppColors.textSecondary,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      searchController.clear();
                      onSearchQueryChanged('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggleBtn(String label, String modeValue) {
    final active = rekapMode == modeValue;
    return GestureDetector(
      onTap: () => onRekapModeChanged(modeValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatGradientCard({
    required String title,
    required String mainValue,
    required String subValue,
    required String badgeText,
    required IconData icon,
    required List<Color> colors,
    String? footerNote,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: isSelected ? 0.45 : 0.22),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  mainValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  subValue,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (footerNote != null) ...[
              const SizedBox(height: 2),
              Text(
                footerNote,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

