import 'package:flutter/material.dart';
import 'cetak/cetak_jurnal_modal_header.dart';
import 'cetak/cetak_jurnal_periode_selector.dart';
import 'cetak/cetak_jurnal_target_selector.dart';
import 'cetak/cetak_jurnal_action_buttons.dart';

/// Modal Bottom Sheet Cetak Rekap Laporan Jurnal Mengajar
class DialogCetakJurnalPeriode {
  static void show(
    BuildContext context, {
    required String currentMonthYear,
    required List<Map<String, dynamic>> availableMonthsList,
    required int? currentMapelId,
    required List<Map<String, dynamic>> availableMapels,
    required String? currentClassId,
    required List<Map<String, dynamic>> allTeachingClasses,
    required String currentTeacherName,
    required void Function({
      required String format,
      required String jenis,
      required String monthYear,
      required String semester,
      int? mapelId,
      String? classId,
    }) onExport,
  }) {
    String cetakJenis = 'bulanan'; // bulanan | semester | tahunan
    String cetakBulanYear = currentMonthYear.isNotEmpty
        ? currentMonthYear
        : (availableMonthsList.isNotEmpty
            ? '${availableMonthsList.first['key']}'
            : '');
    String cetakSemester = DateTime.now().month >= 7 ? 'ganjil' : 'genap';
    int? cetakMapelId = currentMapelId ??
        (availableMapels.length == 1
            ? int.tryParse('${availableMapels.first['id']}')
            : null);
    String? cetakClassId = currentClassId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final classesForModalMapel = <Map<String, dynamic>>[];
            if (cetakMapelId != null) {
              final seen = <String>{};
              for (final c in allTeachingClasses) {
                final mId = int.tryParse('${c['mata_pelajaran_id']}');
                final cId = '${c['id']}';
                if (mId == cetakMapelId && !seen.contains(cId)) {
                  seen.add(cId);
                  classesForModalMapel.add(c);
                }
              }
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CetakJurnalModalHeader(
                      onClose: () => Navigator.of(ctx).pop(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CetakJurnalPeriodeSelector(
                            cetakJenis: cetakJenis,
                            onJenisChanged: (val) =>
                                setModalState(() => cetakJenis = val),
                            availableMonthsList: availableMonthsList,
                            cetakBulanYear: cetakBulanYear,
                            onBulanYearChanged: (val) =>
                                setModalState(() => cetakBulanYear = val),
                            cetakSemester: cetakSemester,
                            onSemesterChanged: (val) =>
                                setModalState(() => cetakSemester = val),
                          ),
                          const SizedBox(height: 16),
                          CetakJurnalTargetSelector(
                            currentTeacherName: currentTeacherName,
                            availableMapels: availableMapels,
                            cetakMapelId: cetakMapelId,
                            onMapelChanged: (val) {
                              setModalState(() {
                                cetakMapelId = val;
                                cetakClassId = null;
                              });
                            },
                            classesForModalMapel: classesForModalMapel,
                            cetakClassId: cetakClassId,
                            onClassChanged: (val) =>
                                setModalState(() => cetakClassId = val),
                          ),
                          const SizedBox(height: 20),
                          CetakJurnalActionButtons(
                            onExportExcel: () {
                              Navigator.of(ctx).pop();
                              onExport(
                                format: 'excel',
                                jenis: cetakJenis,
                                monthYear: cetakBulanYear,
                                semester: cetakSemester,
                                mapelId: cetakMapelId,
                                classId: cetakClassId,
                              );
                            },
                            onExportPdf: () {
                              Navigator.of(ctx).pop();
                              onExport(
                                format: 'pdf',
                                jenis: cetakJenis,
                                monthYear: cetakBulanYear,
                                semester: cetakSemester,
                                mapelId: cetakMapelId,
                                classId: cetakClassId,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
