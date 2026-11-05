import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'step1/step1_header_and_teacher.dart';
import 'step1/step1_mapel_rombel_selector.dart';
import 'step1/step1_jp_calculator_strip.dart';

/// Langkah 1 Form Jurnal Mengajar: Parameter Pembelajaran & Jadwal Waktu
class Step1ParameterKbmCard extends StatelessWidget {
  final String teacherName;
  final String tanggal;
  final String tanggalFormatted;
  final VoidCallback onPickTanggalKbm;
  final bool isSingleMapel;
  final List<Map<String, dynamic>> availableMapels;
  final int? selectedMapelId;
  final ValueChanged<int?> onMapelChanged;
  final List<Map<String, dynamic>> classesForMapel;
  final String? selectedClassId;
  final ValueChanged<String?> onClassChanged;
  final int jamMulai;
  final int durasiJp;
  final int durasiMenit;
  final String jamKeLabel;
  final ValueChanged<int> onJamMulaiChanged;
  final ValueChanged<int> onDurasiJpChanged;

  const Step1ParameterKbmCard({
    super.key,
    required this.teacherName,
    required this.tanggal,
    required this.tanggalFormatted,
    required this.onPickTanggalKbm,
    required this.isSingleMapel,
    required this.availableMapels,
    required this.selectedMapelId,
    required this.onMapelChanged,
    required this.classesForMapel,
    required this.selectedClassId,
    required this.onClassChanged,
    required this.jamMulai,
    required this.durasiJp,
    required this.durasiMenit,
    required this.jamKeLabel,
    required this.onJamMulaiChanged,
    required this.onDurasiJpChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Step1HeaderAndTeacher(
            teacherName: teacherName,
            tanggal: tanggal,
            tanggalFormatted: tanggalFormatted,
            onPickTanggalKbm: onPickTanggalKbm,
          ),
          const SizedBox(height: 14),
          Step1MapelRombelSelector(
            isSingleMapel: isSingleMapel,
            availableMapels: availableMapels,
            selectedMapelId: selectedMapelId,
            onMapelChanged: onMapelChanged,
            classesForMapel: classesForMapel,
            selectedClassId: selectedClassId,
            onClassChanged: onClassChanged,
          ),
          const SizedBox(height: 18),
          Step1JpCalculatorStrip(
            jamMulai: jamMulai,
            durasiJp: durasiJp,
            durasiMenit: durasiMenit,
            jamKeLabel: jamKeLabel,
            onJamMulaiChanged: onJamMulaiChanged,
            onDurasiJpChanged: onDurasiJpChanged,
          ),
        ],
      ),
    );
  }
}
