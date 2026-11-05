import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/config/app_config.dart';
import 'bulk/sholat_bulk_modal_header.dart';
import 'bulk/sholat_bulk_control_bar.dart';
import 'bulk/sholat_bulk_student_item.dart';
import 'bulk/sholat_bulk_bottom_bar.dart';

/// Modal Input Presensi Sholat Dhuhur Massal (1 Kelas)
class ModalSholatBulkInput extends StatefulWidget {
  final Dio dio;
  final String? academicYearId;
  final String? classId;
  final String selectedClassName;
  final String selectedDailyDate;
  final String? identifier;
  final VoidCallback onSaved;

  const ModalSholatBulkInput({
    super.key,
    required this.dio,
    required this.academicYearId,
    required this.classId,
    required this.selectedClassName,
    required this.selectedDailyDate,
    required this.identifier,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required Dio dio,
    required String? academicYearId,
    required String? classId,
    required String selectedClassName,
    required String selectedDailyDate,
    required String? identifier,
    required VoidCallback onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalSholatBulkInput(
        dio: dio,
        academicYearId: academicYearId,
        classId: classId,
        selectedClassName: selectedClassName,
        selectedDailyDate: selectedDailyDate,
        identifier: identifier,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<ModalSholatBulkInput> createState() => _ModalSholatBulkInputState();
}

class _ModalSholatBulkInputState extends State<ModalSholatBulkInput> {
  static const Color _emeraldPrimary = Color(0xFF059669);

  late String _modalDate;
  bool _isLoadingModal = true;
  bool _isSavingModal = false;
  bool _isHoliday = false;
  String _holidayDesc = '';
  String _bulkStatus = '';
  List<Map<String, dynamic>> _inputStudents = [];

  @override
  void initState() {
    super.initState();
    _modalDate = widget.selectedDailyDate.isNotEmpty
        ? widget.selectedDailyDate
        : DateTime.now().toIso8601String().substring(0, 10);
    _loadModalStudents();
  }

  Future<void> _loadModalStudents({bool pullMorning = false}) async {
    setState(() => _isLoadingModal = true);
    try {
      final response = await widget.dio.get(
        '${AppConfig.baseUrl}/guru/sholat-dhuhur/manual-input',
        queryParameters: {
          'academic_year_id': widget.academicYearId,
          'class_id': widget.classId,
          'date': _modalDate,
          if (pullMorning) 'pull_morning': 1,
          if (widget.identifier != null) 'identifier': widget.identifier,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final d = Map<String, dynamic>.from(response.data['data'] as Map);
        if (mounted) {
          setState(() {
            _isHoliday = d['is_holiday'] == true;
            _holidayDesc = d['holiday_desc']?.toString() ?? '';
            _inputStudents = List<Map<String, dynamic>>.from(
              (d['students'] as List? ?? [])
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            _isLoadingModal = false;
          });
          if (pullMorning) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response.data['message']?.toString() ??
                      'Data Izin/Sakit/Alpa presensi pagi berhasil ditarik.',
                ),
                backgroundColor: _emeraldPrimary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingModal = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSavingModal = true);
    try {
      final resp = await widget.dio.post(
        '${AppConfig.baseUrl}/guru/sholat-dhuhur/manual-input',
        data: {
          'academic_year_id': widget.academicYearId,
          'class_id': widget.classId,
          'date': _modalDate,
          'students': _inputStudents,
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resp.data?['message']?.toString() ??
                  'Presensi sholat kelas berhasil disimpan!',
            ),
            backgroundColor: _emeraldPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onSaved();
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isSavingModal = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data?['message']?.toString() ??
                  'Gagal menyimpan presensi.',
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickModalDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_modalDate) ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final dStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _modalDate = dStr);
      await _loadModalStudents();
    }
  }

  void _applyBulkStatus(String? val) {
    if (val == null) return;
    setState(() {
      _bulkStatus = val;
      for (final st in _inputStudents) {
        if (st['is_non_muslim'] == true) {
          continue;
        }
        st['status'] = val;
        st['is_halangan'] = false;
        if (st['keterangan'] == 'Halangan / Haid') {
          st['keterangan'] = '';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: Column(
            children: [
              SholatBulkModalHeader(
                selectedClassName: widget.selectedClassName,
                onClose: () => Navigator.pop(context),
              ),
              SholatBulkControlBar(
                modalDate: _modalDate,
                onPickDate: _pickModalDate,
                isHoliday: _isHoliday,
                holidayDesc: _holidayDesc,
                onSyncMorning: () => _loadModalStudents(pullMorning: true),
                bulkStatus: _bulkStatus,
                onBulkStatusChanged: _applyBulkStatus,
              ),
              Expanded(
                child: _isLoadingModal
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _emeraldPrimary,
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(14),
                        itemCount: _inputStudents.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, idx) {
                          final st = _inputStudents[idx];
                          return SholatBulkStudentItem(
                            student: st,
                            isHoliday: _isHoliday,
                            onStatusChanged: (val) {
                              if (val == null) return;
                              setState(() {
                                st['status'] = val;
                                if (val == 'haid') {
                                  st['is_halangan'] = true;
                                  st['keterangan'] = 'Halangan / Haid';
                                } else {
                                  st['is_halangan'] = false;
                                  if (st['keterangan'] == 'Halangan / Haid') {
                                    st['keterangan'] = '';
                                  }
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              SholatBulkBottomBar(
                isSavingModal: _isSavingModal,
                isHoliday: _isHoliday,
                onCancel: () => Navigator.pop(context),
                onSave: _handleSave,
              ),
            ],
          ),
        );
      },
    );
  }
}
