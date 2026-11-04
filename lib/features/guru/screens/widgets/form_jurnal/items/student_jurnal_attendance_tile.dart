import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Item Baris Presensi Siswa di Sesi KBM Jurnal Mengajar
class StudentJurnalAttendanceTile extends StatelessWidget {
  final int realIndex;
  final Map<String, dynamic> item;
  final int displayNo;
  final TextEditingController? noteController;
  final void Function(int realIndex, String status) onSetStatusJurnal;
  final void Function(int realIndex, String? manualStatus) onSetManualStatusBelumAbsen;

  const StudentJurnalAttendanceTile({
    super.key,
    required this.realIndex,
    required this.item,
    required this.displayNo,
    required this.noteController,
    required this.onSetStatusJurnal,
    required this.onSetManualStatusBelumAbsen,
  });

  static const Color _indigoPrimary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    final name = '${item['name'] ?? '-'}';
    final nis = '${item['nis'] ?? '-'}';
    final statusGerbang = '${item['status_gerbang'] ?? 'belum_absen'}';
    final statusJurnal = '${item['status_jurnal'] ?? 'hadir'}';
    final isLocked = item['is_locked'] == true;
    final manualStatus = item['manual_status'] as String?;

    final initials = name.trim().isNotEmpty
        ? name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : 'S';

    // Badge Status Gerbang Pagi
    String gateLabel = '⚪ Belum Scan';
    Color gateBg = const Color(0xFFF1F5F9);
    Color gateFg = const Color(0xFF475569);
    if (statusGerbang == 'hadir') {
      gateLabel = '✓ Tepat Waktu';
      gateBg = const Color(0xFFECFDF5);
      gateFg = const Color(0xFF065F46);
    } else if (statusGerbang == 'telat') {
      gateLabel = '⏰ Telat di Gerbang';
      gateBg = const Color(0xFFFFFBEB);
      gateFg = const Color(0xFF92400E);
    } else if (statusGerbang == 'izin') {
      gateLabel = '✉️ Izin Resmi';
      gateBg = const Color(0xFFEFF6FF);
      gateFg = const Color(0xFF1E40AF);
    } else if (statusGerbang == 'sakit') {
      gateLabel = '🩺 Sakit';
      gateBg = const Color(0xFFF5F3FF);
      gateFg = const Color(0xFF5B21B6);
    } else if (statusGerbang == 'alpa') {
      gateLabel = '✕ Alpa';
      gateBg = const Color(0xFFFFF1F2);
      gateFg = const Color(0xFF9F1239);
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isLocked
            ? const Color(0xFFFFF1F2).withValues(alpha: 0.45)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? const Color(0xFFFECDD3)
              : (statusJurnal == 'tidak_mengikuti'
                  ? const Color(0xFFFDA4AF)
                  : AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Nomor + Initials Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _indigoPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _indigoPrimary.withValues(alpha: 0.2),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _indigoPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$displayNo. $name',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIS/NISN: $nis',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: gateBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: gateFg.withValues(alpha: 0.2)),
                ),
                child: Text(
                  gateLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: gateFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Baris Aksi Kehadiran Jam KBM
          if (isLocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 15,
                    color: Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tidak Mengikuti (Terkunci • Tercatat ${statusGerbang.toUpperCase()} di gerbang pagi)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (statusGerbang == 'belum_absen')
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: manualStatus == null
                    ? const Color(0xFFF8FAFC)
                    : (manualStatus == 'hadir'
                        ? const Color(0xFFECFDF5)
                        : manualStatus == 'telat'
                            ? const Color(0xFFFFFBEB)
                            : manualStatus == 'izin'
                                ? const Color(0xFFEFF6FF)
                                : manualStatus == 'sakit'
                                    ? const Color(0xFFF5F3FF)
                                    : const Color(0xFFFFF1F2)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: manualStatus == null
                      ? const Color(0xFFE2E8F0)
                      : (manualStatus == 'hadir'
                          ? const Color(0xFFA7F3D0)
                          : manualStatus == 'telat'
                              ? const Color(0xFFFDE68A)
                              : manualStatus == 'izin'
                                  ? const Color(0xFFBFDBFE)
                                  : manualStatus == 'sakit'
                                      ? const Color(0xFFDDD6FE)
                                      : const Color(0xFFFECDD3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PILIH STATUS KEHADIRAN (BELUM SCAN PAGI):',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (manualStatus != null)
                        InkWell(
                          onTap: () => onSetManualStatusBelumAbsen(realIndex, null),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.refresh_rounded,
                                    size: 12, color: Color(0xFF64748B)),
                                SizedBox(width: 2),
                                Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 5 Pilihan Status Bebas untuk Guru
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildManualStatusChip(
                        label: 'Hadir',
                        value: 'hadir',
                        currentValue: manualStatus,
                        activeBg: const Color(0xFF059669),
                        onTap: () =>
                            onSetManualStatusBelumAbsen(realIndex, 'hadir'),
                      ),
                      _buildManualStatusChip(
                        label: 'Telat',
                        value: 'telat',
                        currentValue: manualStatus,
                        activeBg: const Color(0xFFD97706),
                        onTap: () =>
                            onSetManualStatusBelumAbsen(realIndex, 'telat'),
                      ),
                      _buildManualStatusChip(
                        label: 'Izin',
                        value: 'izin',
                        currentValue: manualStatus,
                        activeBg: const Color(0xFF2563EB),
                        onTap: () =>
                            onSetManualStatusBelumAbsen(realIndex, 'izin'),
                      ),
                      _buildManualStatusChip(
                        label: 'Sakit',
                        value: 'sakit',
                        currentValue: manualStatus,
                        activeBg: const Color(0xFF7C3AED),
                        onTap: () =>
                            onSetManualStatusBelumAbsen(realIndex, 'sakit'),
                      ),
                      _buildManualStatusChip(
                        label: 'Alpa',
                        value: 'alpa',
                        currentValue: manualStatus,
                        activeBg: const Color(0xFFDC2626),
                        onTap: () =>
                            onSetManualStatusBelumAbsen(realIndex, 'alpa'),
                      ),
                    ],
                  ),

                  // Feedback / Catatan Konfirmasi Pilihan
                  const SizedBox(height: 8),
                  if (manualStatus == null)
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Siswa belum memiliki status. Klik salah satu status di atas.',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (manualStatus == 'hadir')
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13,
                          color: Color(0xFF059669),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Dicatat HADIR di gerbang & Mengikuti Jam KBM',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (manualStatus == 'telat')
                    const Row(
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          size: 13,
                          color: Color(0xFFD97706),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Dicatat TELAT di gerbang & Mengikuti Jam KBM',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.cancel_rounded,
                          size: 13,
                          color: manualStatus == 'izin'
                              ? const Color(0xFF2563EB)
                              : manualStatus == 'sakit'
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFFDC2626),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Dicatat ${manualStatus.toUpperCase()} di presensi sekolah & Tidak Mengikuti KBM',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: manualStatus == 'izin'
                                  ? const Color(0xFF1E40AF)
                                  : manualStatus == 'sakit'
                                      ? const Color(0xFF5B21B6)
                                      : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            )
          else
            Row(
              children: [
                const Text(
                  'Kehadiran KBM:',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => onSetStatusJurnal(realIndex, 'hadir'),
                            borderRadius: BorderRadius.circular(9),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: statusJurnal == 'hadir'
                                    ? const Color(0xFF059669)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                '✓ Hadir',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: statusJurnal == 'hadir'
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => onSetStatusJurnal(
                              realIndex,
                              'tidak_mengikuti',
                            ),
                            borderRadius: BorderRadius.circular(9),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: statusJurnal == 'tidak_mengikuti'
                                    ? const Color(0xFFE11D48)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                '✕ Tidak Hadir',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: statusJurnal == 'tidak_mengikuti'
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          // Input Catatan / Alasan jika tidak terkunci
          if (!isLocked &&
              (statusJurnal == 'tidak_mengikuti' ||
                  (noteController?.text.isNotEmpty ?? false))) ...[
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: statusJurnal == 'tidak_mengikuti'
                    ? 'Alasan tidak mengikuti KBM (misal: Izin UKS, Bolos)...'
                    : 'Catatan khusus siswa (opsional)...',
                hintStyle: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: statusJurnal == 'tidak_mengikuti'
                    ? const Color(0xFFFFF1F2)
                    : const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: statusJurnal == 'tidak_mengikuti'
                        ? const Color(0xFFFDA4AF)
                        : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: statusJurnal == 'tidak_mengikuti'
                        ? const Color(0xFFFDA4AF)
                        : AppColors.border,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualStatusChip({
    required String label,
    required String value,
    required String? currentValue,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    final isSelected = currentValue == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeBg : const Color(0xFFCBD5E1),
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBg.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 13,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

