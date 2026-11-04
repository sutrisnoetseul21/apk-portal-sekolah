import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/config/app_config.dart';
import '../../../../../../core/constants/app_colors.dart';

/// Modal Cetak Laporan Presensi (Bulanan, Semester, Tahunan - PDF & Excel)
class ModalPresensiCetak extends StatefulWidget {
  final String? academicYearId;
  final String? classId;
  final String? initialMonthYear;
  final List<Map<String, dynamic>> availableMonths;

  const ModalPresensiCetak({
    super.key,
    required this.academicYearId,
    required this.classId,
    required this.initialMonthYear,
    required this.availableMonths,
  });

  static Future<void> show(
    BuildContext context, {
    required String? academicYearId,
    required String? classId,
    required String? initialMonthYear,
    required List<Map<String, dynamic>> availableMonths,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalPresensiCetak(
        academicYearId: academicYearId,
        classId: classId,
        initialMonthYear: initialMonthYear,
        availableMonths: availableMonths,
      ),
    );
  }

  @override
  State<ModalPresensiCetak> createState() => _ModalPresensiCetakState();
}

class _ModalPresensiCetakState extends State<ModalPresensiCetak> {
  late String _cetakJenis;
  late String _cetakBulanYear;
  late String _cetakSemester;

  @override
  void initState() {
    super.initState();
    _cetakJenis = 'bulanan';
    _cetakBulanYear = widget.initialMonthYear ?? '';
    _cetakSemester = DateTime.now().month >= 7 ? 'ganjil' : 'genap';
  }

  Future<void> _triggerExport(String format) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/guru/presensi/export').replace(
      queryParameters: {
        'academic_year_id': widget.academicYearId ?? '',
        'class_id': widget.classId ?? '',
        'jenis': _cetakJenis,
        'month_year': _cetakBulanYear,
        'semester': _cetakSemester,
        'format': format,
      },
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.print_rounded, color: Color(0xFF059669)),
                    SizedBox(width: 10),
                    Text(
                      'Cetak Laporan Presensi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'PILIH JENIS LAPORAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildJenisRadioCard(
                  title: 'Bulanan',
                  subtitle: 'Bulan spesifik',
                  selected: _cetakJenis == 'bulanan',
                  onTap: () => setState(() => _cetakJenis = 'bulanan'),
                ),
                const SizedBox(width: 8),
                _buildJenisRadioCard(
                  title: 'Semester',
                  subtitle: 'Per semester',
                  selected: _cetakJenis == 'semester',
                  onTap: () => setState(() => _cetakJenis = 'semester'),
                ),
                const SizedBox(width: 8),
                _buildJenisRadioCard(
                  title: 'Tahunan',
                  subtitle: '1 Tahun penuh',
                  selected: _cetakJenis == 'tahunan',
                  onTap: () => setState(() => _cetakJenis = 'tahunan'),
                ),
              ],
            ),
            if (_cetakJenis == 'bulanan' &&
                widget.availableMonths.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'PILIH BULAN KEHADIRAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _cetakBulanYear,
                    isExpanded: true,
                    items: widget.availableMonths
                        .map(
                          (m) => DropdownMenuItem<String>(
                            value: m['key']?.toString(),
                            child: Text(m['label']?.toString() ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _cetakBulanYear = v);
                      }
                    },
                  ),
                ),
              ),
            ],
            if (_cetakJenis == 'semester') ...[
              const SizedBox(height: 14),
              const Text(
                'PILIH SEMESTER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildJenisRadioCard(
                    title: 'Semester Ganjil',
                    subtitle: 'Juli - Desember',
                    selected: _cetakSemester == 'ganjil',
                    onTap: () => setState(() => _cetakSemester = 'ganjil'),
                  ),
                  const SizedBox(width: 8),
                  _buildJenisRadioCard(
                    title: 'Semester Genap',
                    subtitle: 'Januari - Juni',
                    selected: _cetakSemester == 'genap',
                    onTap: () => setState(() => _cetakSemester = 'genap'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _triggerExport('excel'),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text(
                      'Excel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _triggerExport('pdf'),
                    icon: const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 16,
                    ),
                    label: const Text(
                      'PDF',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJenisRadioCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFECFDF5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF10B981) : AppColors.border,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: selected
                      ? const Color(0xFF065F46)
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

