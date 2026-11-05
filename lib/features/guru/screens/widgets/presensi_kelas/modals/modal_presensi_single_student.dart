import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/config/app_config.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'single/single_student_info_card.dart';
import 'single/single_student_status_selector.dart';

/// Modal Input Presensi Khusus 1 Siswa
class ModalPresensiSingleStudent extends StatefulWidget {
  final Dio dio;
  final Map<String, dynamic> student;
  final String todayDate;
  final String? academicYearId;
  final String? selectedClassId;
  final String selectedClassName;
  final String? identifier;
  final bool initialEnableCheckout;
  final VoidCallback onPresensiSaved;

  const ModalPresensiSingleStudent({
    super.key,
    required this.dio,
    required this.student,
    required this.todayDate,
    required this.academicYearId,
    required this.selectedClassId,
    required this.selectedClassName,
    required this.identifier,
    required this.initialEnableCheckout,
    required this.onPresensiSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required Dio dio,
    required Map<String, dynamic> student,
    required String todayDate,
    required String? academicYearId,
    required String? selectedClassId,
    required String selectedClassName,
    required String? identifier,
    required bool initialEnableCheckout,
    required VoidCallback onPresensiSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalPresensiSingleStudent(
        dio: dio,
        student: student,
        todayDate: todayDate,
        academicYearId: academicYearId,
        selectedClassId: selectedClassId,
        selectedClassName: selectedClassName,
        identifier: identifier,
        initialEnableCheckout: initialEnableCheckout,
        onPresensiSaved: onPresensiSaved,
      ),
    );
  }

  @override
  State<ModalPresensiSingleStudent> createState() =>
      _ModalPresensiSingleStudentState();
}

class _ModalPresensiSingleStudentState
    extends State<ModalPresensiSingleStudent> {
  late String _inputDate;
  late String _curStatus;
  late String _curPulang;
  late int _lateMinutes;
  bool _isLocked = false;
  bool _isHoliday = false;
  bool _isSaving = false;
  bool _isLoadingDate = true;
  late bool _enableCheckout;
  int _requestSeq = 0;

  late final TextEditingController _lateCtrl;
  late final FocusNode _lateFocusNode;

  @override
  void initState() {
    super.initState();
    final todayMap = widget.student['today'] is Map
        ? Map<String, dynamic>.from(widget.student['today'] as Map)
        : <String, dynamic>{};

    _inputDate = widget.todayDate.isNotEmpty
        ? widget.todayDate
        : DateTime.now().toIso8601String().substring(0, 10);
    _curStatus = todayMap['status']?.toString() ?? '';
    if (_curStatus == 'belum') _curStatus = 'hadir';
    _curPulang = todayMap['status_pulang']?.toString() ?? '';
    _lateMinutes = (todayMap['late_minutes'] as num?)?.toInt() ?? 0;
    _enableCheckout = widget.initialEnableCheckout;

    _lateCtrl = TextEditingController(text: '$_lateMinutes');
    _lateFocusNode = FocusNode();

    _syncStudentDateStatus(_inputDate);
  }

  @override
  void dispose() {
    _lateCtrl.dispose();
    _lateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _syncStudentDateStatus(String targetDate) async {
    final int currentSeq = ++_requestSeq;
    setState(() => _isLoadingDate = true);
    final studentId = widget.student['id']?.toString() ?? '';

    try {
      final res = await widget.dio.get(
        '${AppConfig.baseUrl}/guru/presensi/manual-input',
        queryParameters: {
          'academic_year_id': widget.academicYearId,
          'class_id': widget.selectedClassId,
          'date': targetDate,
        },
      );
      if (currentSeq != _requestSeq) return;
      if (res.statusCode == 200 && res.data['success'] == true) {
        final d = res.data['data'] as Map<String, dynamic>;
        final list = List<Map<String, dynamic>>.from(
          (d['students'] as List? ?? [])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e)),
        );
        final found = list.firstWhere(
          (item) => item['id']?.toString() == studentId,
          orElse: () => <String, dynamic>{},
        );
        if (mounted) {
          setState(() {
            _isHoliday = d['is_holiday'] == true;
            _enableCheckout = d['enable_checkout'] == true;
            if (found.isNotEmpty) {
              _isLocked = found['is_locked'] == true;
              final fetchedStatus = found['status']?.toString() ?? '';
              _curStatus = fetchedStatus.isEmpty ? 'hadir' : fetchedStatus;
              _curPulang = found['status_pulang']?.toString() ?? '';
              _lateMinutes = (found['late_minutes'] as num?)?.toInt() ?? 0;
              _lateCtrl.text = '$_lateMinutes';
            }
          });
        }
      }
    } catch (_) {}
    if (currentSeq == _requestSeq && mounted) {
      setState(() => _isLoadingDate = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final studentId = widget.student['id']?.toString() ?? '';
    final studentName = widget.student['name']?.toString() ?? '-';
    final isNonAtt = ['izin', 'sakit', 'alpa'].contains(_curStatus);

    try {
      final res = await widget.dio.post(
        '${AppConfig.baseUrl}/guru/presensi/manual-input',
        data: {
          'academic_year_id': widget.academicYearId,
          'class_id': widget.selectedClassId,
          'date': _inputDate,
          'students': [
            {
              'id': studentId,
              'status': _curStatus,
              'status_pulang': isNonAtt ? _curStatus : _curPulang,
              'late_minutes': _curStatus == 'telat' ? _lateMinutes : 0,
            },
          ],
          if (widget.identifier != null)
            'identifier': widget.identifier,
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.data['message']?.toString() ??
                  'Presensi $studentName berhasil disimpan!',
            ),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        widget.onPresensiSaved();
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Presensi $studentName berhasil disimpan!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        widget.onPresensiSaved();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.student['name']?.toString() ?? '-';
    final nisn = widget.student['nisn']?.toString() ?? '-';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Modal Khusus 1 Siswa
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Input Presensi Siswa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kartu Identitas Siswa yang Dipilih
                    SingleStudentInfoCard(
                      studentName: studentName,
                      selectedClassName: widget.selectedClassName,
                      nisn: nisn,
                    ),

                    const SizedBox(height: 12),

                    // Pilih Tanggal Presensi
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(_inputDate) ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          final formatted = picked.toIso8601String().substring(0, 10);
                          setState(() => _inputDate = formatted);
                          _syncStudentDateStatus(formatted);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.primary),
                                const SizedBox(width: 8),
                                const Text('Tanggal: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(
                                  _inputDate,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Ganti Tanggal',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isHoliday) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tanggal ini adalah hari libur sekolah.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    if (_isLoadingDate)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      SingleStudentStatusSelector(
                        curStatus: _curStatus,
                        curPulang: _curPulang,
                        isLocked: _isLocked,
                        enableCheckout: _enableCheckout,
                        lateCtrl: _lateCtrl,
                        lateFocusNode: _lateFocusNode,
                        onStatusDatangChanged: (v) {
                          setState(() {
                            _curStatus = v;
                            if (['izin', 'sakit', 'alpa'].contains(v)) {
                              _curPulang = v;
                            }
                            if (v == 'telat') {
                              if (_lateCtrl.text.isEmpty || _lateCtrl.text == '0') {
                                if (_lateMinutes > 0) {
                                  _lateCtrl.text = '$_lateMinutes';
                                }
                              }
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_lateFocusNode.canRequestFocus) {
                                  _lateFocusNode.requestFocus();
                                  _lateCtrl.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: _lateCtrl.text.length,
                                  );
                                }
                              });
                            }
                          });
                        },
                        onStatusPulangChanged: (v) => setState(() => _curPulang = v),
                        onLateMinutesChanged: (v) {
                          _lateMinutes = int.tryParse(v.trim()) ?? 0;
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Tombol Batal & Simpan Presensi Siswa
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
                            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isHoliday ? Colors.grey : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: (_isHoliday || _isSaving || _isLoadingDate) ? null : _handleSave,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.save_rounded, size: 18),
                            label: Text(
                              _isSaving ? 'Menyimpan...' : 'Simpan Presensi',
                              style: const TextStyle(fontWeight: FontWeight.w900),
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
      ),
    );
  }
}
