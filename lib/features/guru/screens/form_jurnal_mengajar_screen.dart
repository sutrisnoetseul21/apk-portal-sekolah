import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';

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
  static const Color _indigoDark = Color(0xFF3730A3);
  static const Color _purpleAccent = Color(0xFF7C3AED);

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

  void _toggleAbsenkanTelat(int index) {
    final item = _students[index];
    if ('${item['status_gerbang']}' != 'belum_absen') return;

    HapticFeedback.lightImpact();
    final current = item['diabsenkan_telat'] == true;
    setState(() {
      _students[index]['diabsenkan_telat'] = !current;
      _students[index]['status_jurnal'] = !current
          ? 'hadir'
          : 'tidak_mengikuti';
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
            _students[i]['diabsenkan_telat'] = true;
          }
        }
      }
    });
    _showSnackBar(
      'Seluruh siswa aktif (yang tidak terkunci sakit/izin/alpa) ditandai Hadir KBM.',
    );
  }

  Future<void> _saveJurnal() async {
    // Validasi Frontend
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
          'diabsenkan_telat': s['diabsenkan_telat'] == true,
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
                      _buildHeroHeaderCard(),
                      const SizedBox(height: 16),
                      _buildStep1ParameterCard(),
                      const SizedBox(height: 16),
                      _buildStep2MateriRefleksiCard(),
                      const SizedBox(height: 16),
                      _buildStep3StudentAttendanceCard(),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildStickyBottomBar(),
                ),
              ],
            ),
    );
  }

  Widget _buildHeroHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_indigoPrimary, _indigoDark, _purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _indigoPrimary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF34D399)),
                    SizedBox(width: 6),
                    Text(
                      'PRESENSI & JURNAL DIGITAL KBM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isEdit)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFCD34D).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text(
                    'MODE EDIT',
                    style: TextStyle(
                      color: Color(0xFFFEF3C7),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isEdit ? 'Perbarui Jurnal Mengajar' : 'Tulis Jurnal Mengajar',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dokumentasi agenda pembelajaran, kalkulasi JP otomatis, dan sinkronisasi langsung dengan kehadiran gerbang sekolah.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1ParameterCard() {
    final classesForMapel = _filteredClassesForSelectedMapel;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Langkah 01
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_indigoPrimary, _purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '01',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parameter Pembelajaran & Jadwal Waktu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tentukan mata pelajaran, kelas rombel, serta durasi jam pelajaran.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26),

          // 1. Guru Pengampu (Read-Only)
          const Text(
            'GURU PENGAMPU',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _teacherName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AKTIF',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Tanggal Pelaksanaan KBM
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TANGGAL KBM *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _indigoPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Format Indonesia',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _indigoPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickTanggalKbm,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: _indigoPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _tanggalFormatted.isNotEmpty
                          ? _tanggalFormatted
                          : _tanggal,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Mata Pelajaran (Dipilih Dulu)
          const Text(
            'MATA PELAJARAN *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          if (_isSingleMapel && _availableMapels.length == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFECFDF5), Color(0xFFF0FDFA)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF6EE7B7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_availableMapels.first['nama_mapel'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA7F3D0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'OTOMATIS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value:
                      _availableMapels.any(
                        (m) => int.tryParse('${m['id']}') == _selectedMapelId,
                      )
                      ? _selectedMapelId
                      : null,
                  isExpanded: true,
                  hint: const Text(
                    '-- Pilih Mata Pelajaran --',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  items: _availableMapels.map((m) {
                    final mId = int.tryParse('${m['id']}') ?? 0;
                    return DropdownMenuItem<int>(
                      value: mId,
                      child: Text(
                        '${m['nama_mapel'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedMapelId = val;
                      _selectedClassId = null;
                      _students = [];
                    });
                    _checkAutoSelectClassAndLoadStudents();
                  },
                ),
              ),
            ),
          const SizedBox(height: 14),

          // 4. Kelas Rombel (Dependent pada Mapel)
          const Text(
            'KELAS ROMBEL *',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          if (_selectedMapelId == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                '-- Pilih Mapel Terlebih Dahulu --',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:
                      classesForMapel.any(
                        (c) => '${c['id']}' == _selectedClassId,
                      )
                      ? _selectedClassId
                      : null,
                  isExpanded: true,
                  hint: const Text(
                    '-- Pilih Kelas Rombel --',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  items: classesForMapel.map((c) {
                    final cId = '${c['id']}';
                    return DropdownMenuItem<String>(
                      value: cId,
                      child: Text(
                        '${c['name'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedClassId = val);
                    _loadStudentsAndGateAttendance();
                  },
                ),
              ),
            ),

          const SizedBox(height: 18),

          // SMART JP CALCULATOR STRIP
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kotak 1: Jam Mulai (Ke-) 1 s/d 9
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _indigoPrimary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '1',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: _indigoPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Jam Mulai (Ke-)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _indigoPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Jam Ke-$_jamMulai',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: _indigoPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(9, (idx) {
                          final jamOpt = idx + 1;
                          final isSelected = _jamMulai == jamOpt;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: idx < 8 ? 4.0 : 0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _jamMulai = jamOpt);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [
                                              _indigoPrimary,
                                              _purpleAccent,
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? _indigoPrimary
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Text(
                                    '$jamOpt',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Kotak 2: Durasi Pembelajaran 1 s/d 5 JP
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _purpleAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: _purpleAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Durasi Pembelajaran',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                              ),
                            ),
                            child: const Text(
                              '40 Menit / JP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(5, (idx) {
                          final jpOpt = idx + 1;
                          final isSelected = _durasiJp == jpOpt;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: idx < 4 ? 6.0 : 0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _durasiJp = jpOpt);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [
                                              _indigoPrimary,
                                              _purpleAccent,
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? _indigoPrimary
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Text(
                                    '$jpOpt JP',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Kotak 3: Hasil Kalkulasi Jadwal
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_indigoPrimary, _purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.access_time_filled_rounded,
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
                              'RENTANG KBM TERJADWAL',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _jamKeLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$_durasiMenit Menit',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$_durasiJp JP × 40 mnt',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2MateriRefleksiCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Langkah 02
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_purpleAccent, _indigoPrimary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '02',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dokumentasi Materi Pokok & Refleksi KBM',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Uraikan capaian pembelajaran, aktivitas kelas, serta catatan evaluasi.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26),

          // Materi Pokok
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MATERI POKOK / BAB / TOPIK *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Wajib diisi',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _materiController,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText:
                  'Contoh: Bab 3 - Persamaan Linier Dua Variabel (SPLDV)',
              hintStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _indigoPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Uraian Aktivitas KBM
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'URAIAN AKTIVITAS KBM & PENUGASAN *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Min. 5 karakter',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _uraianController,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText:
                  'Deskripsikan secara ringkas kegiatan pembelajaran: apersepsi, penyampaian materi, diskusi kelompok, praktikum, atau tugas latihan...',
              hintStyle: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _indigoPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Refleksi Guru (Opsional)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 17,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Refleksi / Catatan Tindak Lanjut Guru (Opsional)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _refleksiController,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Catatan evaluasi ketercapaian kelas, siswa yang perlu remedial, kedisiplinan, atau rencana sesi berikutnya...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFCD34D)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFCD34D)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD97706),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3StudentAttendanceCard() {
    final filteredStudents = <MapEntry<int, Map<String, dynamic>>>[];
    for (var i = 0; i < _students.length; i++) {
      final s = _students[i];
      if (_studentSearchQuery.isNotEmpty) {
        final q = _studentSearchQuery.toLowerCase();
        final name = '${s['name'] ?? ''}'.toLowerCase();
        final nis = '${s['nis'] ?? ''}'.toLowerCase();
        if (!name.contains(q) && !nis.contains(q)) continue;
      }
      filteredStudents.add(MapEntry(i, s));
    }

    int hadirCount = 0;
    int tidakMengikutiCount = 0;
    for (final s in _students) {
      if ('${s['status_jurnal']}' == 'hadir') {
        hadirCount++;
      } else {
        tidakMengikutiCount++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Langkah 03
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF0D9488)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '03',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Presensi Siswa di Jam KBM',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_students.length} Siswa',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Terintegrasi otomatis dengan presensi gerbang. Siswa sakit/izin/alpa dikunci demi validitas.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Live Status Legend Chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'PETUNJUK:',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF64748B),
                  ),
                ),
                _buildLegendChip(
                  'Hadir Tepat Waktu',
                  const Color(0xFF10B981),
                  const Color(0xFFECFDF5),
                ),
                _buildLegendChip(
                  'Telat Gerbang',
                  const Color(0xFFF59E0B),
                  const Color(0xFFFFFBEB),
                ),
                _buildLegendChip(
                  'Belum Scan Gerbang',
                  const Color(0xFF64748B),
                  const Color(0xFFF1F5F9),
                ),
                _buildLegendChip(
                  'Sakit/Izin/Alpa (Terkunci)',
                  const Color(0xFFE11D48),
                  const Color(0xFFFFF1F2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (_isLoadingStudents)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(color: _indigoPrimary),
              ),
            )
          else if (_students.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.groups_2_outlined,
                    size: 40,
                    color: _indigoPrimary,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Daftar Siswa Belum Dimuat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Silakan pilih Kelas Rombel pada Langkah 01 di atas untuk memuat seluruh peserta didik aktif dan presensi gerbangnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Ringkasan Cepat + Tombol Tandai Semua Hadir KBM
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Hadir KBM: $hadirCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                        ),
                      ),
                      Text(
                        '• Tidak Hadir: $tidakMengikutiCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _markAllHadir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.done_all_rounded, size: 15),
                  label: const Text(
                    'Tandai Semua Hadir KBM',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Pencarian Siswa di Kelas
            TextField(
              controller: _studentSearchController,
              onChanged: (v) => setState(() => _studentSearchQuery = v.trim()),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIS siswa di kelas ini...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                suffixIcon: _studentSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _studentSearchController.clear();
                          setState(() => _studentSearchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Kartu Siswa
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredStudents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final entry = filteredStudents[idx];
                return _buildStudentAttendanceItem(
                  entry.key,
                  entry.value,
                  idx + 1,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendChip(String label, Color dotColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dotColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceItem(
    int realIndex,
    Map<String, dynamic> item,
    int displayNo,
  ) {
    final sId = '${item['student_id']}';
    final name = '${item['name'] ?? '-'}';
    final nis = '${item['nis'] ?? '-'}';
    final statusGerbang = '${item['status_gerbang'] ?? 'belum_absen'}';
    final statusJurnal = '${item['status_jurnal'] ?? 'hadir'}';
    final isLocked = item['is_locked'] == true;
    final diabsenkanTelat = item['diabsenkan_telat'] == true;

    final initials = name.trim().isNotEmpty
        ? name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
              .join()
        : 'S';

    // Badge Status Gerbang Pagi
    String gateLabel = '⚪ Belum Scan';
    Color gateBg = const Color(0xFFF1F5F9);
    Color gateFg = const Color(0xFF475569);
    if (statusGerbang == 'hadir') {
      gateLabel = '✓ Tepat Waktu';
      gateBg = const Color(0xFFECFDF5);
      gateFg = const Color(0xFF065F46);
    } else if (statusGerbang == 'telat') {
      gateLabel = '⏰ Telat di Gerbang';
      gateBg = const Color(0xFFFFFBEB);
      gateFg = const Color(0xFF92400E);
    } else if (statusGerbang == 'izin') {
      gateLabel = '✉️ Izin Resmi';
      gateBg = const Color(0xFFEFF6FF);
      gateFg = const Color(0xFF1E40AF);
    } else if (statusGerbang == 'sakit') {
      gateLabel = '🩺 Sakit';
      gateBg = const Color(0xFFF5F3FF);
      gateFg = const Color(0xFF5B21B6);
    } else if (statusGerbang == 'alpa') {
      gateLabel = '✕ Alpa';
      gateBg = const Color(0xFFFFF1F2);
      gateFg = const Color(0xFF9F1239);
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFFFFF1F2).withValues(alpha: 0.45) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? const Color(0xFFFECDD3)
              : (statusJurnal == 'tidak_mengikuti'
                    ? const Color(0xFFFDA4AF)
                    : AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Nomor + Initials Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _indigoPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _indigoPrimary.withValues(alpha: 0.2),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _indigoPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$displayNo. $name',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIS/NISN: $nis',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: gateBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: gateFg.withValues(alpha: 0.2)),
                ),
                child: Text(
                  gateLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: gateFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Baris Aksi Kehadiran Jam KBM
          if (isLocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 15,
                    color: Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tidak Mengikuti (Terkunci • Tercatat ${statusGerbang.toUpperCase()} di gerbang pagi)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (statusGerbang == 'belum_absen')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () => _toggleAbsenkanTelat(realIndex),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: diabsenkanTelat
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: diabsenkanTelat
                              ? const Color(0xFFD97706)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            diabsenkanTelat
                                ? Icons.check_circle_rounded
                                : Icons.add_circle_outline_rounded,
                            size: 16,
                            color: diabsenkanTelat
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            diabsenkanTelat
                                ? '✓ Diabsenkan Hadir (Wajib Telat)'
                                : '+ Hadirkan di Kelas (Wajib Telat)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: diabsenkanTelat
                                  ? Colors.white
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (diabsenkanTelat) ...[
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: Color(0xFFB45309),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Otomatis dicatat TELAT di presensi gerbang sekolah',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            )
          else
            Row(
              children: [
                const Text(
                  'Kehadiran KBM:',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _setStatusJurnal(realIndex, 'hadir'),
                            borderRadius: BorderRadius.circular(9),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: statusJurnal == 'hadir'
                                    ? const Color(0xFF059669)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                '✓ Hadir',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: statusJurnal == 'hadir'
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _setStatusJurnal(
                              realIndex,
                              'tidak_mengikuti',
                            ),
                            borderRadius: BorderRadius.circular(9),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: statusJurnal == 'tidak_mengikuti'
                                    ? const Color(0xFFE11D48)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                '✕ Tidak Hadir',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: statusJurnal == 'tidak_mengikuti'
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          // Input Catatan / Alasan jika tidak terkunci
          if (!isLocked &&
              (statusJurnal == 'tidak_mengikuti' ||
                  (_noteControllers[sId]?.text.isNotEmpty ?? false))) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _noteControllers[sId],
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: statusJurnal == 'tidak_mengikuti'
                    ? 'Alasan tidak mengikuti KBM (misal: Izin UKS, Bolos)...'
                    : 'Catatan khusus siswa (opsional)...',
                hintStyle: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: statusJurnal == 'tidak_mengikuti'
                    ? const Color(0xFFFFF1F2)
                    : const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: statusJurnal == 'tidak_mengikuti'
                        ? const Color(0xFFFDA4AF)
                        : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: statusJurnal == 'tidak_mengikuti'
                        ? const Color(0xFFFDA4AF)
                        : AppColors.border,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveJurnal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _indigoPrimary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  _isSaving
                      ? 'Menyimpan Jurnal...'
                      : (_isEdit
                            ? 'Simpan Perubahan Jurnal'
                            : 'Simpan Jurnal Mengajar'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
