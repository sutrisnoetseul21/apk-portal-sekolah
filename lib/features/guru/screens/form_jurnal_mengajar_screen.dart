import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/form_jurnal/sections/form_jurnal_header.dart';
import 'widgets/form_jurnal/sections/form_jurnal_sticky_bottom_bar.dart';
import 'widgets/form_jurnal/steps/step1_parameter_kbm_card.dart';
import 'widgets/form_jurnal/steps/step2_materi_refleksi_card.dart';
import 'widgets/form_jurnal/steps/step3_presensi_siswa_card.dart';

/// Halaman Form Tambah & Edit Jurnal Mengajar
/// Mengikuti 100% aturan bisnis JurnalMengajarForm.php (/portal-guru/jurnal-mengajar/tambah & edit)
class FormJurnalMengajarScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String? jurnalId;

  const FormJurnalMengajarScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    this.jurnalId,
  });

  @override
  State<FormJurnalMengajarScreen> createState() =>
      _FormJurnalMengajarScreenState();
}

class _FormJurnalMengajarScreenState extends State<FormJurnalMengajarScreen> {
  late final Dio _dio;

  bool _isLoadingInit = true;
  bool _isLoadingStudents = false;
  bool _isSaving = false;

  bool get _isEdit => widget.jurnalId != null && widget.jurnalId!.isNotEmpty;

  // Master Info
  String _academicYearName = 'Tahun Aktif';
  String _teacherName = '';
  String _tanggal = '';
  String _tanggalFormatted = '';

  // Waktu KBM (Smart JP Calculator)
  int _jamMulai = 1;
  int _durasiJp = 2;
  int get _jamSelesai => _jamMulai + _durasiJp - 1;
  int get _durasiMenit => _durasiJp * 40;
  String get _jamKeLabel => _durasiJp == 1
      ? 'Jam ke $_jamMulai (1 JP)'
      : 'Jam ke $_jamMulai - $_jamSelesai ($_durasiJp JP)';

  // Pemilihan Mapel & Kelas
  bool _isSingleMapel = false;
  int? _selectedMapelId;
  String? _selectedClassId;

  List<Map<String, dynamic>> _availableMapels = [];
  List<Map<String, dynamic>> _allTeachingClasses = [];

  // Form Controllers
  final TextEditingController _materiController = TextEditingController();
  final TextEditingController _uraianController = TextEditingController();
  final TextEditingController _refleksiController = TextEditingController();
  final TextEditingController _studentSearchController =
      TextEditingController();
  String _studentSearchQuery = '';

  // Daftar Presensi Siswa Sesi KBM
  List<Map<String, dynamic>> _students = [];
  final Map<String, TextEditingController> _noteControllers = {};

  // Tema Warna Indigo-Purple Jurnal Mengajar
  static const Color _indigoPrimary = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    _teacherName = widget.teacherName;
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          if (widget.token != null && widget.token!.isNotEmpty)
            'Authorization': 'Bearer ${widget.token}',
          if (widget.identifier != null && widget.identifier!.isNotEmpty)
            'X-User-Identifier': widget.identifier,
        },
      ),
    );
    _initForm();
  }

  @override
  void dispose() {
    _materiController.dispose();
    _uraianController.dispose();
    _refleksiController.dispose();
    _studentSearchController.dispose();
    for (final ctrl in _noteControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredClassesForSelectedMapel {
    if (_selectedMapelId == null) return [];
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final c in _allTeachingClasses) {
      final mId = int.tryParse('${c['mata_pelajaran_id']}');
      final cId = '${c['id']}';
      if (mId == _selectedMapelId && !seen.contains(cId)) {
        seen.add(cId);
        result.add(c);
      }
    }
    return result;
  }

  Future<void> _initForm() async {
    setState(() => _isLoadingInit = true);
    try {
      if (_isEdit) {
        await _loadExistingJurnal(widget.jurnalId!);
      } else {
        await _loadFormOptions();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memuat parameter form jurnal: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingInit = false);
      }
    }
  }

  Future<void> _loadFormOptions() async {
    final res = await _dio.get(
      '/guru/jurnal-mengajar/form-options',
      queryParameters: {'identifier': ?widget.identifier},
    );

    final body = res.data;
    if (body is Map && body['data'] is Map) {
      final data = Map<String, dynamic>.from(body['data'] as Map);
      final ay = data['academic_year'] as Map?;
      final teacher = data['teacher'] as Map?;

      final mapels = (data['available_mapels'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final classes = (data['available_classes'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final isSingle = data['is_single_mapel'] == true || mapels.length == 1;
      int? autoMapelId = data['auto_mapel_id'] != null
          ? int.tryParse('${data['auto_mapel_id']}')
          : (isSingle && mapels.isNotEmpty
                ? int.tryParse('${mapels.first['id']}')
                : null);

      setState(() {
        _academicYearName = '${ay?['name'] ?? 'Tahun Aktif'}';
        if (teacher != null && '${teacher['name'] ?? ''}'.isNotEmpty) {
          _teacherName = '${teacher['name']}';
        }
        _tanggal =
            '${data['today'] ?? DateTime.now().toIso8601String().split('T').first}';
        _tanggalFormatted = '${data['today_formatted'] ?? _tanggal}';
        _jamMulai = int.tryParse('${data['default_jam_mulai'] ?? 1}') ?? 1;
        _durasiJp = int.tryParse('${data['default_durasi_jp'] ?? 2}') ?? 2;
        _availableMapels = mapels;
        _allTeachingClasses = classes;
        _isSingleMapel = isSingle;
        _selectedMapelId = autoMapelId;
      });

      if (_selectedMapelId != null) {
        _checkAutoSelectClassAndLoadStudents();
      }
    }
  }

  Future<void> _loadExistingJurnal(String id) async {
    final res = await _dio.get(
      '/guru/jurnal-mengajar/$id',
      queryParameters: {'identifier': ?widget.identifier},
    );

    final body = res.data;
    if (body is Map && body['data'] is Map) {
      final data = Map<String, dynamic>.from(body['data'] as Map);
      final jurnal = Map<String, dynamic>.from(data['jurnal'] as Map? ?? {});
      final mapels = (data['available_mapels'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final classes = (data['available_classes'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final students = (data['students'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      _syncNoteControllers(students);

      setState(() {
        _academicYearName = '${jurnal['academic_year_name'] ?? 'Tahun Aktif'}';
        _teacherName = '${jurnal['teacher_name'] ?? widget.teacherName}';
        _tanggal = '${jurnal['tanggal'] ?? ''}';
        _tanggalFormatted = '${jurnal['tanggal_formatted'] ?? _tanggal}';
        _selectedMapelId = int.tryParse('${jurnal['mata_pelajaran_id']}');
        _selectedClassId = '${jurnal['class_id'] ?? ''}';
        _jamMulai = int.tryParse('${jurnal['jam_mulai'] ?? 1}') ?? 1;
        _durasiJp = int.tryParse('${jurnal['durasi_jp'] ?? 2}') ?? 2;
        _materiController.text = '${jurnal['materi'] ?? ''}';
        _uraianController.text = '${jurnal['uraian_materi'] ?? ''}';
        _refleksiController.text = '${jurnal['refleksi'] ?? ''}';
        _availableMapels = mapels;
        _allTeachingClasses = classes;
        _isSingleMapel = data['is_single_mapel'] == true || mapels.length == 1;
        _students = students;
      });
    }
  }

  void _syncNoteControllers(List<Map<String, dynamic>> students) {
    for (final s in students) {
      final sId = '${s['student_id']}';
      final ket = '${s['keterangan'] ?? ''}';
      if (_noteControllers.containsKey(sId)) {
        _noteControllers[sId]!.text = ket;
      } else {
        _noteControllers[sId] = TextEditingController(text: ket);
      }
    }
  }

  void _checkAutoSelectClassAndLoadStudents() {
    final classesForMapel = _filteredClassesForSelectedMapel;
    if (classesForMapel.length == 1) {
      final onlyClassId = '${classesForMapel.first['id']}';
      setState(() => _selectedClassId = onlyClassId);
      _loadStudentsAndGateAttendance();
    } else if (_selectedClassId != null &&
        classesForMapel.any((c) => '${c['id']}' == _selectedClassId)) {
      _loadStudentsAndGateAttendance();
    } else {
      setState(() {
        _selectedClassId = null;
        _students = [];
      });
    }
  }

  Future<void> _loadStudentsAndGateAttendance() async {
    if (_selectedClassId == null ||
        _selectedClassId!.isEmpty ||
        _tanggal.isEmpty) {
      setState(() => _students = []);
      return;
    }

    setState(() => _isLoadingStudents = true);
    try {
      final res = await _dio.get(
        '/guru/jurnal-mengajar/students',
        queryParameters: {
          'class_id': _selectedClassId,
          'tanggal': _tanggal,
          'jurnal_id': ?widget.jurnalId,
          'identifier': ?widget.identifier,
        },
      );

      final body = res.data;
      if (body is Map && body['data'] is Map) {
        final data = Map<String, dynamic>.from(body['data'] as Map);
        final students = (data['students'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        _syncNoteControllers(students);

        setState(() {
          if (data['tanggal_formatted'] != null) {
            _tanggalFormatted = '${data['tanggal_formatted']}';
          }
          _students = students;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memuat daftar siswa: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingStudents = false);
      }
    }
  }

  Future<void> _pickTanggalKbm() async {
    final initial = DateTime.tryParse(_tanggal) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'PILIH TANGGAL PELAKSANAAN KBM',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _indigoPrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedIso =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _tanggal = formattedIso;
        _tanggalFormatted = _formatLocalDateIndo(picked);
      });
      if (_selectedClassId != null && _selectedClassId!.isNotEmpty) {
        await _loadStudentsAndGateAttendance();
      }
    }
  }

  String _formatLocalDateIndo(DateTime dt) {
    const days = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[dt.weekday]}, ${dt.day} ${months[dt.month]} ${dt.year}';
  }

  void _setManualStatusBelumAbsen(int index, String? status) {
    final item = _students[index];
    if ('${item['status_gerbang']}' != 'belum_absen') return;

    HapticFeedback.lightImpact();
    setState(() {
      _students[index]['manual_status'] = status;
      if (status == null) {
        // Reset kembali ke status awal (belum ditentukan)
        _students[index]['diabsenkan_telat'] = false;
        _students[index]['status_jurnal'] = 'tidak_mengikuti';
      } else if (status == 'hadir' || status == 'telat') {
        _students[index]['diabsenkan_telat'] = (status == 'telat');
        _students[index]['status_jurnal'] = 'hadir';
      } else {
        // status == 'izin' || status == 'sakit' || status == 'alpa'
        _students[index]['diabsenkan_telat'] = false;
        _students[index]['status_jurnal'] = 'tidak_mengikuti';
      }
    });
  }

  void _setStatusJurnal(int index, String status) {
    final item = _students[index];
    if (item['is_locked'] == true) return;

    HapticFeedback.selectionClick();
    setState(() {
      _students[index]['status_jurnal'] = status;
    });
  }

  void _markAllHadir() {
    HapticFeedback.mediumImpact();
    setState(() {
      for (var i = 0; i < _students.length; i++) {
        if (_students[i]['is_locked'] != true) {
          _students[i]['status_jurnal'] = 'hadir';
          if ('${_students[i]['status_gerbang']}' == 'belum_absen') {
            // Default hadir untuk yang belum absen jika ditandai semua hadir
            if (_students[i]['manual_status'] == null) {
              _students[i]['manual_status'] = 'hadir';
            }
            _students[i]['diabsenkan_telat'] = (_students[i]['manual_status'] == 'telat');
          }
        }
      }
    });
    _showSnackBar(
      'Seluruh siswa aktif (yang tidak terkunci sakit/izin/alpa) ditandai Hadir KBM.',
    );
  }

  Future<void> _saveJurnal() async {
    if (_selectedMapelId == null) {
      _showSnackBar('Pilih Mata Pelajaran terlebih dahulu.', isError: true);
      return;
    }
    if (_selectedClassId == null || _selectedClassId!.isEmpty) {
      _showSnackBar('Pilih Kelas Rombel terlebih dahulu.', isError: true);
      return;
    }
    final materi = _materiController.text.trim();
    if (materi.isEmpty) {
      _showSnackBar(
        'Judul Materi Pokok / Bab / Topik wajib diisi.',
        isError: true,
      );
      return;
    }
    final uraian = _uraianController.text.trim();
    if (uraian.length < 5) {
      _showSnackBar(
        'Uraian Aktivitas KBM wajib diisi (minimal 5 karakter).',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final studentsPayload = _students.map((s) {
        final sId = '${s['student_id']}';
        final noteText =
            _noteControllers[sId]?.text.trim() ?? '${s['keterangan'] ?? ''}';
        return {
          'student_id': sId,
          'status_gerbang': s['status_gerbang'],
          'status_jurnal': s['status_jurnal'],
          'status_absen_manual': s['manual_status'],
          'diabsenkan_telat': s['manual_status'] == 'telat' || (s['diabsenkan_telat'] == true && s['manual_status'] == null),
          'keterangan': noteText,
        };
      }).toList();

      final payload = {
        'tanggal': _tanggal,
        'class_id': _selectedClassId,
        'mata_pelajaran_id': _selectedMapelId,
        'jam_mulai': _jamMulai,
        'durasi_jp': _durasiJp,
        'materi': materi,
        'uraian_materi': uraian,
        'refleksi': _refleksiController.text.trim(),
        'students': studentsPayload,
        'identifier': ?widget.identifier,
      };

      final Response<dynamic> res;
      if (_isEdit) {
        res = await _dio.put(
          '/guru/jurnal-mengajar/${widget.jurnalId}',
          data: payload,
        );
      } else {
        res = await _dio.post('/guru/jurnal-mengajar', data: payload);
      }

      final body = res.data;
      final msg = (body is Map && body['message'] != null)
          ? '${body['message']}'
          : 'Jurnal mengajar berhasil disimpan!';

      if (mounted) {
        _showSnackBar(msg);
        Navigator.of(context).pop(true);
      }
    } on DioException catch (e) {
      String errMsg = 'Gagal menyimpan jurnal mengajar.';
      final resData = e.response?.data;
      if (resData is Map && resData['message'] != null) {
        errMsg = '${resData['message']}';
      }
      if (mounted) {
        _showSnackBar(errMsg, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        backgroundColor: isError ? AppColors.alpa : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _indigoPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEdit ? 'Perbarui Jurnal Mengajar' : 'Tulis Jurnal Mengajar',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'TA $_academicYearName • $_teacherName',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _isLoadingInit
          ? const Center(
              child: CircularProgressIndicator(color: _indigoPrimary),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormJurnalHeader(isEdit: _isEdit),
                      const SizedBox(height: 16),
                      Step1ParameterKbmCard(
                        teacherName: _teacherName,
                        tanggal: _tanggal,
                        tanggalFormatted: _tanggalFormatted,
                        onPickTanggalKbm: _pickTanggalKbm,
                        isSingleMapel: _isSingleMapel,
                        availableMapels: _availableMapels,
                        selectedMapelId: _selectedMapelId,
                        onMapelChanged: (v) {
                          setState(() => _selectedMapelId = v);
                          _checkAutoSelectClassAndLoadStudents();
                        },
                        classesForMapel: _filteredClassesForSelectedMapel,
                        selectedClassId: _selectedClassId,
                        onClassChanged: (v) {
                          setState(() => _selectedClassId = v);
                          _loadStudentsAndGateAttendance();
                        },
                        jamMulai: _jamMulai,
                        durasiJp: _durasiJp,
                        durasiMenit: _durasiMenit,
                        jamKeLabel: _jamKeLabel,
                        onJamMulaiChanged: (v) => setState(() => _jamMulai = v),
                        onDurasiJpChanged: (v) => setState(() => _durasiJp = v),
                      ),
                      const SizedBox(height: 16),
                      Step2MateriRefleksiCard(
                        materiController: _materiController,
                        uraianController: _uraianController,
                        refleksiController: _refleksiController,
                      ),
                      const SizedBox(height: 16),
                      Step3PresensiSiswaCard(
                        students: _students,
                        isLoadingStudents: _isLoadingStudents,
                        studentSearchController: _studentSearchController,
                        studentSearchQuery: _studentSearchQuery,
                        onSearchChanged: (v) =>
                            setState(() => _studentSearchQuery = v.trim()),
                        onClearSearch: () {
                          _studentSearchController.clear();
                          setState(() => _studentSearchQuery = '');
                        },
                        onMarkAllHadir: _markAllHadir,
                        noteControllers: _noteControllers,
                        onSetStatusJurnal: _setStatusJurnal,
                        onSetManualStatusBelumAbsen: _setManualStatusBelumAbsen,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FormJurnalStickyBottomBar(
                    isSaving: _isSaving,
                    isEdit: _isEdit,
                    onCancel: () => Navigator.of(context).pop(),
                    onSave: _saveJurnal,
                  ),
                ),
              ],
            ),
    );
  }
}
