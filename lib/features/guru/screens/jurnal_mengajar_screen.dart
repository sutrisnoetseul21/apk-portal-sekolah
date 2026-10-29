import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import 'form_jurnal_mengajar_screen.dart';

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
    this.schoolName = 'SMP Negeri 3 Kedungreja',
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
  static const Color _indigoDark = Color(0xFF3730A3);
  static const Color _purpleAccent = Color(0xFF7C3AED);

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

  Future<void> _showJurnalDetailSheet(Map<String, dynamic> jurnal) async {
    final id = '${jurnal['id']}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.5,
          maxChildSize: 0.94,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: FutureBuilder<Response<dynamic>>(
                future: _dio.get(
                  '/guru/jurnal-mengajar/$id',
                  queryParameters: {'identifier': ?widget.identifier},
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _indigoPrimary),
                    );
                  }
                  if (snapshot.hasError || snapshot.data?.data == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Gagal memuat detail presensi sesi KBM: ${snapshot.error ?? ''}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final body = snapshot.data!.data as Map;
                  final data = Map<String, dynamic>.from(
                    body['data'] as Map? ?? {},
                  );
                  final detail = Map<String, dynamic>.from(
                    data['jurnal'] as Map? ?? jurnal,
                  );
                  final students = (data['students'] as List? ?? [])
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList();

                  return Column(
                    children: [
                      // Header Modal
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 14, 16, 16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_indigoPrimary, _purpleAccent],
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(26),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${detail['materi'] ?? '-'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${detail['tanggal_formatted'] ?? detail['tanggal']} • ${detail['jam_ke_label'] ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(18),
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildBadgePill(
                                  '🎓 Kelas ${detail['class_name'] ?? '-'}',
                                  const Color(0xFFECFDF5),
                                  const Color(0xFF065F46),
                                ),
                                _buildBadgePill(
                                  '📖 ${detail['mata_pelajaran_name'] ?? '-'}',
                                  const Color(0xFFEEF2FF),
                                  _indigoPrimary,
                                ),
                                _buildBadgePill(
                                  '👥 Hadir: ${detail['total_hadir']}/${detail['total_siswa']} (${detail['persentase_kehadiran']}%)',
                                  const Color(0xFFF0FDF4),
                                  const Color(0xFF15803D),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'URAIAN AKTIVITAS KBM:',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${detail['uraian_materi'] ?? '-'}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if ('${detail['refleksi'] ?? ''}'
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'REFLEKSI / TINDAK LANJUT GURU:',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${detail['refleksi']}',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF78350F),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            Text(
                              'RINCIAN KEHADIRAN SISWA (${students.length} Siswa)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...students.asMap().entries.map((entry) {
                              final s = entry.value;
                              final isHadir = '${s['status_jurnal']}' == 'hadir';
                              final ket = '${s['keterangan'] ?? ''}'.trim();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isHadir
                                      ? Colors.white
                                      : const Color(0xFFFFF1F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isHadir
                                        ? AppColors.border
                                        : const Color(0xFFFECDD3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${entry.key + 1}.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${s['name'] ?? '-'}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (ket.isNotEmpty)
                                            Text(
                                              ket,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFFBE123C),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isHadir
                                            ? const Color(0xFFECFDF5)
                                            : const Color(0xFFFFE4E6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isHadir
                                            ? '✓ Hadir KBM'
                                            : '✕ Tidak Mengikuti',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          color: isHadir
                                              ? const Color(0xFF047857)
                                              : const Color(0xFFBE123C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _openCetakModal() {
    String cetakJenis = 'bulanan'; // bulanan | semester | tahunan
    String cetakBulanYear = _selectedMonthYear.isNotEmpty
        ? _selectedMonthYear
        : (_availableMonthsList.isNotEmpty
              ? '${_availableMonthsList.first['key']}'
              : '');
    String cetakSemester = DateTime.now().month >= 7 ? 'ganjil' : 'genap';
    int? cetakMapelId =
        _selectedMapelId ??
        (_availableMapels.length == 1
            ? int.tryParse('${_availableMapels.first['id']}')
            : null);
    String? cetakClassId = _selectedClassId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final classesForModalMapel = <Map<String, dynamic>>[];
            if (cetakMapelId != null) {
              final seen = <String>{};
              for (final c in _allTeachingClasses) {
                final mId = int.tryParse('${c['mata_pelajaran_id']}');
                final cId = '${c['id']}';
                if (mId == cetakMapelId && !seen.contains(cId)) {
                  seen.add(cId);
                  classesForModalMapel.add(c);
                }
              }
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_indigoPrimary, _purpleAccent],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.print_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cetak Rekap Jurnal Mengajar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Pilih periode dan target kelas KBM yang ingin dicetak',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
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
                          const Text(
                            '1. PILIH PERIODE LAPORAN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildPeriodeRadioCard(
                                title: 'Bulanan',
                                subtitle: 'Per Bulan',
                                isSelected: cetakJenis == 'bulanan',
                                onTap: () =>
                                    setModalState(() => cetakJenis = 'bulanan'),
                              ),
                              const SizedBox(width: 8),
                              _buildPeriodeRadioCard(
                                title: 'Semester',
                                subtitle: 'Ganjil / Genap',
                                isSelected: cetakJenis == 'semester',
                                onTap: () => setModalState(
                                  () => cetakJenis = 'semester',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildPeriodeRadioCard(
                                title: 'Tahunan',
                                subtitle: '1 Tahun Ajaran',
                                isSelected: cetakJenis == 'tahunan',
                                onTap: () =>
                                    setModalState(() => cetakJenis = 'tahunan'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          if (cetakJenis == 'bulanan' &&
                              _availableMonthsList.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _indigoPrimary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _indigoPrimary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PILIH BULAN KBM',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      color: _indigoPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value:
                                            _availableMonthsList.any(
                                              (m) =>
                                                  '${m['key']}' ==
                                                  cetakBulanYear,
                                            )
                                            ? cetakBulanYear
                                            : '${_availableMonthsList.first['key']}',
                                        isExpanded: true,
                                        items: _availableMonthsList.map((m) {
                                          return DropdownMenuItem<String>(
                                            value: '${m['key']}',
                                            child: Text(
                                              '${m['label']}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setModalState(
                                              () => cetakBulanYear = val,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (cetakJenis == 'semester')
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _indigoPrimary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _indigoPrimary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setModalState(
                                        () => cetakSemester = 'ganjil',
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: cetakSemester == 'ganjil'
                                              ? _indigoPrimary
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          'Semester Ganjil',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: cetakSemester == 'ganjil'
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setModalState(
                                        () => cetakSemester = 'genap',
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: cetakSemester == 'genap'
                                              ? _indigoPrimary
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          'Semester Genap',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: cetakSemester == 'genap'
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),
                          const Text(
                            '2. SASARAN CETAK (GURU • MAPEL • KELAS)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Guru Pengampu Paten
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: _indigoPrimary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'GURU PENGAMPU',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        _currentTeacherName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
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
                                    'Paten',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Pilih Mapel Cetak
                          const Text(
                            'Mata Pelajaran',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int?>(
                                value: cetakMapelId,
                                isExpanded: true,
                                items: [
                                  if (_availableMapels.length > 1)
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(
                                        '-- Semua Mata Pelajaran --',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ..._availableMapels.map((m) {
                                    final mId = int.tryParse('${m['id']}');
                                    return DropdownMenuItem<int?>(
                                      value: mId,
                                      child: Text(
                                        '${m['nama_mapel']}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  setModalState(() {
                                    cetakMapelId = val;
                                    cetakClassId = null;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Pilih Kelas Rombel Cetak
                          const Text(
                            'Kelas Rombel',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: cetakMapelId == null
                                  ? const Color(0xFFF1F5F9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value:
                                    classesForModalMapel.any(
                                      (c) => '${c['id']}' == cetakClassId,
                                    )
                                    ? cetakClassId
                                    : null,
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text(
                                      cetakMapelId == null
                                          ? '-- Pilih Mapel Terlebih Dahulu --'
                                          : '-- Semua Kelas Rombel --',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ...classesForModalMapel.map((c) {
                                    return DropdownMenuItem<String?>(
                                      value: '${c['id']}',
                                      child: Text(
                                        '${c['name']}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: cetakMapelId == null
                                    ? null
                                    : (val) => setModalState(
                                        () => cetakClassId = val,
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Tombol Unduh Excel & Cetak PDF
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    _downloadExport(
                                      format: 'excel',
                                      jenis: cetakJenis,
                                      monthYear: cetakBulanYear,
                                      semester: cetakSemester,
                                      mapelId: cetakMapelId,
                                      classId: cetakClassId,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF059669),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.table_view_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Unduh Excel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    _downloadExport(
                                      format: 'pdf',
                                      jenis: cetakJenis,
                                      monthYear: cetakBulanYear,
                                      semester: cetakSemester,
                                      mapelId: cetakMapelId,
                                      classId: cetakClassId,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE11D48),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Cetak PDF',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
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
          },
        );
      },
    );
  }

  Widget _buildPeriodeRadioCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _indigoPrimary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _indigoPrimary : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? _indigoPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
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
              '${widget.schoolName} • TA $_academicYearName',
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
              _buildHeroBanner(),
              const SizedBox(height: 16),
              _buildSummaryMetricsRow(),
              const SizedBox(height: 16),
              _buildFilterCard(),
              const SizedBox(height: 16),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: _indigoPrimary),
                  ),
                )
              else if (_jurnals.isEmpty)
                _buildEmptyState()
              else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _jurnals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) =>
                      _buildJurnalItemCard(_jurnals[idx]),
                ),
                if (_lastPage > 1) ...[
                  const SizedBox(height: 16),
                  _buildPaginationBar(),
                ],
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_indigoPrimary, _indigoDark, _purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _indigoPrimary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                  color: Colors.white.withValues(alpha: 0.15),
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
                      'PORTAL GURU • KBM & AGENDA MENGAJAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSupervisor)
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
                    'Mode Supervisi Kepala Sekolah',
                    style: TextStyle(
                      color: Color(0xFFFEF3C7),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jurnal Mengajar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Dokumentasikan agenda pembelajaran harian, durasi JP, materi pokok, dan sinkronisasi kehadiran siswa.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openCreateOrEditForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _indigoPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Tulis Jurnal Baru',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _openCetakModal,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.print_outlined, size: 17),
                label: const Text(
                  'Cetak Laporan KBM',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetricsRow() {
    return Row(
      children: [
        // Card 1: Total Sesi KBM
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _indigoPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: _indigoPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'TOTAL SESI KBM',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_totalSesi Sesi',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Card 2: Total JP
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: Color(0xFF059669),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'TOTAL JAM PELAJARAN',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_totalJp JP',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Card 3: Rata-rata Kehadiran
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _purpleAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 18,
                    color: _purpleAccent,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'RATA KEHADIRAN',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_rataKehadiran%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterCard() {
    final classesForMapel = _filteredClassesForSelectedMapel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: 17,
                    color: _indigoPrimary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Filter & Pencarian Jurnal',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 7, color: Color(0xFF10B981)),
                    const SizedBox(width: 5),
                    Text(
                      'TA: $_academicYearName',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22),

          if (_isSupervisor && _teachers.isNotEmpty) ...[
            const Text(
              'GURU PENGAMPU (MODE SUPERVISI)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF92400E),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:
                      _teachers.any((t) => '${t['id']}' == _selectedTeacherId)
                      ? _selectedTeacherId
                      : '${_teachers.first['id']}',
                  isExpanded: true,
                  items: _teachers.map((t) {
                    return DropdownMenuItem<String>(
                      value: '${t['id']}',
                      child: Text(
                        '${t['name']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedTeacherId = val;
                      _selectedMapelId = null;
                      _selectedClassId = null;
                    });
                    _fetchJurnals(page: 1);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Baris Bulan KBM & Mata Pelajaran
          Row(
            children: [
              // Bulan KBM
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BULAN KBM',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              _availableMonthsList.any(
                                (m) => '${m['key']}' == _selectedMonthYear,
                              )
                              ? _selectedMonthYear
                              : '',
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text(
                                'Semua Bulan',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ..._availableMonthsList.map((m) {
                              return DropdownMenuItem<String>(
                                value: '${m['key']}',
                                child: Text(
                                  '${m['label']}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedMonthYear = val ?? '');
                            _fetchJurnals(page: 1);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Mata Pelajaran
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MATA PELAJARAN',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value:
                              _availableMapels.any(
                                (m) =>
                                    int.tryParse('${m['id']}') ==
                                    _selectedMapelId,
                              )
                              ? _selectedMapelId
                              : null,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                'Semua Mapel',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ..._availableMapels.map((m) {
                              final mId = int.tryParse('${m['id']}');
                              return DropdownMenuItem<int?>(
                                value: mId,
                                child: Text(
                                  '${m['nama_mapel']}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: _isSingleMapel
                              ? null
                              : (val) {
                                  setState(() {
                                    _selectedMapelId = val;
                                    _selectedClassId = null;
                                  });
                                  _fetchJurnals(page: 1);
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Kelas Rombel (Dependent)
          const Text(
            'KELAS ROMBEL',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _selectedMapelId == null
                  ? const Color(0xFFF1F5F9)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value:
                    classesForMapel.any((c) => '${c['id']}' == _selectedClassId)
                    ? _selectedClassId
                    : null,
                isExpanded: true,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      _selectedMapelId == null
                          ? '-- Pilih Mapel Terlebih Dahulu --'
                          : '-- Semua Kelas Rombel --',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _selectedMapelId == null
                            ? const Color(0xFF94A3B8)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...classesForMapel.map((c) {
                    return DropdownMenuItem<String?>(
                      value: '${c['id']}',
                      child: Text(
                        '${c['name']}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: _selectedMapelId == null
                    ? null
                    : (val) {
                        setState(() => _selectedClassId = val);
                        _fetchJurnals(page: 1);
                      },
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cari Materi / Refleksi
          TextField(
            controller: _searchController,
            onSubmitted: (val) {
              setState(() => _searchQuery = val.trim());
              _fetchJurnals(page: 1);
            },
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Ketik kata kunci topik materi atau refleksi...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: _indigoPrimary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _fetchJurnals(page: 1);
                      },
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: _indigoPrimary,
                      ),
                      onPressed: () {
                        setState(
                          () => _searchQuery = _searchController.text.trim(),
                        );
                        _fetchJurnals(page: 1);
                      },
                    ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJurnalItemCard(Map<String, dynamic> jurnal) {
    final tanggalFormatted =
        '${jurnal['tanggal_formatted'] ?? jurnal['tanggal']}';
    final jamKeLabel = '${jurnal['jam_ke_label'] ?? ''}';
    final className = '${jurnal['class_name'] ?? '-'}';
    final mapelName = '${jurnal['mata_pelajaran_name'] ?? '-'}';
    final teacherName = '${jurnal['teacher_name'] ?? '-'}';
    final materi = '${jurnal['materi'] ?? '-'}';
    final uraian = '${jurnal['uraian_materi'] ?? '-'}';
    final refleksi = '${jurnal['refleksi'] ?? ''}'.trim();
    final totalSiswa = int.tryParse('${jurnal['total_siswa'] ?? 0}') ?? 0;
    final totalHadir = int.tryParse('${jurnal['total_hadir'] ?? 0}') ?? 0;
    final totalTidakMengikuti =
        int.tryParse('${jurnal['total_tidak_mengikuti'] ?? 0}') ?? 0;
    final persentase = '${jurnal['persentase_kehadiran'] ?? 0}';
    final canEdit = jurnal['can_edit'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Badges Header
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadgePill(
                '📅 $tanggalFormatted',
                const Color(0xFFF1F5F9),
                const Color(0xFF1E293B),
              ),
              _buildBadgePill(
                '⏰ $jamKeLabel',
                _indigoPrimary.withValues(alpha: 0.1),
                _indigoPrimary,
              ),
              _buildBadgePill(
                '🎓 Kelas $className',
                const Color(0xFFECFDF5),
                const Color(0xFF065F46),
              ),
              _buildBadgePill(
                '📖 $mapelName',
                _purpleAccent.withValues(alpha: 0.1),
                _purpleAccent,
              ),
              if (_isSupervisor && teacherName.isNotEmpty)
                _buildBadgePill(
                  '👤 $teacherName',
                  const Color(0xFFFFFBEB),
                  const Color(0xFF92400E),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Materi Pokok
          Text(
            materi,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Uraian Aktivitas KBM
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(
              uraian,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                height: 1.45,
              ),
            ),
          ),

          // Refleksi Guru jika ada
          if (refleksi.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF334155),
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Refleksi / Catatan Tindak Lanjut: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF78350F),
                            ),
                          ),
                          TextSpan(text: refleksi),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 24),

          // Footer: Kehadiran & Tombol Aksi
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TINGKAT KEHADIRAN',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '$totalHadir/$totalSiswa',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($persentase%)',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: totalTidakMengikuti > 0
                                ? const Color(0xFFFFE4E6)
                                : const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            totalTidakMengikuti > 0
                                ? '$totalTidakMengikuti Tidak Hadir'
                                : '✓ Semua Hadir',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: totalTidakMengikuti > 0
                                  ? const Color(0xFF9F1239)
                                  : const Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol Detail Presensi Sesi
              IconButton(
                onPressed: () => _showJurnalDetailSheet(jurnal),
                tooltip: 'Lihat Detail Kehadiran Siswa',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Color(0xFF475569),
                ),
              ),

              if (canEdit) ...[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () =>
                      _openCreateOrEditForm(jurnalId: '${jurnal['id']}'),
                  tooltip: 'Edit Jurnal',
                  style: IconButton.styleFrom(
                    backgroundColor: _indigoPrimary.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: _indigoPrimary.withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: _indigoPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => _confirmDeleteJurnal(jurnal),
                  tooltip: 'Hapus Jurnal',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F2),
                    side: const BorderSide(color: Color(0xFFFECDD3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgePill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _indigoPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 30,
              color: _indigoPrimary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Catatan Jurnal Mengajar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Belum ada riwayat pembelajaran yang tercatat pada filter tahun ajaran, bulan, atau kelas yang dipilih.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openCreateOrEditForm(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _indigoPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Tulis Jurnal Baru Sekarang',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: _currentPage > 1
                ? () => _fetchJurnals(page: _currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 18),
            label: const Text('Sebelumnya', style: TextStyle(fontSize: 12)),
          ),
          Text(
            'Hal $_currentPage / $_lastPage ($_totalItems)',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          OutlinedButton.icon(
            onPressed: _currentPage < _lastPage
                ? () => _fetchJurnals(page: _currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: const Text('Berikutnya', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
