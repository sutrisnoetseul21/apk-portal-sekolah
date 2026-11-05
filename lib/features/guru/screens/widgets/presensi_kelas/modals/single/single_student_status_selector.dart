import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'single_status_choice_chip.dart';

class SingleStudentStatusSelector extends StatelessWidget {
  final String curStatus;
  final String curPulang;
  final bool isLocked;
  final bool enableCheckout;
  final TextEditingController lateCtrl;
  final FocusNode lateFocusNode;
  final ValueChanged<String> onStatusDatangChanged;
  final ValueChanged<String> onStatusPulangChanged;
  final ValueChanged<String> onLateMinutesChanged;

  const SingleStudentStatusSelector({
    super.key,
    required this.curStatus,
    required this.curPulang,
    required this.isLocked,
    required this.enableCheckout,
    required this.lateCtrl,
    required this.lateFocusNode,
    required this.onStatusDatangChanged,
    required this.onStatusPulangChanged,
    required this.onLateMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNonAtt = ['izin', 'sakit', 'alpa'].contains(curStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status Kehadiran Datang
        const Text(
          'STATUS KEHADIRAN (DATANG)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        if (isLocked)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, size: 16, color: Color(0xFFB45309)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sudah Scan Kiosk (Status datang terkunci otomatis)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SingleStatusChoiceChip(
                label: 'Hadir',
                value: 'hadir',
                selectedValue: curStatus,
                activeColor: const Color(0xFF059669),
                icon: Icons.check_circle_outline_rounded,
                onTap: () {
                  lateFocusNode.unfocus();
                  onStatusDatangChanged('hadir');
                },
              ),
              SingleStatusChoiceChip(
                label: 'Terlambat',
                value: 'telat',
                selectedValue: curStatus,
                activeColor: const Color(0xFFD97706),
                icon: Icons.access_time_rounded,
                onTap: () => onStatusDatangChanged('telat'),
              ),
              SingleStatusChoiceChip(
                label: 'Izin',
                value: 'izin',
                selectedValue: curStatus,
                activeColor: const Color(0xFF2563EB),
                icon: Icons.assignment_outlined,
                onTap: () {
                  lateFocusNode.unfocus();
                  onStatusDatangChanged('izin');
                },
              ),
              SingleStatusChoiceChip(
                label: 'Sakit',
                value: 'sakit',
                selectedValue: curStatus,
                activeColor: const Color(0xFF7C3AED),
                icon: Icons.medical_services_outlined,
                onTap: () {
                  lateFocusNode.unfocus();
                  onStatusDatangChanged('sakit');
                },
              ),
              SingleStatusChoiceChip(
                label: 'Alpa',
                value: 'alpa',
                selectedValue: curStatus,
                activeColor: const Color(0xFFDC2626),
                icon: Icons.cancel_outlined,
                onTap: () {
                  lateFocusNode.unfocus();
                  onStatusDatangChanged('alpa');
                },
              ),
            ],
          ),

        // Input Menit Terlambat jika status == 'telat'
        if (curStatus == 'telat' && !isLocked) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: Color(0xFFB45309),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Durasi Terlambat (Menit):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: TextField(
                    key: const ValueKey('single_student_late_input'),
                    controller: lateCtrl,
                    focusNode: lateFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    scrollPadding: const EdgeInsets.only(bottom: 90),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      suffixText: 'mnt',
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: onLateMinutesChanged,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Status Pulang jika fitur checkout aktif
        if (enableCheckout) ...[
          const SizedBox(height: 16),
          const Text(
            'STATUS PULANG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          if (isNonAtt)
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Otomatis mengikuti status datang: ${curStatus.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SingleStatusChoiceChip(
                  label: 'Belum Pulang',
                  value: '',
                  selectedValue: curPulang,
                  activeColor: const Color(0xFF64748B),
                  icon: Icons.hourglass_empty_rounded,
                  onTap: () => onStatusPulangChanged(''),
                ),
                SingleStatusChoiceChip(
                  label: 'Pulang',
                  value: 'pulang',
                  selectedValue: curPulang,
                  activeColor: const Color(0xFF059669),
                  icon: Icons.logout_rounded,
                  onTap: () => onStatusPulangChanged('pulang'),
                ),
                SingleStatusChoiceChip(
                  label: 'Izin Pulang',
                  value: 'izin',
                  selectedValue: curPulang,
                  activeColor: const Color(0xFF2563EB),
                  icon: Icons.assignment_return_outlined,
                  onTap: () => onStatusPulangChanged('izin'),
                ),
                SingleStatusChoiceChip(
                  label: 'Sakit',
                  value: 'sakit',
                  selectedValue: curPulang,
                  activeColor: const Color(0xFF7C3AED),
                  icon: Icons.medical_services_outlined,
                  onTap: () => onStatusPulangChanged('sakit'),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
