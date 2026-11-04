import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/config/app_config.dart';
import '../../../../../../core/constants/app_colors.dart';

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
  static const Color _tealDark = Color(0xFF0F766E);

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
              // Modal Header
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
                        Icons.playlist_add_check_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Input Presensi Sholat Dhuhur (1 Kelas)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Kelas ${widget.selectedClassName} • Pencatatan Ibadah Berjamaah',
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

              // Bar Tanggal, Sinkron Presensi Pagi, dan Set Massal
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFA7F3D0)),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.tryParse(_modalDate) ??
                                    DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                final dStr =
                                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                setState(() => _modalDate = dStr);
                                await _loadModalStudents();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFA7F3D0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: _emeraldPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _modalDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!_isHoliday)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEF3C7),
                              foregroundColor: const Color(0xFF92400E),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Color(0xFFFDE68A),
                                ),
                              ),
                            ),
                            onPressed: () =>
                                _loadModalStudents(pullMorning: true),
                            icon: const Icon(
                              Icons.sync_rounded,
                              size: 15,
                            ),
                            label: const Text(
                              'Sinkron Pagi (Izin/Alpa)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isHoliday)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hari Libur Sholat: ${_holidayDesc.isNotEmpty ? _holidayDesc : 'Libur'} (Input Dinonaktifkan)',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          const Text(
                            'Set Massal:',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF065F46),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF6EE7B7),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _bulkStatus.isEmpty
                                      ? null
                                      : _bulkStatus,
                                  hint: const Text(
                                    '-- Pilih Set Massal --',
                                    style: TextStyle(fontSize: 11.5),
                                  ),
                                  isExpanded: true,
                                  isDense: true,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'hadir',
                                      child: Text(
                                        '⚡ Hadir Berjamaah Semua',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'ijin',
                                      child: Text(
                                        'Izin Semua',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'tidak_hadir',
                                      child: Text(
                                        'Alpa Semua',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val == null) return;
                                    setState(() {
                                      _bulkStatus = val;
                                      for (final st in _inputStudents) {
                                        if (st['is_non_muslim'] == true) {
                                          continue;
                                        }
                                        st['status'] = val;
                                        st['is_halangan'] = false;
                                        if (st['keterangan'] ==
                                            'Halangan / Haid') {
                                          st['keterangan'] = '';
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Body Daftar Siswa
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
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, idx) {
                          final st = _inputStudents[idx];
                          final isNm = st['is_non_muslim'] == true;
                          final gender = st['gender']?.toString() ?? 'L';
                          final curStatus = st['status']?.toString() ?? '';
                          final isPagiAbsent = st['is_pagi_absent'] == true;

                          if (isNm) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFC7D2FE),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      st['name']?.toString() ?? '-',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF3730A3),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E7FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Non-Muslim — Tidak Wajib',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF4338CA),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            st['name']?.toString() ?? '-',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                gender == 'P'
                                                    ? 'Perempuan'
                                                    : 'Laki-laki',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: gender == 'P'
                                                      ? const Color(0xFFDB2777)
                                                      : const Color(0xFF2563EB),
                                                ),
                                              ),
                                              if (isPagiAbsent) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 1,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFFEF3C7,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  child: const Text(
                                                    'Sinkron Pagi',
                                                    style: TextStyle(
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(0xFF92400E),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Dropdown Status Siswa
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: [
                                            'hadir',
                                            'ijin',
                                            'tidak_hadir',
                                            if (gender == 'P') 'haid',
                                          ].contains(curStatus)
                                              ? curStatus
                                              : null,
                                          hint: const Text(
                                            '-- Pilih --',
                                            style: TextStyle(fontSize: 11.5),
                                          ),
                                          isDense: true,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          items: [
                                            const DropdownMenuItem(
                                              value: 'hadir',
                                              child: Text(
                                                'Hadir',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF065F46),
                                                ),
                                              ),
                                            ),
                                            const DropdownMenuItem(
                                              value: 'ijin',
                                              child: Text(
                                                'Izin / Sakit',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF1E40AF),
                                                ),
                                              ),
                                            ),
                                            if (gender == 'P')
                                              const DropdownMenuItem(
                                                value: 'haid',
                                                child: Text(
                                                  '🩸 Halangan / Haid',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF9D174D),
                                                  ),
                                                ),
                                              ),
                                            const DropdownMenuItem(
                                              value: 'tidak_hadir',
                                              child: Text(
                                                'Alpa',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF9F1239),
                                                ),
                                              ),
                                            ),
                                          ],
                                          onChanged: _isHoliday
                                              ? null
                                              : (val) {
                                                  if (val == null) return;
                                                  setState(() {
                                                    st['status'] = val;
                                                    if (val == 'haid') {
                                                      st['is_halangan'] = true;
                                                      st['keterangan'] =
                                                          'Halangan / Haid';
                                                    } else {
                                                      st['is_halangan'] = false;
                                                      if (st['keterangan'] ==
                                                          'Halangan / Haid') {
                                                        st['keterangan'] = '';
                                                      }
                                                    }
                                                  });
                                                },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if ((st['keterangan'] ?? '')
                                    .toString()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Catatan: ${st['keterangan']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Footer Simpan Massal
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSavingModal
                            ? null
                            : () => Navigator.pop(context),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: (_isHoliday || _isSavingModal)
                            ? null
                            : _handleSave,
                        icon: const Icon(Icons.save_outlined, size: 17),
                        label: Text(
                          _isSavingModal
                              ? 'Menyimpan...'
                              : 'Simpan Presensi Kelas',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

