import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Seksi Statistik Presensi Sholat Dhuhur:
/// - Mode Switcher: Harian / Bulanan
/// - Bar Pemilihan Tanggal Harian & Tombol Cetak Rekap / Export Excel
/// - Indikator Hari Libur Sholat
/// - Grid 2x2 Kartu Statistik Gradient Interaktif
class SholatStatsSection extends StatelessWidget {
  final String rekapMode;
  final ValueChanged<String> onRekapModeChanged;
  final Map<String, dynamic> todayStats;
  final Map<String, dynamic> classMonthlyStats;
  final String todayDateLabel;
  final String selectedMonthLabel;
  final String selectedDailyDate;
  final VoidCallback onPickDailyDate;
  final void Function({required String jenis}) onDownloadExport;
  final String dailyFilter;
  final ValueChanged<String> onDailyFilterChanged;

  const SholatStatsSection({
    super.key,
    required this.rekapMode,
    required this.onRekapModeChanged,
    required this.todayStats,
    required this.classMonthlyStats,
    required this.todayDateLabel,
    required this.selectedMonthLabel,
    required this.selectedDailyDate,
    required this.onPickDailyDate,
    required this.onDownloadExport,
    required this.dailyFilter,
    required this.onDailyFilterChanged,
  });

  static const Color _emeraldPrimary = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    final hadir = (todayStats['hadir'] as num?)?.toInt() ?? 0;
    final ijin = (todayStats['ijin'] as num?)?.toInt() ?? 0;
    final tidakHadir = (todayStats['tidak_hadir'] as num?)?.toInt() ?? 0;
    final belum = (todayStats['belum'] as num?)?.toInt() ?? 0;
    final total = (todayStats['total'] as num?)?.toInt() ?? 0;
    final persenHadir = (todayStats['persentase_hadir'] as num?) ?? 0;
    final isHoliday = todayStats['is_holiday'] == true;
    final holidayDesc = todayStats['holiday_desc']?.toString();

    final mHadir = (classMonthlyStats['hadir'] as num?)?.toInt() ?? 0;
    final mIjin = (classMonthlyStats['ijin'] as num?)?.toInt() ?? 0;
    final mTidakHadir = (classMonthlyStats['tidak_hadir'] as num?)?.toInt() ?? 0;
    final mEffDays = (classMonthlyStats['effective_days'] as num?)?.toInt() ?? 0;
    final mMax = (classMonthlyStats['max_possible'] as num?)?.toInt() ?? 0;
    final mPct = (classMonthlyStats['class_percentage'] as num?) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul & Mode Toggle Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      rekapMode == 'harian'
                          ? 'Sholat Dhuhur Harian'
                          : 'Rekap Sholat Bulanan',
                      style: const TextStyle(
                        fontSize: 16.5,
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
                      rekapMode == 'harian' ? 'Harian' : '1 Bulan',
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

        if (rekapMode == 'harian')
          Text(
            'Tanggal: $todayDateLabel • Wajib Sholat: $total Siswa • Kehadiran: $persenHadir%',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          )
        else
          Text(
            'Potensi Maksimal: $mMax ($total Siswa × $mEffDays Hari Sholat • $selectedMonthLabel)',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

        if (rekapMode == 'harian') ...[
          const SizedBox(height: 10),
          // Action Bar Harian: Pilih Tanggal + Cetak Rekap Kelas PDF + Export Excel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event_note_rounded,
                      size: 16,
                      color: _emeraldPrimary,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Tanggal Harian:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: onPickDailyDate,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDailyDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: _emeraldPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _emeraldPrimary,
                          side: const BorderSide(color: Color(0xFFA7F3D0)),
                          backgroundColor: const Color(0xFFECFDF5),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => onDownloadExport(jenis: 'rekap_kelas'),
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
                        label: const Text(
                          'Rekap Kelas (PDF)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF047857),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => onDownloadExport(jenis: 'excel_harian'),
                        icon: const Icon(Icons.table_view_outlined, size: 14),
                        label: const Text(
                          'Export Excel',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (isHoliday && rekapMode == 'harian') ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tanggal ini adalah Hari Libur Sholat Dhuhur (${holidayDesc ?? 'Libur'}).',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Grid 2x2 Kartu Statistik Berwarna
        if (rekapMode == 'harian')
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Hadir Berjamaah',
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
                      title: 'Ijin / Halangan',
                      mainValue: '$ijin',
                      subValue: '/ $total',
                      badgeText: 'Haid / Sakit',
                      icon: Icons.info_outline_rounded,
                      colors: const [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                      isSelected: dailyFilter == 'ijin',
                      onTap: () {
                        onDailyFilterChanged(
                          dailyFilter == 'ijin' ? 'all' : 'ijin',
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
                      title: 'Tidak Hadir',
                      mainValue: '$tidakHadir',
                      subValue: '/ $total',
                      badgeText: tidakHadir > 0 ? 'Perlu Pantau' : 'Nihil',
                      icon: Icons.cancel_outlined,
                      colors: const [Color(0xFFF43F5E), Color(0xFFDB2777)],
                      isSelected: dailyFilter == 'tidak_hadir',
                      onTap: () {
                        onDailyFilterChanged(
                          dailyFilter == 'tidak_hadir' ? 'all' : 'tidak_hadir',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Belum Absen Sholat',
                      mainValue: '$belum',
                      subValue: '/ $total',
                      badgeText: belum == 0 ? '✓ Tuntas' : 'Perlu Tindakan',
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
                      title: 'Total Ijin/Halangan',
                      mainValue: '$mIjin',
                      subValue: '/ $mMax',
                      badgeText: mMax > 0
                          ? '${((mIjin / mMax) * 100).toStringAsFixed(1)}%'
                          : '0%',
                      icon: Icons.info_outline_rounded,
                      colors: const [Color(0xFF3B82F6), Color(0xFF4F46E5)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatGradientCard(
                      title: 'Total Alpa',
                      mainValue: '$mTidakHadir',
                      subValue: '/ $mMax',
                      badgeText: mMax > 0
                          ? '${((mTidakHadir / mMax) * 100).toStringAsFixed(1)}%'
                          : '0%',
                      icon: Icons.cancel_outlined,
                      colors: const [Color(0xFFF43F5E), Color(0xFFDB2777)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatGradientCard(
                      title: '% Kepatuhan',
                      mainValue: '$mPct%',
                      subValue: '',
                      badgeText: '$mEffDays Hari',
                      icon: Icons.bar_chart_rounded,
                      colors: const [Color(0xFF334155), Color(0xFF1E293B)],
                    ),
                  ),
                ],
              ),
            ],
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
            color: active ? _emeraldPrimary : AppColors.textSecondary,
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
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
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
                if (subValue.isNotEmpty) ...[
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

