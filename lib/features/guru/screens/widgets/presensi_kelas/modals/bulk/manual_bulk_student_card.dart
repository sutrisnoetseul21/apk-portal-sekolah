import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class ManualBulkStudentCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool enableCheckout;
  final TextEditingController lateController;
  final ValueChanged<String?> onStatusDatangChanged;
  final ValueChanged<String?> onStatusPulangChanged;
  final ValueChanged<String> onLateMinutesChanged;

  const ManualBulkStudentCard({
    super.key,
    required this.item,
    required this.enableCheckout,
    required this.lateController,
    required this.onStatusDatangChanged,
    required this.onStatusPulangChanged,
    required this.onLateMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = item['is_locked'] == true;
    final curStatus = item['status']?.toString() ?? '';
    final curPulang = item['status_pulang']?.toString() ?? '';
    final isNonAtt = ['izin', 'sakit', 'alpa'].contains(curStatus);
    final sId = item['id']?.toString() ?? '';

    return Container(
      key: ValueKey('manual_card_$sId'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name']?.toString() ?? '-',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Kolom Status Datang
              Expanded(
                child: isLocked
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                          ),
                        ),
                        child: const Text(
                          '🔒 Sudah Scan Kiosk',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: curStatus.isEmpty ? null : curStatus,
                            hint: const Text(
                              'Datang: -- Pilih --',
                              style: TextStyle(fontSize: 11.5),
                            ),
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'hadir', child: Text('Hadir')),
                              DropdownMenuItem(value: 'telat', child: Text('Terlambat')),
                              DropdownMenuItem(value: 'izin', child: Text('Izin')),
                              DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                              DropdownMenuItem(value: 'alpa', child: Text('Alpa')),
                            ],
                            onChanged: onStatusDatangChanged,
                          ),
                        ),
                      ),
              ),
              if (enableCheckout) ...[
                const SizedBox(width: 8),
                // Kolom Status Pulang
                Expanded(
                  child: isNonAtt
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            curStatus.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: ['pulang', 'izin', 'sakit', 'alpa'].contains(curPulang)
                                  ? curPulang
                                  : null,
                              hint: const Text(
                                'Pulang: -- Pilih --',
                                style: TextStyle(fontSize: 11.5),
                              ),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'pulang', child: Text('Pulang')),
                                DropdownMenuItem(value: 'izin', child: Text('Izin')),
                                DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                                DropdownMenuItem(value: 'alpa', child: Text('Alpa')),
                              ],
                              onChanged: onStatusPulangChanged,
                            ),
                          ),
                        ),
                ),
              ],
            ],
          ),

          // Input Menit Terlambat jika status == 'telat'
          if (curStatus == 'telat' && !isLocked) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Keterlambatan (Menit): ',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: TextField(
                    key: ValueKey('late_ctrl_$sId'),
                    controller: lateController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    scrollPadding: const EdgeInsets.only(bottom: 90),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      suffixText: 'mnt',
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFFFFBEB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: onLateMinutesChanged,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
