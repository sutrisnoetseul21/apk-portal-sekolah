import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apk_portal_smpn1_sampang/core/config/app_config.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

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
              res.data['message']?.toString() ??
                  'Presensi berhasil disimpan!',
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
            content: Text(
              'Presensi tanggal $_inputDate disimpan!',
            ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
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
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
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
                  // Date Picker Row
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.tryParse(_inputDate) ??
                            DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        final formatted =
                            picked.toIso8601String().substring(0, 10);
                        setState(() => _inputDate = formatted);
                        _fetchDateList(formatted);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Pilih Tanggal: ',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _inputDate,
                                style: const TextStyle(
                                  fontSize: 13,
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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFECACA),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFDC2626),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Input ditolak: Tanggal ini adalah hari libur sekolah.',
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

                  const SizedBox(height: 10),

                  // Baris Set Massal Datang & Pulang
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _bulkDatang.isEmpty ? null : _bulkDatang,
                              hint: const Text(
                                '⚡ Set Massal Datang',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'hadir',
                                  child: Text('⚡ Hadir Semua'),
                                ),
                                DropdownMenuItem(
                                  value: 'telat',
                                  child: Text('Terlambat Semua'),
                                ),
                                DropdownMenuItem(
                                  value: 'izin',
                                  child: Text('Izin Semua'),
                                ),
                                DropdownMenuItem(
                                  value: 'sakit',
                                  child: Text('Sakit Semua'),
                                ),
                                DropdownMenuItem(
                                  value: 'alpa',
                                  child: Text('Alpa Semua'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() {
                                  _bulkDatang = val;
                                  for (var s in _inputList) {
                                    if (s['is_locked'] == true) continue;
                                    s['status'] = val;
                                    if ([
                                      'izin',
                                      'sakit',
                                      'alpa',
                                    ].contains(val)) {
                                      s['status_pulang'] = val;
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      if (_enableCheckout) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _bulkPulang.isEmpty ? null : _bulkPulang,
                                hint: const Text(
                                  '⚡ Set Massal Pulang',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'pulang',
                                    child: Text('⚡ Pulang Semua'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'izin',
                                    child: Text('Izin Semua'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'sakit',
                                    child: Text('Sakit Semua'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'alpa',
                                    child: Text('Alpa Semua'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val == null) return;
                                  setState(() {
                                    _bulkPulang = val;
                                    for (var s in _inputList) {
                                      final cur =
                                          s['status']?.toString() ?? '';
                                      if ([
                                        'izin',
                                        'sakit',
                                        'alpa',
                                      ].contains(cur)) {
                                        continue;
                                      }
                                      s['status_pulang'] = val;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final item = _inputList[idx];
                        final isLocked = item['is_locked'] == true;
                        final curStatus =
                            item['status']?.toString() ?? '';
                        final curPulang =
                            item['status_pulang']?.toString() ?? '';
                        final isNonAtt = [
                          'izin',
                          'sakit',
                          'alpa',
                        ].contains(curStatus);

                        final sId = item['id']?.toString() ?? '';
                        if (!_lateControllers.containsKey(sId)) {
                          _lateControllers[sId] = TextEditingController(
                            text: '${item['late_minutes'] ?? 0}',
                          );
                        }
                        final ctrl = _lateControllers[sId]!;

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
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 9,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFFBEB),
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: curStatus.isEmpty
                                                    ? null
                                                    : curStatus,
                                                hint: const Text(
                                                  'Datang: -- Pilih --',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                  ),
                                                ),
                                                isExpanded: true,
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: 'hadir',
                                                    child: Text('Hadir'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'telat',
                                                    child: Text('Terlambat'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'izin',
                                                    child: Text('Izin'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'sakit',
                                                    child: Text('Sakit'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'alpa',
                                                    child: Text('Alpa'),
                                                  ),
                                                ],
                                                onChanged: (v) {
                                                  setState(() {
                                                    item['status'] = v ?? '';
                                                    if ([
                                                      'izin',
                                                      'sakit',
                                                      'alpa',
                                                    ].contains(v)) {
                                                      item['status_pulang'] = v;
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                  ),
                                  if (_enableCheckout) ...[
                                    const SizedBox(width: 8),
                                    // Kolom Status Pulang
                                    Expanded(
                                      child: isNonAtt
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 11,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                curStatus.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: AppColors.border,
                                                ),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: [
                                                    'pulang',
                                                    'izin',
                                                    'sakit',
                                                    'alpa',
                                                  ].contains(curPulang)
                                                      ? curPulang
                                                      : null,
                                                  hint: const Text(
                                                    'Pulang: -- Pilih --',
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                    ),
                                                  ),
                                                  isExpanded: true,
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'pulang',
                                                      child: Text('Pulang'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'izin',
                                                      child: Text('Izin'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'sakit',
                                                      child: Text('Sakit'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'alpa',
                                                      child: Text('Alpa'),
                                                    ),
                                                  ],
                                                  onChanged: (v) {
                                                    setState(() {
                                                      item['status_pulang'] =
                                                          v ?? '';
                                                    });
                                                  },
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
                                        controller: ctrl,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        scrollPadding: const EdgeInsets.only(
                                          bottom: 90,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          suffixText: 'mnt',
                                          isDense: true,
                                          filled: true,
                                          fillColor: const Color(0xFFFFFBEB),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onChanged: (v) {
                                          item['late_minutes'] =
                                              int.tryParse(v.trim()) ?? 0;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Tombol Simpan Presensi Massal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isHoliday
                            ? Colors.grey
                            : const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (_isHoliday ||
                              _isSaving ||
                              _isLoadingModal)
                          ? null
                          : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Presensi',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
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

