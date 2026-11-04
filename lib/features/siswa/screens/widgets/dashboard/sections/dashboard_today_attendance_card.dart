import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import '../../models/siswa_dashboard_model.dart';

/// Kartu dinamis status presensi masuk & sholat hari ini untuk dashboard siswa
class DashboardTodayAttendanceCard extends StatelessWidget {
  final SiswaTodayAttendance? attendance;
  final SiswaTodaySholat? sholat;
  final VoidCallback onTap;

  const DashboardTodayAttendanceCard({
    super.key,
    required this.attendance,
    required this.sholat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Presensi Config
    Color attColor = const Color(0xFF64748B);
    IconData attIcon = Icons.radio_button_unchecked_rounded;
    String attTitle = 'Belum Presensi';
    String attSubtitle = 'Presensi Masuk';

    if (attendance != null) {
      if (attendance!.status == 'hadir') {
        attColor = const Color(0xFF059669);
        attIcon = Icons.check_circle_outline_rounded;
        attTitle = 'Tepat Waktu';
        if (attendance!.scanInTime != null) {
          attSubtitle = 'Masuk: ${attendance!.scanInTime} WIB';
        }
      } else if (attendance!.status == 'telat') {
        attColor = const Color(0xFFD97706);
        attIcon = Icons.access_time_rounded;
        attTitle = 'Terlambat ${attendance!.lateMinutes}m';
        if (attendance!.scanInTime != null) {
          attSubtitle = 'Masuk: ${attendance!.scanInTime} WIB';
        }
      } else if (attendance!.status == 'libur') {
        attColor = const Color(0xFF64748B);
        attIcon = Icons.weekend_outlined;
        attTitle = 'Hari Libur';
        attSubtitle = 'Kalender Sekolah';
      } else if (attendance!.status == 'sakit') {
        attColor = const Color(0xFFE11D48);
        attIcon = Icons.local_hospital_outlined;
        attTitle = 'Sakit';
        attSubtitle = 'Ijin Terverifikasi';
      } else if (attendance!.status == 'izin') {
        attColor = const Color(0xFF2563EB);
        attIcon = Icons.assignment_turned_in_outlined;
        attTitle = 'Izin';
        attSubtitle = 'Ijin Terverifikasi';
      } else if (attendance!.status == 'alpa') {
        attColor = const Color(0xFFDC2626);
        attIcon = Icons.cancel_outlined;
        attTitle = 'Alpa';
        attSubtitle = 'Tidak Hadir';
      }
    }

    // Sholat Config
    Color sholatColor = const Color(0xFF64748B);
    IconData sholatIcon = Icons.mosque_outlined;
    String sholatTitle = 'Belum Ada Data';
    String sholatSubtitle = 'Sholat Dhuhur';

    if (sholat != null) {
      if (!sholat!.enabled) {
        sholatColor = const Color(0xFF94A3B8);
        sholatIcon = Icons.info_outline;
        sholatTitle = 'Non-Aktif';
      } else if (sholat!.status == 'berjamaah') {
        sholatColor = const Color(0xFF0D9488);
        sholatIcon = Icons.mosque_outlined;
        sholatTitle = 'Berjamaah';
      } else if (sholat!.status == 'masbuk') {
        sholatColor = const Color(0xFFD97706);
        sholatIcon = Icons.mosque_outlined;
        sholatTitle = 'Masbuk';
      } else if (sholat!.status == 'halangan') {
        sholatColor = const Color(0xFF7C3AED);
        sholatIcon = Icons.event_busy_outlined;
        sholatTitle = 'Halangan/Haid';
      } else if (sholat!.status == 'libur') {
        sholatColor = const Color(0xFF64748B);
        sholatIcon = Icons.weekend_outlined;
        sholatTitle = 'Hari Libur';
      } else {
        sholatColor = const Color(0xFF64748B);
        sholatIcon = Icons.radio_button_unchecked_rounded;
        sholatTitle = 'Belum Presensi';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Presensi Pagi
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: attColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(attIcon, color: attColor, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attSubtitle,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              attTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: attColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 12),
                // Status Sholat Dhuhur
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: sholatColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(sholatIcon, color: sholatColor, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sholatSubtitle,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              sholatTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: sholatColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
}

