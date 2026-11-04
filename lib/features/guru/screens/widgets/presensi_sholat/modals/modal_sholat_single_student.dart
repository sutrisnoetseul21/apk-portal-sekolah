import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/config/app_config.dart';
import '../../../../../../core/constants/app_colors.dart';

/// Modal Input Presensi Sholat Dhuhur Khusus 1 Siswa
class ModalSholatSingleStudent extends StatefulWidget {
  final Dio dio;
  final Map<String, dynamic> student;
  final String selectedClassName;
  final String? academicYearId;
  final String? classId;
  final String selectedDailyDate;
  final String todayDateLabel;
  final VoidCallback onSaved;

  const ModalSholatSingleStudent({
    super.key,
    required this.dio,
    required this.student,
    required this.selectedClassName,
    required this.academicYearId,
    required this.classId,
    required this.selectedDailyDate,
    required this.todayDateLabel,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required Dio dio,
    required Map<String, dynamic> student,
    required String selectedClassName,
    required String? academicYearId,
    required String? classId,
    required String selectedDailyDate,
    required String todayDateLabel,
    required VoidCallback onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalSholatSingleStudent(
        dio: dio,
        student: student,
        selectedClassName: selectedClassName,
        academicYearId: academicYearId,
        classId: classId,
        selectedDailyDate: selectedDailyDate,
        todayDateLabel: todayDateLabel,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<ModalSholatSingleStudent> createState() =>
      _ModalSholatSingleStudentState();
}

class _ModalSholatSingleStudentState extends State<ModalSholatSingleStudent> {
  static const Color _emeraldPrimary = Color(0xFF059669);
  static const Color _tealDark = Color(0xFF0F766E);

  late String _selectedStatus;
  late final TextEditingController _noteCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final today = widget.student['today'] is Map
        ? Map<String, dynamic>.from(widget.student['today'] as Map)
        : <String, dynamic>{};

    _selectedStatus =
        (today['ui_status'] ?? today['status'] ?? 'hadir').toString();
    if (_selectedStatus == 'belum' || _selectedStatus.isEmpty) {
      _selectedStatus = 'hadir';
    }
    _noteCtrl = TextEditingController(
      text: today['keterangan']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final studentId = widget.student['id']?.toString() ?? '';
    final studentName = widget.student['name']?.toString() ?? '-';

    try {
      final resp = await widget.dio.post(
        '${AppConfig.baseUrl}/guru/sholat-dhuhur/manual-input',
        data: {
          'academic_year_id': widget.academicYearId,
          'class_id': widget.classId,
          'date': widget.selectedDailyDate.isNotEmpty
              ? widget.selectedDailyDate
              : DateTime.now().toIso8601String().substring(0, 10),
          'students': [
            {
              'id': studentId,
              'status': _selectedStatus,
              'is_halangan': _selectedStatus == 'haid',
              'keterangan': _noteCtrl.text.trim(),
            },
          ],
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resp.data?['message']?.toString() ??
                  'Presensi sholat $studentName berhasil disimpan!',
            ),
            backgroundColor: _emeraldPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onSaved();
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data?['message']?.toString() ??
                  'Gagal menyimpan presensi sholat.',
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildChoiceChip({
    required String value,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedStatus == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = value;
          if (value == 'haid' && _noteCtrl.text.trim().isEmpty) {
            _noteCtrl.text = 'Halangan / Haid';
          } else if (value != 'haid' &&
              _noteCtrl.text.trim() == 'Halangan / Haid') {
            _noteCtrl.clear();
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.12)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight:
                      isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected ? activeColor : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: activeColor,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.student['name']?.toString() ?? '-';
    final studentNisn = widget.student['nisn']?.toString() ?? '-';
    final gender = widget.student['gender']?.toString() ?? 'L';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Emerald-Teal
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_emeraldPrimary, _tealDark],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.mosque_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Input Presensi Sholat Siswa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Tanggal: ${widget.todayDateLabel}',
                          style: const TextStyle(
                            color: Color(0xFFD1FAE5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Identitas Siswa
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFD1FAE5),
                          foregroundColor: const Color(0xFF065F46),
                          child: Text(
                            studentName.isNotEmpty
                                ? studentName[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Kelas ${widget.selectedClassName} • NISN: $studentNisn',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'PILIH STATUS SHOLAT DHUHUR',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildChoiceChip(
                    value: 'hadir',
                    label: 'Hadir Berjamaah',
                    icon: Icons.check_circle_outline_rounded,
                    activeColor: _emeraldPrimary,
                  ),
                  const SizedBox(height: 8),
                  _buildChoiceChip(
                    value: 'ijin',
                    label: 'Izin / Sakit',
                    icon: Icons.info_outline_rounded,
                    activeColor: const Color(0xFF2563EB),
                  ),
                  if (gender == 'P') ...[
                    const SizedBox(height: 8),
                    _buildChoiceChip(
                      value: 'haid',
                      label: '🩸 Halangan / Haid (Siswi Perempuan)',
                      icon: Icons.favorite_border_rounded,
                      activeColor: const Color(0xFFDB2777),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildChoiceChip(
                    value: 'tidak_hadir',
                    label: 'Tidak Hadir / Alpa',
                    icon: Icons.cancel_outlined,
                    activeColor: const Color(0xFFE11D48),
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    'CATATAN / KETERANGAN (OPSIONAL)',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      hintText:
                          'Contoh: Halangan / Haid, Sakit di UKS, Izin pulang...',
                      hintStyle: const TextStyle(fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _emeraldPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSaving ? null : _handleSave,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.save_outlined,
                                  size: 17,
                                ),
                          label: Text(
                            _isSaving ? 'Menyimpan...' : 'Simpan Presensi',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

