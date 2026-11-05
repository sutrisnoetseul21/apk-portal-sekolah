import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/config/app_config.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'bulk/manual_bulk_bottom_bar.dart';
import 'bulk/manual_bulk_date_picker_card.dart';
import 'bulk/manual_bulk_quick_setter_bar.dart';
import 'bulk/manual_bulk_student_card.dart';

/// Modal Input Presensi Manual Massal Semua Siswa
class ModalPresensiManualBulk extends StatefulWidget {
  final Dio dio;
  final List<Map<String, dynamic>> students;
  final String todayDate;
  final String? academicYearId;
  final String? selectedClassId;
  final String? identifier;
  final bool initialEnableCheckout;
  final VoidCallback onPresensiSaved;

  const ModalPresensiManualBulk({
    super.key,
    required this.dio,
    required this.students,
    required this.todayDate,
    required this.academicYearId,
    required this.selectedClassId,
    required this.identifier,
    required this.initialEnableCheckout,
    required this.onPresensiSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required Dio dio,
    required List<Map<String, dynamic>> students,
    required String todayDate,
    required String? academicYearId,
    required String? selectedClassId,
    required String? identifier,
    required bool initialEnableCheckout,
    required VoidCallback onPresensiSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalPresensiManualBulk(
        dio: dio,
        students: students,
        todayDate: todayDate,
        academicYearId: academicYearId,
        selectedClassId: selectedClassId,
        identifier: identifier,
        initialEnableCheckout: initialEnableCheckout,
        onPresensiSaved: onPresensiSaved,
      ),
    );
  }

  @override
  State<ModalPresensiManualBulk> createState() =>
      _ModalPresensiManualBulkState();
}

class _ModalPresensiManualBulkState extends State<ModalPresensiManualBulk> {
  late String _inputDate;
  bool _isHoliday = false;
  bool _isSaving = false;
  bool _isLoadingModal = true;
  String _bulkDatang = '';
  String _bulkPulang = '';
  late bool _enableCheckout;
  int _requestSeq = 0;

  final Map<String, TextEditingController> _lateControllers = {};
  late List<Map<String, dynamic>> _inputList;

  @override
  void initState() {
    super.initState();
    _enableCheckout = widget.initialEnableCheckout;
    _inputDate = widget.todayDate.isNotEmpty
        ? widget.todayDate
        : DateTime.now().toIso8601String().substring(0, 10);

    _inputList = widget.students.map((s) {
      final today = Map<String, dynamic>.from(s['today'] ?? {});
      final st = today['status']?.toString() ?? '';
      return {
        'id': s['id'],
        'name': s['name'],
        'status': st == 'belum' ? '' : st,
        'status_pulang': today['status_pulang']?.toString() ?? '',
        'late_minutes': (today['late_minutes'] as num?)?.toInt() ?? 0,
        'is_locked': false,
      };
    }).toList();

    _syncControllers(_inputList);
    _fetchDateList(_inputDate);
  }

  @override
  void dispose() {
    for (var c in _lateControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<Map<String, dynamic>> list) {
    for (var s in list) {
      final sId = s['id']?.toString() ?? '';
      final minutes = (s['late_minutes'] as num?)?.toInt() ?? 0;
      if (!_lateControllers.containsKey(sId)) {
        _lateControllers[sId] = TextEditingController(text: '$minutes');
      } else {
        final curVal = int.tryParse(_lateControllers[sId]!.text.trim()) ?? 0;
        if (curVal != minutes && minutes > 0) {
          _lateControllers[sId]!.text = '$minutes';
        }
      }
    }
  }

  Future<void> _fetchDateList(String targetDate) async {
    final int currentSeq = ++_requestSeq;
    setState(() => _isLoadingModal = true);

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
        if (mounted) {
          setState(() {
            _isHoliday = d['is_holiday'] == true;
            _enableCheckout = d['enable_checkout'] == true;
            _inputList = List<Map<String, dynamic>>.from(
              (d['students'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e)),
            );
            _syncControllers(_inputList);
          });
        }
      }
    } catch (_) {}
    if (currentSeq == _requestSeq && mounted) {
      setState(() => _isLoadingModal = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final payloadStudents = _inputList.map((item) {
      final sId = item['id']?.toString() ?? '';
      final curSt = item['status']?.toString() ?? '';
      final isNonAtt = ['izin', 'sakit', 'alpa'].contains(curSt);
      final rawMinutes = _lateControllers[sId]?.text.trim() ?? '0';
      final lateMin = int.tryParse(rawMinutes) ??
          ((item['late_minutes'] as num?)?.toInt() ?? 0);

      return {
        'id': item['id'],
        'status': curSt,
        'status_pulang': isNonAtt ? curSt : item['status_pulang']?.toString(),
        'late_minutes': curSt == 'telat' ? lateMin : 0,
      };
    }).toList();

    try {
      final res = await widget.dio.post(
        '${AppConfig.baseUrl}/guru/presensi/manual-input',
        data: {
          'academic_year_id': widget.academicYearId,
          'class_id': widget.selectedClassId,
          'date': _inputDate,
          'students': payloadStudents,
          if (widget.identifier != null)
            'identifier': widget.identifier,
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.data['message']?.toString() ?? 'Presensi berhasil disimpan!',
            ),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        widget.onPresensiSaved();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Presensi tanggal $_inputDate disimpan!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        widget.onPresensiSaved();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.viewInsetsOf(context).bottom;
    final screenH = MediaQuery.sizeOf(context).height;
    final availableH = (screenH - bottomInsets).clamp(0.0, screenH);
    final modalH = (screenH * 0.88).clamp(0.0, availableH);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInsets),
      child: Container(
        height: modalH,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Modal Input Manual
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
                  const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Input Presensi Manual',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Baris Pilih Tanggal & Set Massal
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  ManualBulkDatePickerCard(
                    inputDate: _inputDate,
                    isHoliday: _isHoliday,
                    onPickDate: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.tryParse(_inputDate) ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        final formatted = picked.toIso8601String().substring(0, 10);
                        setState(() => _inputDate = formatted);
                        _fetchDateList(formatted);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ManualBulkQuickSetterBar(
                    bulkDatang: _bulkDatang,
                    bulkPulang: _bulkPulang,
                    enableCheckout: _enableCheckout,
                    onBulkDatangChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _bulkDatang = val;
                        for (var s in _inputList) {
                          if (s['is_locked'] == true) continue;
                          s['status'] = val;
                          if (['izin', 'sakit', 'alpa'].contains(val)) {
                            s['status_pulang'] = val;
                          }
                        }
                      });
                    },
                    onBulkPulangChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _bulkPulang = val;
                        for (var s in _inputList) {
                          final cur = s['status']?.toString() ?? '';
                          if (['izin', 'sakit', 'alpa'].contains(cur)) continue;
                          s['status_pulang'] = val;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Daftar Siswa Input Manual
            Expanded(
              child: _isLoadingModal
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _inputList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final item = _inputList[idx];
                        final sId = item['id']?.toString() ?? '';
                        if (!_lateControllers.containsKey(sId)) {
                          _lateControllers[sId] = TextEditingController(
                            text: '${item['late_minutes'] ?? 0}',
                          );
                        }
                        final ctrl = _lateControllers[sId]!;

                        return ManualBulkStudentCard(
                          item: item,
                          enableCheckout: _enableCheckout,
                          lateController: ctrl,
                          onStatusDatangChanged: (v) {
                            setState(() {
                              item['status'] = v ?? '';
                              if (['izin', 'sakit', 'alpa'].contains(v)) {
                                item['status_pulang'] = v;
                              }
                            });
                          },
                          onStatusPulangChanged: (v) {
                            setState(() {
                              item['status_pulang'] = v ?? '';
                            });
                          },
                          onLateMinutesChanged: (v) {
                            item['late_minutes'] = int.tryParse(v.trim()) ?? 0;
                          },
                        );
                      },
                    ),
            ),

            // Tombol Simpan Presensi Massal
            ManualBulkBottomBar(
              isHoliday: _isHoliday,
              isSaving: _isSaving,
              isLoadingModal: _isLoadingModal,
              onCancel: () => Navigator.pop(context),
              onSave: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
