import 'package:flutter/material.dart';

class SholatBulkControlBar extends StatelessWidget {
  final String modalDate;
  final VoidCallback onPickDate;
  final bool isHoliday;
  final String holidayDesc;
  final VoidCallback onSyncMorning;
  final String bulkStatus;
  final ValueChanged<String?> onBulkStatusChanged;

  static const Color _emeraldPrimary = Color(0xFF059669);

  const SholatBulkControlBar({
    super.key,
    required this.modalDate,
    required this.onPickDate,
    required this.isHoliday,
    required this.holidayDesc,
    required this.onSyncMorning,
    required this.bulkStatus,
    required this.onBulkStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFFECFDF5),
        border: Border(
          bottom: BorderSide(color: Color(0xFFA7F3D0)),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFA7F3D0),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: _emeraldPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          modalDate,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!isHoliday)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF3C7),
                    foregroundColor: const Color(0xFF92400E),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color(0xFFFDE68A),
                      ),
                    ),
                  ),
                  onPressed: onSyncMorning,
                  icon: const Icon(
                    Icons.sync_rounded,
                    size: 15,
                  ),
                  label: const Text(
                    'Sinkron Pagi (Izin/Alpa)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isHoliday)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Hari Libur Sholat: ${holidayDesc.isNotEmpty ? holidayDesc : 'Libur'} (Input Dinonaktifkan)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF991B1B),
                ),
              ),
            )
          else
            Row(
              children: [
                const Text(
                  'Set Massal:',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF6EE7B7),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: bulkStatus.isEmpty ? null : bulkStatus,
                        hint: const Text(
                          '-- Pilih Set Massal --',
                          style: TextStyle(fontSize: 11.5),
                        ),
                        isExpanded: true,
                        isDense: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'hadir',
                            child: Text(
                              '⚡ Hadir Berjamaah Semua',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'ijin',
                            child: Text(
                              'Izin Semua',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'tidak_hadir',
                            child: Text(
                              'Alpa Semua',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        onChanged: onBulkStatusChanged,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
