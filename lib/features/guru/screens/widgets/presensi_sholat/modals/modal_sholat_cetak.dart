import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/config/app_config.dart';
import '../../../../../../core/constants/app_colors.dart';

/// Modal Cetak Laporan Sholat Dhuhur (PDF Landscape Bulanan / Semester)
class ModalSholatCetak extends StatefulWidget {
  final String? academicYearId;
  final String? classId;
  final String? initialMonthYear;
  final String selectedDailyDate;
  final String? selectedKoordinatorId;
  final String? identifier;
  final List<Map<String, dynamic>> availableMonths;

  const ModalSholatCetak({
    super.key,
    required this.academicYearId,
    required this.classId,
    required this.initialMonthYear,
    required this.selectedDailyDate,
    required this.selectedKoordinatorId,
    required this.identifier,
    required this.availableMonths,
  });

  static Future<void> show(
    BuildContext context, {
    required String? academicYearId,
    required String? classId,
    required String? initialMonthYear,
    required String selectedDailyDate,
    required String? selectedKoordinatorId,
    required String? identifier,
    required List<Map<String, dynamic>> availableMonths,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalSholatCetak(
        academicYearId: academicYearId,
        classId: classId,
        initialMonthYear: initialMonthYear,
        selectedDailyDate: selectedDailyDate,
        selectedKoordinatorId: selectedKoordinatorId,
        identifier: identifier,
        availableMonths: availableMonths,
      ),
    );
  }

  @override
  State<ModalSholatCetak> createState() => _ModalSholatCetakState();
}

class _ModalSholatCetakState extends State<ModalSholatCetak> {
  static const Color _emeraldPrimary = Color(0xFF059669);

  late String _cetakJenis;
  late String _cetakMonthYear;
  late String _cetakSemester;

  @override
  void initState() {
    super.initState();
    _cetakJenis = 'bulanan';
    _cetakMonthYear = widget.initialMonthYear ??
        (widget.availableMonths.isNotEmpty
            ? widget.availableMonths.first['key'].toString()
            : '10-2026');
    _cetakSemester = DateTime.now().month >= 7 ? 'ganjil' : 'genap';
  }

  Future<void> _downloadExport() async {
    final params = <String, String>{
      if (widget.academicYearId != null)
        'academic_year_id': widget.academicYearId!,
      if (widget.classId != null) 'class_id': widget.classId!,
      'jenis': _cetakJenis,
      if (_cetakMonthYear.isNotEmpty) 'month_year': _cetakMonthYear,
      if (_cetakSemester.isNotEmpty) 'semester': _cetakSemester,
      if (widget.selectedDailyDate.isNotEmpty)
        'date': widget.selectedDailyDate,
      if (widget.selectedKoordinatorId != null)
        'koordinator_id': widget.selectedKoordinatorId!,
      if (widget.identifier != null && widget.identifier!.isNotEmpty)
        'identifier': widget.identifier!,
    };

    final uri = Uri.parse(
      '${AppConfig.baseUrl}/guru/sholat-dhuhur/export',
    ).replace(queryParameters: params);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Cetak Laporan Sholat Dhuhur (PDF Landscape)',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _cetakJenis = 'bulanan'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _cetakJenis == 'bulanan'
                          ? const Color(0xFFECFDF5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _cetakJenis == 'bulanan'
                            ? _emeraldPrimary
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Bulanan',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Matriks Harian 1-31',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _cetakJenis = 'semester'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _cetakJenis == 'semester'
                          ? const Color(0xFFECFDF5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _cetakJenis == 'semester'
                            ? _emeraldPrimary
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Semester',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Rekapitulasi 6 Bulan',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_cetakJenis == 'bulanan' && widget.availableMonths.isNotEmpty)
            DropdownButtonFormField<String>(
              initialValue: _cetakMonthYear,
              decoration: InputDecoration(
                labelText: 'Pilih Bulan Laporan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: widget.availableMonths
                  .map(
                    (m) => DropdownMenuItem(
                      value: m['key'].toString(),
                      child: Text(m['label'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _cetakMonthYear = v);
              },
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _cetakSemester,
              decoration: InputDecoration(
                labelText: 'Pilih Semester',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'ganjil',
                  child: Text('Semester Ganjil (Juli - Desember)'),
                ),
                DropdownMenuItem(
                  value: 'genap',
                  child: Text('Semester Genap (Januari - Juni)'),
                ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _cetakSemester = v);
              },
            ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _emeraldPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _downloadExport();
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text(
              'Unduh Laporan PDF',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

