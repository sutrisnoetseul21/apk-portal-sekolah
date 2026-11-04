import 'package:flutter/material.dart';

/// Banner Hero Header Presensi Sholat Dhuhur
class SholatHeaderBanner extends StatelessWidget {
  final String selectedClassName;
  final String selectedClassAccessLabel;
  final int hadir;
  final int belum;
  final bool isSyncingMorning;
  final VoidCallback onSyncMorning;
  final VoidCallback onOpenCetak;
  final VoidCallback onOpenBulkInput;

  const SholatHeaderBanner({
    super.key,
    required this.selectedClassName,
    required this.selectedClassAccessLabel,
    required this.hadir,
    required this.belum,
    required this.isSyncingMorning,
    required this.onSyncMorning,
    required this.onOpenCetak,
    required this.onOpenBulkInput,
  });

  static const Color _emeraldPrimary = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _emeraldPrimary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Color(0xFF6EE7B7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Presensi Sholat Dhuhur',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (selectedClassName != '-')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(
                                alpha: 0.25,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF6EE7B7).withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            child: Text(
                              '$selectedClassName • $selectedClassAccessLabel',
                              style: const TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Pantau ibadah sholat dhuhur berjamaah siswa, catat siswi berhalangan/haid, dan sinkronkan izin/sakit/alpa dari presensi pagi.',
                      style: TextStyle(
                        color: Color(0xFFD1FAE5),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Indikator Pill Real-Time: Hadir Berjamaah & Belum Sholat
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hadir Berjamaah: $hadir',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: belum > 0
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Belum Sholat: $belum',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Aksi Cepat di Header: Sinkron Presensi Pagi, Cetak Laporan, Input Presensi Sholat
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tombol Sinkron Presensi Pagi (Khusus Izin/Sakit/Alpa)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B).withValues(
                    alpha: 0.2,
                  ),
                  foregroundColor: const Color(0xFFFEF3C7),
                  side: BorderSide(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSyncingMorning ? null : onSyncMorning,
                icon: isSyncingMorning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFEF3C7),
                        ),
                      )
                    : const Icon(Icons.sync_rounded, size: 16),
                label: Text(
                  isSyncingMorning
                      ? 'Menyinkronkan Presensi Pagi...'
                      : 'Sinkron Presensi Pagi (Izin / Sakit / Alpa)',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onOpenCetak,
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text(
                        'Cetak Laporan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF065F46),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onOpenBulkInput,
                      icon: const Icon(Icons.edit_note_rounded, size: 17),
                      label: const Text(
                        'Input Presensi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
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

