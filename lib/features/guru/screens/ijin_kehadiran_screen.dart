import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../models/leave_request_model.dart';
import '../services/ijin_kehadiran_service.dart';
import 'widgets/ijin/cards/leave_request_card.dart';
import 'widgets/ijin/modals/modal_detail_ijin.dart';
import 'widgets/ijin/sections/ijin_filter_card.dart';
import 'widgets/ijin/sections/ijin_metric_cards.dart';
import 'widgets/ijin/sections/ijin_pagination_bar.dart';
import 'widgets/ijin/sections/ijin_segmented_tabs.dart';

/// Halaman Menu 4: Persetujuan Ijin Siswa
/// Terintegrasi dengan IjinKehadiranService & LeaveRequestModel
class IjinKehadiranScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;

  const IjinKehadiranScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    this.schoolName = '',
  });

  @override
  State<IjinKehadiranScreen> createState() => _IjinKehadiranScreenState();
}

class _IjinKehadiranScreenState extends State<IjinKehadiranScreen> {
  late final IjinKehadiranService _service;

  bool _isLoading = true;
  // Default langsung diarahkan ke siswa yang menunggu persetujuan ('pending')
  String _activeTab = 'pending'; // 'pending', 'all', 'approved', 'rejected'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filters
  List<Map<String, dynamic>> _accessibleClasses = [];
  String? _selectedClassId;
  List<Map<String, dynamic>> _availableMonths = [];
  // Default 'all' (Semua Bulan) agar seluruh pengajuan pending lintas bulan langsung tampil
  String? _selectedMonthKey = 'all';

  // Stats & Info
  Map<String, dynamic> _todayStats = {
    'pending': 0,
    'approved': 0,
    'rejected': 0,
    'total': 0,
  };
  Map<String, dynamic> _userInfo = {
    'name': '',
    'is_wali_kelas': false,
    'is_bk': false,
    'role_summary': 'Wali Kelas',
  };
  Map<String, dynamic> _academicYear = {
    'id': null,
    'name': 'Tahun Ajaran Aktif',
  };

  // Data List
  List<LeaveRequestItemModel> _requests = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _service = IjinKehadiranService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectStatusTab(String tab) {
    setState(() {
      _activeTab = tab;
      // Saat berpindah ke tab 'Menunggu', pastikan tidak tersembunyi oleh filter bulan tunggal
      if (tab == 'pending') {
        _selectedMonthKey = 'all';
      }
    });
    _loadData(page: 1);
  }

  Future<void> _loadData({int page = 1}) async {
    setState(() => _isLoading = true);
    try {
      final res = await _service.getLeaveRequests(
        status: _activeTab,
        classId: _selectedClassId,
        month: _selectedMonthKey,
        search: _searchQuery,
        page: page,
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _requests = res.requests;
          _currentPage = res.currentPage;
          _lastPage = res.lastPage;
          _totalItems = res.total;
          _todayStats = {
            'pending': res.todayStats.pending,
            'approved': res.todayStats.approved,
            'rejected': res.todayStats.rejected,
            'total': res.todayStats.total,
          };
          _accessibleClasses = res.accessibleClasses;
          _availableMonths = res.availableMonths;
          _userInfo = res.userInfo;
          _academicYear = res.academicYear;

          _selectedMonthKey ??= 'all';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal memuat data: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openDetailModal(String recordId) {
    ModalDetailIjin.show(
      context,
      recordId: recordId,
      service: _service,
      onStatusChanged: () => _loadData(page: _currentPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = (_todayStats['pending'] as num?)?.toInt() ?? 0;
    final approvedCount = (_todayStats['approved'] as num?)?.toInt() ?? 0;
    final rejectedCount = (_todayStats['rejected'] as num?)?.toInt() ?? 0;

    final roleSummary = _userInfo['role_summary']?.toString() ?? 'Wali Kelas';
    final academicName =
        _academicYear['name']?.toString() ?? 'Tahun Ajaran Aktif';
    final schoolLabel =
        widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName;

    final String listTitle = switch (_activeTab) {
      'pending' => 'Menunggu Persetujuan ($_totalItems)',
      'approved' => 'Permohonan Disetujui ($_totalItems)',
      'rejected' => 'Permohonan Ditolak ($_totalItems)',
      _ => 'Semua Permohonan ($_totalItems)',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Persetujuan Ijin Siswa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '$schoolLabel • $academicName • $roleSummary',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () => _loadData(page: _currentPage),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(page: 1),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. METRIC SUMMARY CARDS
              IjinMetricCards(
                pendingCount: pendingCount,
                approvedCount: approvedCount,
                rejectedCount: rejectedCount,
                activeTab: _activeTab,
                onTabSelected: _selectStatusTab,
              ),

              const SizedBox(height: 14),

              // 2. SEGMENTED TABS FILTER (Menunggu di urutan pertama)
              IjinSegmentedTabs(
                activeTab: _activeTab,
                pendingCount: pendingCount,
                onTabChanged: _selectStatusTab,
              ),

              const SizedBox(height: 12),

              // 3. FILTER KELAS, BULAN & PENCARIAN SISWA
              IjinFilterCard(
                accessibleClasses: _accessibleClasses,
                selectedClassId: _selectedClassId,
                onClassChanged: (val) {
                  setState(() => _selectedClassId =
                      (val == null || val.isEmpty) ? null : val);
                  _loadData(page: 1);
                },
                availableMonths: _availableMonths,
                selectedMonthKey: _selectedMonthKey,
                onMonthChanged: (val) {
                  if (val != null && val != _selectedMonthKey) {
                    setState(() => _selectedMonthKey = val);
                    _loadData(page: 1);
                  }
                },
                searchController: _searchController,
                searchQuery: _searchQuery,
                onSearchSubmitted: (val) {
                  setState(() => _searchQuery = val);
                  _loadData(page: 1);
                },
                onSearchCleared: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                  _loadData(page: 1);
                },
              ),

              const SizedBox(height: 16),

              // 4. DAFTAR PERMOHONAN SISWA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    listTitle,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (_isLoading)
                    const SpinKitThreeBounce(
                      color: AppColors.primary,
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading && _requests.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: const Center(
                    child: SpinKitFadingCircle(
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                )
              else if (_requests.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final item = _requests[index];
                    return LeaveRequestCard(
                      item: item,
                      onTap: () => _openDetailModal(item.id),
                    );
                  },
                ),

              const SizedBox(height: 16),

              // 5. PAGINASI KONTROL
              if (_lastPage > 1)
                IjinPaginationBar(
                  currentPage: _currentPage,
                  lastPage: _lastPage,
                  onPageChanged: (page) => _loadData(page: page),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isPendingTab = _activeTab == 'pending' &&
        (_selectedClassId == null || _selectedClassId!.isEmpty) &&
        _searchQuery.isEmpty &&
        (_selectedMonthKey == null || _selectedMonthKey == 'all');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isPendingTab
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPendingTab ? Icons.task_alt_rounded : Icons.inbox_rounded,
              size: 38,
              color: isPendingTab
                  ? const Color(0xFF059669)
                  : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isPendingTab
                ? 'Tidak Ada Permohonan Menunggu'
                : 'Belum Ada Permohonan Izin',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPendingTab
                ? 'Semua pengajuan izin atau sakit siswa di kelas binaan Anda telah diverifikasi.'
                : 'Tidak ada data yang sesuai dengan filter atau kata kunci saat ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _activeTab = 'all';
                _selectedClassId = null;
                _selectedMonthKey = 'all';
                _searchQuery = '';
                _searchController.clear();
              });
              _loadData(page: 1);
            },
            icon: Icon(
              isPendingTab ? Icons.history_rounded : Icons.refresh_rounded,
              size: 15,
            ),
            label: Text(
              isPendingTab
                  ? 'Lihat Semua Riwayat Izin'
                  : 'Reset Filter & Lihat Semua',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
