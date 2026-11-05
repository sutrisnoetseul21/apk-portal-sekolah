import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import 'form_jurnal_mengajar_screen.dart';
import 'widgets/jurnal_mengajar/cards/jurnal_item_card.dart';
import 'widgets/jurnal_mengajar/modals/dialog_cetak_jurnal_periode.dart';
import 'widgets/jurnal_mengajar/modals/sheet_detail_jurnal_kbm.dart';
import 'widgets/jurnal_mengajar/sections/jurnal_analisa_section.dart';
import 'widgets/jurnal_mengajar/sections/jurnal_filter_card.dart';

/// Halaman Menu 3: Jurnal Mengajar (/portal-guru/jurnal-mengajar)
/// Dilengkapi 2 Tab: (1) Riwayat Jurnal & (2) Analisa Kelas & Kehadiran Siswa
class JurnalMengajarScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;

  const JurnalMengajarScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    this.schoolName = '',
  });

  @override
  State<JurnalMengajarScreen> createState() => _JurnalMengajarScreenState();
}

class _JurnalMengajarScreenState extends State<JurnalMengajarScreen>
    with SingleTickerProviderStateMixin {
  late final Dio _dio;
  late final TabController _tabController;

  bool _isLoading = true;
  bool _isAnalyticsLoading = false;
  bool _isSupervisor = false;

  // Info Tahun Ajaran & Guru
  String _academicYearId = '';
  String _academicYearName = 'Tahun Aktif';
  String _currentTeacherName = '';
  String? _selectedTeacherId;
  List<Map<String, dynamic>> _teachers = [];

  // Filter State
  String _selectedMonthYear = ''; // '' = Semua Bulan, atau 'MM-YYYY'
  bool _isFirstLoad = true;
  List<Map<String, dynamic>> _availableMonthsList = [];

  bool _isSingleMapel = false;
  int? _selectedMapelId;
  List<Map<String, dynamic>> _availableMapels = [];

  String? _selectedClassId;
  List<Map<String, dynamic>> _allTeachingClasses = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Statistik Ringkasan
  int _totalSesi = 0;
  int _totalJp = 0;

  // Daftar Jurnal & Pagination
  List<Map<String, dynamic>> _jurnals = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;

  // Data Analisa Kelas & Siswa (Tab 2)
  Map<String, dynamic> _analyticsTotals = {
    'total_sesi': 0,
    'total_jp': 0,
    'hadir': 0,
    'izin': 0,
    'sakit': 0,
    'izin_sakit': 0,
    'alpa': 0,
    'tidak_mengikuti': 0,
    'total_absen': 0,
  };
  List<Map<String, dynamic>> _classesSummary = [];
  List<Map<String, dynamic>> _studentsSummary = [];

  // Tema Warna Indigo-Purple Jurnal Mengajar
  static const Color _indigoPrimary = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentTeacherName = widget.teacherName;
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
    _fetchJurnals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredClassesForSelectedMapel {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final c in _allTeachingClasses) {
      final mId = int.tryParse('${c['mata_pelajaran_id']}');
      final cId = '${c['id']}';
      if ((_selectedMapelId == null || mId == _selectedMapelId) &&
          !seen.contains(cId)) {
        seen.add(cId);
        result.add(c);
      }
    }
    return result;
  }

  Future<void> _fetchJurnals({int page = 1}) async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': 12,
        'identifier': ?widget.identifier,
        if (!_isFirstLoad)
          'month_year': _selectedMonthYear.isEmpty ? 'all' : _selectedMonthYear,
        if (_selectedTeacherId != null && _selectedTeacherId!.isNotEmpty)
          'teacher_id': _selectedTeacherId,
        'mata_pelajaran_id': ?_selectedMapelId,
        if (_selectedClassId != null && _selectedClassId!.isNotEmpty)
          'class_id': _selectedClassId,
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      };

      final res = await _dio.get(
        '/guru/jurnal-mengajar',
        queryParameters: queryParams,
      );

      final body = res.data;
      if (body is Map && body['data'] is Map) {
        final data = Map<String, dynamic>.from(body['data'] as Map);
        final ay = data['academic_year'] as Map?;
        final currentTeacher = data['current_teacher'] as Map?;
        final summary = data['summary'] as Map?;
        final meta = data['meta'] as Map?;
        final analyticsRaw = data['analytics'] as Map?;

        final monthsList = (data['available_months_list'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final mapels = (data['available_mapels'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final allClasses = (data['all_teaching_classes'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final teachers = (data['teachers'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final jurnals = (data['jurnals'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        setState(() {
          _academicYearId = '${ay?['id'] ?? ''}';
          _academicYearName = '${ay?['name'] ?? 'Tahun Aktif'}';
          _isSupervisor = data['is_supervisor'] == true;
          if (currentTeacher != null &&
              '${currentTeacher['name'] ?? ''}'.isNotEmpty) {
            _currentTeacherName = '${currentTeacher['name']}';
          }
          _selectedTeacherId = '${data['selected_teacher_id'] ?? ''}'.isNotEmpty
              ? '${data['selected_teacher_id']}'
              : null;
          _teachers = teachers;

          if (_isFirstLoad) {
            _selectedMonthYear = '${data['selected_month_year'] ?? ''}';
            _selectedMapelId = data['selected_mapel_id'] != null
                ? int.tryParse('${data['selected_mapel_id']}')
                : null;
            _isFirstLoad = false;
          }

          _availableMonthsList = monthsList;
          _isSingleMapel = data['is_single_mapel'] == true;
          _availableMapels = mapels;
          _allTeachingClasses = allClasses;

          _totalSesi = int.tryParse('${summary?['total_sesi'] ?? 0}') ?? 0;
          _totalJp = int.tryParse('${summary?['total_jp'] ?? 0}') ?? 0;

          _jurnals = jurnals;
          _currentPage = int.tryParse('${meta?['current_page'] ?? 1}') ?? 1;
          _lastPage = int.tryParse('${meta?['last_page'] ?? 1}') ?? 1;
          _totalItems = int.tryParse('${meta?['total'] ?? 0}') ?? 0;

          if (analyticsRaw != null) {
            _analyticsTotals = Map<String, dynamic>.from(
              analyticsRaw['totals'] as Map? ?? {},
            );
            _classesSummary =
                (analyticsRaw['classes_summary'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
            _studentsSummary =
                (analyticsRaw['students_summary'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
          }
        });

        // Jika endpoint backend belum mengirimkan field `analytics`, hitung otomatis dari detail sesi
        if (analyticsRaw == null) {
          await _buildClientSideAnalyticsFallback();
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memuat daftar jurnal mengajar: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Fallback pembangun data Analisa Kelas & Siswa jika API backend belum menyertakan field `analytics`
  Future<void> _buildClientSideAnalyticsFallback() async {
    if (!mounted) return;
    setState(() => _isAnalyticsLoading = true);

    try {
      // Ambil semua jurnal untuk periode & mapel aktif (tanpa filter class_id agar chip kelas tetap lengkap)
      final allRes = await _dio.get(
        '/guru/jurnal-mengajar',
        queryParameters: {
          'page': 1,
          'per_page': 50,
          'identifier': ?widget.identifier,
          'month_year': _selectedMonthYear.isEmpty ? 'all' : _selectedMonthYear,
          if (_selectedTeacherId != null && _selectedTeacherId!.isNotEmpty)
            'teacher_id': _selectedTeacherId,
          'mata_pelajaran_id': ?_selectedMapelId,
        },
      );

      final body = allRes.data;
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
      final allJurnals = (data['jurnals'] as List? ?? _jurnals)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // Ambil detail presensi tiap sesi jurnal secara paralel
      final detailResponses = await Future.wait(
        allJurnals.map((j) async {
          try {
            final id = '${j['id']}';
            final r = await _dio.get(
              '/guru/jurnal-mengajar/$id',
              queryParameters: {'identifier': ?widget.identifier},
            );
            final rBody = r.data;
            if (rBody is Map && rBody['data'] is Map) {
              return Map<String, dynamic>.from(rBody['data'] as Map);
            }
          } catch (_) {}
          return <String, dynamic>{'jurnal': j, 'students': <dynamic>[]};
        }),
      );

      final overallTotals = <String, int>{
        'total_sesi': 0,
        'total_jp': 0,
        'hadir': 0,
        'izin': 0,
        'sakit': 0,
        'izin_sakit': 0,
        'alpa': 0,
        'tidak_mengikuti': 0,
        'total_absen': 0,
      };

      final classesMap = <String, Map<String, dynamic>>{};
      for (final tc in _filteredClassesForSelectedMapel) {
        final cid = '${tc['id'] ?? ''}';
        if (cid.isNotEmpty && !classesMap.containsKey(cid)) {
          classesMap[cid] = {
            'class_id': cid,
            'class_name': '${tc['name'] ?? '-'}',
            'total_sesi': 0,
            'total_jp': 0,
            'hadir': 0,
            'izin': 0,
            'sakit': 0,
            'izin_sakit': 0,
            'alpa': 0,
            'tidak_mengikuti': 0,
            'total_absen': 0,
            'siswa_pernah_absen_count': 0,
          };
        }
      }

      final studentsMap = <String, Map<String, dynamic>>{};

      for (final item in detailResponses) {
        final j = Map<String, dynamic>.from(item['jurnal'] as Map? ?? {});
        final students = (item['students'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        final cid = '${j['class_id'] ?? ''}';
        final cname = '${j['class_name'] ?? '-'}';
        final jp = int.tryParse('${j['durasi_jp'] ?? 0}') ?? 0;
        final jurnalId = '${j['id'] ?? ''}';
        final tanggal = '${j['tanggal'] ?? '-'}';
        final tanggalFormatted = '${j['tanggal_formatted'] ?? tanggal}';
        final jamKeLabel = '${j['jam_ke_label'] ?? ''}';
        final mapelName = '${j['mata_pelajaran_name'] ?? '-'}';
        final materi = '${j['materi'] ?? '-'}';

        overallTotals['total_sesi'] = (overallTotals['total_sesi'] ?? 0) + 1;
        overallTotals['total_jp'] = (overallTotals['total_jp'] ?? 0) + jp;

        classesMap.putIfAbsent(
          cid,
          () => {
            'class_id': cid,
            'class_name': cname,
            'total_sesi': 0,
            'total_jp': 0,
            'hadir': 0,
            'izin': 0,
            'sakit': 0,
            'izin_sakit': 0,
            'alpa': 0,
            'tidak_mengikuti': 0,
            'total_absen': 0,
            'siswa_pernah_absen_count': 0,
          },
        );
        classesMap[cid]!['total_sesi'] =
            (classesMap[cid]!['total_sesi'] as int) + 1;
        classesMap[cid]!['total_jp'] =
            (classesMap[cid]!['total_jp'] as int) + jp;

        for (final s in students) {
          final sid = '${s['student_id'] ?? ''}';
          if (sid.isEmpty) continue;

          final statusJurnal = '${s['status_jurnal'] ?? ''}'.toLowerCase();
          final statusGerbang = '${s['status_gerbang'] ?? ''}'.toLowerCase();

          String normStatus = 'hadir';
          String statusLabel = 'Hadir';
          if (statusJurnal == 'tidak_mengikuti') {
            if (statusGerbang == 'sakit') {
              normStatus = 'sakit';
              statusLabel = 'Sakit';
            } else if (statusGerbang == 'izin') {
              normStatus = 'izin';
              statusLabel = 'Izin';
            } else if (statusGerbang == 'alpa') {
              normStatus = 'alpa';
              statusLabel = 'Alpa';
            } else {
              normStatus = 'tidak_mengikuti';
              statusLabel = 'Tidak Mengikuti';
            }
          }

          overallTotals[normStatus] = (overallTotals[normStatus] ?? 0) + 1;
          classesMap[cid]![normStatus] =
              (classesMap[cid]![normStatus] as int) + 1;

          final stKey = '${cid}_$sid';
          studentsMap.putIfAbsent(
            stKey,
            () => {
              'student_id': sid,
              'student_name': '${s['name'] ?? 'Siswa'}',
              'nis': '${s['nis'] ?? '-'}',
              'class_id': cid,
              'class_name': cname,
              'total_pertemuan': 0,
              'hadir': 0,
              'izin': 0,
              'sakit': 0,
              'izin_sakit': 0,
              'alpa': 0,
              'tidak_mengikuti': 0,
              'total_absen': 0,
              'absence_logs': <Map<String, dynamic>>[],
            },
          );

          final st = studentsMap[stKey]!;
          st['total_pertemuan'] = (st['total_pertemuan'] as int) + 1;
          st[normStatus] = (st[normStatus] as int) + 1;

          if (normStatus != 'hadir') {
            (st['absence_logs'] as List<Map<String, dynamic>>).add({
              'jurnal_id': jurnalId,
              'tanggal': tanggal,
              'tanggal_formatted': tanggalFormatted,
              'jam_ke_label': jamKeLabel,
              'mata_pelajaran_name': mapelName,
              'materi': materi,
              'status': normStatus,
              'status_label': statusLabel,
              'status_gerbang': statusGerbang,
              'keterangan': '${s['keterangan'] ?? ''}',
            });
          }
        }
      }

      overallTotals['izin_sakit'] =
          (overallTotals['izin'] ?? 0) + (overallTotals['sakit'] ?? 0);
      overallTotals['total_absen'] =
          (overallTotals['izin_sakit'] ?? 0) +
          (overallTotals['alpa'] ?? 0) +
          (overallTotals['tidak_mengikuti'] ?? 0);

      final studentsList = studentsMap.values.toList();
      for (final st in studentsList) {
        final iz = st['izin'] as int;
        final sk = st['sakit'] as int;
        final al = st['alpa'] as int;
        final tk = st['tidak_mengikuti'] as int;
        st['izin_sakit'] = iz + sk;
        st['total_absen'] = iz + sk + al + tk;
        final cid = '${st['class_id']}';
        if ((st['total_absen'] as int) > 0 && classesMap.containsKey(cid)) {
          classesMap[cid]!['siswa_pernah_absen_count'] =
              (classesMap[cid]!['siswa_pernah_absen_count'] as int) + 1;
        }
      }

      for (final cm in classesMap.values) {
        final iz = cm['izin'] as int;
        final sk = cm['sakit'] as int;
        final al = cm['alpa'] as int;
        final tk = cm['tidak_mengikuti'] as int;
        cm['izin_sakit'] = iz + sk;
        cm['total_absen'] = iz + sk + al + tk;
      }

      studentsList.sort((a, b) {
        final tkCmp = (b['tidak_mengikuti'] as int).compareTo(
          a['tidak_mengikuti'] as int,
        );
        if (tkCmp != 0) return tkCmp;
        final alCmp = (b['alpa'] as int).compareTo(a['alpa'] as int);
        if (alCmp != 0) return alCmp;
        final abCmp = (b['total_absen'] as int).compareTo(
          a['total_absen'] as int,
        );
        if (abCmp != 0) return abCmp;
        return '${a['student_name']}'.toLowerCase().compareTo(
          '${b['student_name']}'.toLowerCase(),
        );
      });

      final classesList = classesMap.values.toList()
        ..sort(
          (a, b) => '${a['class_name']}'.compareTo('${b['class_name']}'),
        );

      if (mounted) {
        setState(() {
          _analyticsTotals = overallTotals;
          _classesSummary = classesList;
          _studentsSummary = studentsList;
        });
      }
    } catch (_) {
      // Abaikan jika gagal memuat rincian fallback
    } finally {
      if (mounted) {
        setState(() => _isAnalyticsLoading = false);
      }
    }
  }

  Future<void> _openCreateOrEditForm({String? jurnalId}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormJurnalMengajarScreen(
          teacherName: _currentTeacherName,
          token: widget.token,
          identifier: widget.identifier,
          jurnalId: jurnalId,
        ),
      ),
    );

    if (saved == true) {
      await _fetchJurnals(page: _currentPage);
    }
  }

  Future<void> _confirmDeleteJurnal(Map<String, dynamic> jurnal) async {
    final id = '${jurnal['id']}';
    final tanggalFormatted =
        '${jurnal['tanggal_formatted'] ?? jurnal['tanggal']}';
    final materi = '${jurnal['materi'] ?? '-'}';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppColors.alpa),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hapus Jurnal Mengajar?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          'Yakin ingin menghapus catatan jurnal "$materi" pada $tanggalFormatted?',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alpa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Ya, Hapus',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final res = await _dio.delete(
        '/guru/jurnal-mengajar/$id',
        queryParameters: {'identifier': ?widget.identifier},
      );
      final body = res.data;
      final msg = (body is Map && body['message'] != null)
          ? '${body['message']}'
          : 'Jurnal mengajar berhasil dihapus.';
      _showSnackBar(msg);
      await _fetchJurnals(page: _currentPage);
    } catch (e) {
      _showSnackBar('Gagal menghapus jurnal: $e', isError: true);
    }
  }

  void _openCetakModal() {
    DialogCetakJurnalPeriode.show(
      context,
      currentMonthYear: _selectedMonthYear,
      availableMonthsList: _availableMonthsList,
      currentMapelId: _selectedMapelId,
      availableMapels: _availableMapels,
      currentClassId: _selectedClassId,
      allTeachingClasses: _allTeachingClasses,
      currentTeacherName: _currentTeacherName,
      onExport: _downloadExport,
    );
  }

  Future<void> _downloadExport({
    required String format,
    required String jenis,
    required String monthYear,
    required String semester,
    int? mapelId,
    String? classId,
  }) async {
    final params = <String, String>{
      'format': format,
      'jenis': jenis,
      'month_year': monthYear,
      'semester': semester,
      if (_academicYearId.isNotEmpty) 'academic_year_id': _academicYearId,
      'teacher_id': ?_selectedTeacherId,
      if (mapelId != null) 'mata_pelajaran_id': '$mapelId',
      'class_id': ?classId,
      'identifier': ?widget.identifier,
      'token': ?widget.token,
    };

    final uri = Uri.parse(
      '${AppConfig.baseUrl}/guru/jurnal-mengajar/export',
    ).replace(queryParameters: params);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showSnackBar('Gagal membuka tautan unduhan laporan.', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal mengunduh laporan: $e', isError: true);
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
    final classesForMapel = _filteredClassesForSelectedMapel;
    final totalAbsenAll =
        int.tryParse('${_analyticsTotals['total_absen'] ?? 0}') ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _indigoPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jurnal Mengajar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              '${widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName} • TA $_academicYearName',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openCetakModal,
            tooltip: 'Cetak Laporan KBM',
            icon: const Icon(Icons.print_rounded),
          ),
          IconButton(
            onPressed: () => _fetchJurnals(page: _currentPage),
            tooltip: 'Muat Ulang',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.menu_book_rounded, size: 18),
              text: 'Riwayat Jurnal',
            ),
            Tab(
              icon: Icon(Icons.analytics_outlined, size: 18),
              text: 'Analisa Kelas & Siswa',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateOrEditForm(),
        backgroundColor: _indigoPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Tulis Jurnal',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: RIWAYAT JURNAL MENGAJAR
          RefreshIndicator(
            color: _indigoPrimary,
            onRefresh: () => _fetchJurnals(page: 1),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 84),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JurnalFilterCard(
                    academicYearName: _academicYearName,
                    isSupervisor: _isSupervisor,
                    teachers: _teachers,
                    selectedTeacherId: _selectedTeacherId,
                    onTeacherChanged: (val) {
                      setState(() {
                        _selectedTeacherId = val;
                        _selectedMapelId = null;
                        _selectedClassId = null;
                      });
                      _fetchJurnals(page: 1);
                    },
                    availableMonthsList: _availableMonthsList,
                    selectedMonthYear: _selectedMonthYear,
                    onMonthChanged: (val) {
                      setState(() => _selectedMonthYear = val ?? '');
                      _fetchJurnals(page: 1);
                    },
                    isSingleMapel: _isSingleMapel,
                    availableMapels: _availableMapels,
                    selectedMapelId: _selectedMapelId,
                    onMapelChanged: (val) {
                      setState(() {
                        _selectedMapelId = val;
                        _selectedClassId = null;
                      });
                      _fetchJurnals(page: 1);
                    },
                    classesForMapel: classesForMapel,
                    selectedClassId: _selectedClassId,
                    onClassChanged: (val) {
                      setState(() => _selectedClassId = val);
                      _fetchJurnals(page: 1);
                    },
                    searchController: _searchController,
                    onSearchSubmitted: (val) {
                      setState(() => _searchQuery = val.trim());
                      _fetchJurnals(page: 1);
                    },
                    onSearchCleared: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      _fetchJurnals(page: 1);
                    },
                    onSearchIconPressed: () {
                      setState(
                        () => _searchQuery = _searchController.text.trim(),
                      );
                      _fetchJurnals(page: 1);
                    },
                  ),
                  const SizedBox(height: 12),
                  JurnalCompactSummaryBar(
                    totalSesi: _totalSesi,
                    totalJp: _totalJp,
                    totalTidakHadir: totalAbsenAll,
                    onOpenAnalisaTab: () => _tabController.animateTo(1),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: CircularProgressIndicator(color: _indigoPrimary),
                      ),
                    )
                  else if (_jurnals.isEmpty)
                    JurnalEmptyState(
                      onTulisJurnal: () => _openCreateOrEditForm(),
                    )
                  else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _jurnals.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final j = _jurnals[idx];
                        return JurnalItemCard(
                          jurnal: j,
                          isSupervisor: _isSupervisor,
                          onDetail: () => SheetDetailJurnalKbm.show(
                            context,
                            dio: _dio,
                            jurnal: j,
                            identifier: widget.identifier,
                          ),
                          onEdit: () => _openCreateOrEditForm(
                            jurnalId: '${j['id']}',
                          ),
                          onDelete: () => _confirmDeleteJurnal(j),
                        );
                      },
                    ),
                    if (_lastPage > 1) ...[
                      const SizedBox(height: 16),
                      JurnalPaginationBar(
                        currentPage: _currentPage,
                        lastPage: _lastPage,
                        totalItems: _totalItems,
                        onPageChanged: (p) => _fetchJurnals(page: p),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // TAB 2: ANALISA KELAS & KEHADIRAN SISWA
          RefreshIndicator(
            color: _indigoPrimary,
            onRefresh: () => _fetchJurnals(page: 1),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 84),
              child: JurnalAnalisaSection(
                academicYearName: _academicYearName,
                isSupervisor: _isSupervisor,
                teachers: _teachers,
                selectedTeacherId: _selectedTeacherId,
                onTeacherChanged: (val) {
                  setState(() {
                    _selectedTeacherId = val;
                    _selectedMapelId = null;
                    _selectedClassId = null;
                  });
                  _fetchJurnals(page: 1);
                },
                availableMonthsList: _availableMonthsList,
                selectedMonthYear: _selectedMonthYear,
                onMonthChanged: (val) {
                  setState(() => _selectedMonthYear = val ?? '');
                  _fetchJurnals(page: 1);
                },
                isSingleMapel: _isSingleMapel,
                availableMapels: _availableMapels,
                selectedMapelId: _selectedMapelId,
                onMapelChanged: (val) {
                  setState(() {
                    _selectedMapelId = val;
                    _selectedClassId = null;
                  });
                  _fetchJurnals(page: 1);
                },
                selectedClassId: _selectedClassId,
                onClassChanged: (val) {
                  setState(() => _selectedClassId = val);
                  _fetchJurnals(page: 1);
                },
                isLoading: _isLoading,
                isAnalyticsLoading: _isAnalyticsLoading,
                overallTotals: _analyticsTotals,
                classesSummary: _classesSummary,
                studentsSummary: _studentsSummary,
                onOpenJurnalById: (jurnalId) {
                  SheetDetailJurnalKbm.show(
                    context,
                    dio: _dio,
                    jurnal: {'id': jurnalId},
                    identifier: widget.identifier,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
