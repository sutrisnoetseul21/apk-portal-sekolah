import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import 'form_jurnal_mengajar_screen.dart';
import 'widgets/jurnal_mengajar/cards/jurnal_item_card.dart';
import 'widgets/jurnal_mengajar/modals/dialog_cetak_jurnal_periode.dart';
import 'widgets/jurnal_mengajar/modals/sheet_detail_jurnal_kbm.dart';
import 'widgets/jurnal_mengajar/sections/jurnal_empty_state.dart';
import 'widgets/jurnal_mengajar/sections/jurnal_filter_card.dart';
import 'widgets/jurnal_mengajar/sections/jurnal_hero_banner.dart';
import 'widgets/jurnal_mengajar/sections/jurnal_pagination_bar.dart';
import 'widgets/jurnal_mengajar/sections/jurnal_summary_metrics_row.dart';

/// Halaman Menu 3: Jurnal Mengajar (/portal-guru/jurnal-mengajar)
/// Mengikuti 100% desain & alur bisnis JurnalMengajarList.php
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

class _JurnalMengajarScreenState extends State<JurnalMengajarScreen> {
  late final Dio _dio;

  bool _isLoading = true;
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
  double _rataKehadiran = 0.0;

  // Daftar Jurnal & Pagination
  List<Map<String, dynamic>> _jurnals = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;

  // Tema Warna Indigo-Purple Jurnal Mengajar
  static const Color _indigoPrimary = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
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
          _rataKehadiran =
              double.tryParse('${summary?['rata_kehadiran'] ?? 0}') ?? 0.0;

          _jurnals = jurnals;
          _currentPage = int.tryParse('${meta?['current_page'] ?? 1}') ?? 1;
          _lastPage = int.tryParse('${meta?['last_page'] ?? 1}') ?? 1;
          _totalItems = int.tryParse('${meta?['total'] ?? 0}') ?? 0;
        });
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
            onPressed: () => _fetchJurnals(page: _currentPage),
            tooltip: 'Muat Ulang',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _indigoPrimary,
        onRefresh: () => _fetchJurnals(page: 1),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JurnalHeroBanner(
                isSupervisor: _isSupervisor,
                onTulisJurnal: () => _openCreateOrEditForm(),
                onCetakLaporan: _openCetakModal,
              ),
              const SizedBox(height: 16),
              JurnalSummaryMetricsRow(
                totalSesi: _totalSesi,
                totalJp: _totalJp,
                rataKehadiran: _rataKehadiran,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
