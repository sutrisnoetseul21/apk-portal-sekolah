import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/constants/app_colors.dart';
import '../models/leave_request_model.dart';
import '../services/ijin_kehadiran_service.dart';

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
    this.schoolName = 'SMP Negeri 3 Kedungreja',
  });

  @override
  State<IjinKehadiranScreen> createState() => _IjinKehadiranScreenState();
}

class _IjinKehadiranScreenState extends State<IjinKehadiranScreen> {
  late final IjinKehadiranService _service;

  bool _isLoading = true;
  String _activeTab = 'all'; // 'all', 'pending', 'approved', 'rejected'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filters
  List<Map<String, dynamic>> _accessibleClasses = [];
  String? _selectedClassId;
  List<Map<String, dynamic>> _availableMonths = [];
  String? _selectedMonthKey;

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

          if (_selectedMonthKey == null && _availableMonths.isNotEmpty) {
            _selectedMonthKey = _availableMonths.first['key']?.toString();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar(
          e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = (_todayStats['pending'] as num?)?.toInt() ?? 0;
    final approvedCount = (_todayStats['approved'] as num?)?.toInt() ?? 0;
    final rejectedCount = (_todayStats['rejected'] as num?)?.toInt() ?? 0;

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
              widget.schoolName,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: () => _loadData(page: _currentPage),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(page: 1),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HERO BANNER
              _buildHeroBanner(),

              const SizedBox(height: 16),

              // 2. TIGA KARTU STATISTIK METRIK
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Menunggu',
                      count: pendingCount,
                      subtext: 'Butuh Respons',
                      icon: Icons.hourglass_top_rounded,
                      color: const Color(0xFFE11D48),
                      bgColor: const Color(0xFFFFF1F2),
                      isActive: _activeTab == 'pending',
                      onTap: () {
                        setState(() => _activeTab = 'pending');
                        _loadData(page: 1);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Disetujui',
                      count: approvedCount,
                      subtext: 'Terverifikasi',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                      isActive: _activeTab == 'approved',
                      onTap: () {
                        setState(() => _activeTab = 'approved');
                        _loadData(page: 1);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Ditolak',
                      count: rejectedCount,
                      subtext: 'Tidak Sah',
                      icon: Icons.cancel_outlined,
                      color: const Color(0xFF64748B),
                      bgColor: const Color(0xFFF1F5F9),
                      isActive: _activeTab == 'rejected',
                      onTap: () {
                        setState(() => _activeTab = 'rejected');
                        _loadData(page: 1);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3. SEGMENTED TABS FILTER
              _buildSegmentedTabs(pendingCount),

              const SizedBox(height: 14),

              // 4. FILTER KELAS, BULAN & PENCARIAN SISWA
              _buildFilterCard(),

              const SizedBox(height: 16),

              // 5. DAFTAR PERMOHONAN SISWA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Permohonan ($_totalItems)',
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
                    return _buildLeaveRequestCard(item);
                  },
                ),

              const SizedBox(height: 16),

              // 6. PAGINASI KONTROL
              if (_lastPage > 1) _buildPaginationBar(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // SUB-WIDGETS & SECTIONS
  // =========================================================================

  Widget _buildHeroBanner() {
    final roleSummary = _userInfo['role_summary']?.toString() ?? 'Wali Kelas';
    final academicName =
        _academicYear['name']?.toString() ?? 'Tahun Ajaran Aktif';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Persetujuan Ijin & Sakit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$academicName • $roleSummary',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Verifikasi permohonan kehadiran siswa. Saat disetujui, kehadiran efektif akan otomatis terisi di presensi kelas.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required String subtext,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: isActive ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? color.withOpacity(0.12)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              subtext,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs(int pendingCount) {
    final tabs = [
      {'key': 'all', 'label': 'Semua', 'badge': 0},
      {'key': 'pending', 'label': 'Menunggu', 'badge': pendingCount},
      {'key': 'approved', 'label': 'Disetujui', 'badge': 0},
      {'key': 'rejected', 'label': 'Ditolak', 'badge': 0},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: tabs.map((t) {
          final isSelected = _activeTab == t['key'];
          final badge = (t['badge'] as num?)?.toInt() ?? 0;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_activeTab != t['key']) {
                  setState(() => _activeTab = t['key'] as String);
                  _loadData(page: 1);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF475569),
                      ),
                    ),
                    if (badge > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterCard() {
    final bool hasMultipleClasses = _accessibleClasses.length > 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 1. Filter Kelas
              Expanded(
                child: hasMultipleClasses
                    ? DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'PILIH KELAS',
                          labelStyle: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                          prefixIcon:
                              const Icon(Icons.class_rounded, size: 16),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: '',
                            child: Text('Semua Kelas',
                                style: TextStyle(fontSize: 12)),
                          ),
                          ..._accessibleClasses.map(
                            (c) => DropdownMenuItem<String>(
                              value: c['id']?.toString(),
                              child: Text(
                                'Kelas ${c['name'] ?? ''} (${c['access_label'] ?? 'Kelas'})',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedClassId = val);
                          _loadData(page: 1);
                        },
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.class_rounded,
                                size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'KELAS BINAAN',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64748B)),
                                  ),
                                  Text(
                                    _accessibleClasses.isNotEmpty
                                        ? 'Kelas ${_accessibleClasses.first['name'] ?? '-'}'
                                        : 'Belum Ada Kelas',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(width: 10),

              // 2. Filter Bulan
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMonthKey,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'BULAN PENGAJUAN',
                    labelStyle: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                    prefixIcon:
                        const Icon(Icons.calendar_month_rounded, size: 16),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _availableMonths
                      .map(
                        (m) => DropdownMenuItem<String>(
                          value: m['key']?.toString(),
                          child: Text(
                            m['label']?.toString() ?? '',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null && val != _selectedMonthKey) {
                      setState(() => _selectedMonthKey = val);
                      _loadData(page: 1);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3. Kolom Pencarian Siswa
          TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'Cari nama siswa atau NISN...',
              hintStyle:
                  const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _loadData(page: 1);
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onSubmitted: (val) {
              setState(() => _searchQuery = val);
              _loadData(page: 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 38,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum Ada Permohonan Izin',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tidak ada data yang sesuai dengan filter atau kata kunci saat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _activeTab = 'all';
                _selectedClassId = '';
                _searchQuery = '';
                _searchController.clear();
              });
              _loadData(page: 1);
            },
            icon: const Icon(Icons.refresh_rounded, size: 15),
            label: const Text('Reset Filter & Muat Ulang',
                style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequestItemModel item) {
    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData statusIcon;

    if (item.isApproved) {
      statusColor = const Color(0xFF059669);
      statusBgColor = const Color(0xFFECFDF5);
      statusText = 'Disetujui';
      statusIcon = Icons.check_circle_rounded;
    } else if (item.isRejected) {
      statusColor = const Color(0xFFDC2626);
      statusBgColor = const Color(0xFFFEF2F2);
      statusText = 'Ditolak';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = const Color(0xFFD97706);
      statusBgColor = const Color(0xFFFFFBEB);
      statusText = 'Menunggu Verifikasi';
      statusIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isPending
              ? const Color(0xFFFDE68A)
              : AppColors.border,
          width: item.isPending ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDetailModal(item.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Kartu: Avatar Siswa, Nama, Kelas, Badge Jenis Izin
                Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: item.isSakit
                          ? const Color(0xFFFFE4E6)
                          : const Color(0xFFDCFCE7),
                      child: Text(
                        item.initials,
                        style: TextStyle(
                          color: item.isSakit
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF16A34A),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.studentName,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kelas ${item.className} • NISN: ${item.studentNisn}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge Jenis: Izin / Sakit
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.isSakit
                            ? const Color(0xFFFFE4E6)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.isSakit
                                ? Icons.medical_services_outlined
                                : Icons.event_note_rounded,
                            size: 11,
                            color: item.isSakit
                                ? const Color(0xFFE11D48)
                                : const Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.typeLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: item.isSakit
                                  ? const Color(0xFFE11D48)
                                  : const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Info Rentang Tanggal & Durasi
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 13, color: Color(0xFF475569)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.dateRange} (${item.durationLabel})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Cuplikan Alasan Izin
                Text(
                  item.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    height: 1.3,
                  ),
                ),

                // Pratinjau Thumbnail Lampiran (Jika Ada)
                if (item.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_file_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        '${item.attachments.length} Berkas Lampiran',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      if (item.thumbnailUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            item.thumbnailUrl!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_outlined,
                                size: 20),
                          ),
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Footer Status & Tombol Aksi
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.isPending && item.canApprove
                            ? AppColors.primary
                            : const Color(0xFFF1F5F9),
                        foregroundColor: item.isPending && item.canApprove
                            ? Colors.white
                            : const Color(0xFF334155),
                        elevation: item.isPending && item.canApprove ? 1 : 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _openDetailModal(item.id),
                      icon: Icon(
                        item.isPending && item.canApprove
                            ? Icons.gavel_rounded
                            : Icons.visibility_outlined,
                        size: 13,
                      ),
                      label: Text(
                        item.isPending && item.canApprove
                            ? 'Tinjau & Putuskan'
                            : 'Lihat Detail',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Halaman $_currentPage dari $_lastPage',
            style:
                const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: _currentPage > 1
                    ? () => _loadData(page: _currentPage - 1)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _currentPage < _lastPage
                    ? () => _loadData(page: _currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // MODAL DETAIL & KEPUTUSAN WALI KELAS
  // =========================================================================

  Future<void> _openDetailModal(String recordId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _DetailIjinModal(
          recordId: recordId,
          service: _service,
          onStatusChanged: () {
            _loadData(page: _currentPage);
          },
        );
      },
    );
  }
}

/// =========================================================================
/// WIDGET MODAL DETAIL PERMOHONAN IZIN & BILAH KEPUTUSAN WALI KELAS
/// =========================================================================
class _DetailIjinModal extends StatefulWidget {
  final String recordId;
  final IjinKehadiranService service;
  final VoidCallback onStatusChanged;

  const _DetailIjinModal({
    required this.recordId,
    required this.service,
    required this.onStatusChanged,
  });

  @override
  State<_DetailIjinModal> createState() => _DetailIjinModalState();
}

class _DetailIjinModalState extends State<_DetailIjinModal> {
  bool _isLoading = true;
  bool _isActionProcessing = false;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final data = await widget.service.getLeaveRequestDetail(widget.recordId);
      if (mounted) {
        setState(() {
          _detail = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleApprove() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Setujui Permohonan?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          'Presensi siswa pada tanggal KBM efektif sekolah akan otomatis terisi sebagai Izin/Sakit di tabel presensi.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Setujui'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionProcessing = true);
    try {
      final res = await widget.service.approveLeaveRequest(widget.recordId);
      _showToast(res['message']?.toString() ?? 'Izin berhasil disetujui.');
      widget.onStatusChanged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isActionProcessing = false);
    }
  }

  Future<void> _handleReject() async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Permohonan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mohon cantumkan alasan penolakan agar siswa dan orang tua memahami penyebabnya:',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'Contoh: Surat dokter tidak valid / tidak ada cap...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 3) {
                    return 'Alasan penolakan minimal 3 karakter.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.pop(ctx, reasonController.text.trim());
              }
            },
            child: const Text('Tolak Permohonan'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isActionProcessing = true);
    try {
      final res =
          await widget.service.rejectLeaveRequest(widget.recordId, reason);
      _showToast(
          res['message']?.toString() ?? 'Permohonan berhasil ditolak.');
      widget.onStatusChanged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isActionProcessing = false);
    }
  }

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kembalikan ke Pending?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          'Catatan presensi otomatis (jika ada) akan dicabut dan status kembali menjadi menunggu verifikasi.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF475569),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kembalikan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionProcessing = true);
    try {
      final res = await widget.service.resetLeaveRequest(widget.recordId);
      _showToast(res['message']?.toString() ?? 'Status berhasil dikembalikan.');
      widget.onStatusChanged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showToast(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isActionProcessing = false);
    }
  }

  void _launchWhatsApp(String phone) async {
    final url = 'https://wa.me/$phone';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showToast('Tidak dapat membuka WhatsApp untuk nomor $phone',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 380,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(
          child: SpinKitFadingCircle(color: AppColors.primary, size: 40),
        ),
      );
    }

    final detail = _detail!;
    final student = (detail['student'] as Map<String, dynamic>? ?? {});
    final leave = (detail['leave'] as Map<String, dynamic>? ?? {});
    final authInfo = (detail['authorization'] as Map<String, dynamic>? ?? {});
    final attachments = (detail['attachments'] as List? ?? []);
    final logs = (detail['logs'] as List? ?? []);

    final bool canApprove = authInfo['can_approve_or_reject'] == true;
    final String? restrictionNotice =
        authInfo['restriction_notice']?.toString();

    final status = leave['status']?.toString() ?? 'pending';
    final isPending = status == 'pending';
    final isSakit = leave['type']?.toString() == 'sakit';

    final studentName = student['name']?.toString() ?? 'Siswa';
    final className = student['class_name']?.toString() ?? '-';
    final nisn = student['nisn']?.toString() ?? '-';
    final parentName = student['parent_name']?.toString() ?? 'Orang Tua';
    final parentPhone = student['parent_phone']?.toString();
    final parentPhoneClean = student['parent_phone_clean']?.toString();

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // Header Modal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Permohonan Izin',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '$studentName • Kelas $className',
                        style: const TextStyle(
                            fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Pemberitahuan Mode Pantau (Khusus Guru BK)
                  if (restrictionNotice != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFF2563EB), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              restrictionNotice,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF1E40AF),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // CARD 1: INFORMASI SISWA & ORTU
                  _buildSectionHeader('Profil Siswa & Kontak Orang Tua'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Nama Siswa', studentName),
                        _buildDetailRow(
                            'NISN / NIS', '$nisn / ${student['nis'] ?? '-'}'),
                        _buildDetailRow('Kelas', 'Kelas $className'),
                        _buildDetailRow('Orang Tua / Wali', parentName),
                        if (parentPhone != null && parentPhone.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'No. WhatsApp Ortu',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              if (parentPhoneClean != null)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF22C55E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                  onPressed: () =>
                                      _launchWhatsApp(parentPhoneClean),
                                  icon: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 12),
                                  label: Text(
                                    parentPhone,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              else
                                Text(
                                  parentPhone,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 2: RINCIAN PERMOHONAN
                  _buildSectionHeader('Rincian Izin / Sakit'),
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
                        _buildDetailRow(
                          'Jenis Permohonan',
                          isSakit ? 'Sakit' : 'Izin',
                          valueColor: isSakit
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF16A34A),
                        ),
                        _buildDetailRow('Tanggal Mulai',
                            leave['start_date_formatted']?.toString() ?? '-'),
                        _buildDetailRow('Tanggal Selesai',
                            leave['end_date_formatted']?.toString() ?? '-'),
                        _buildDetailRow('Durasi Hari',
                            leave['duration_label']?.toString() ?? '-'),
                        _buildDetailRow('Status Saat Ini',
                            leave['status_label']?.toString() ?? '-'),
                        const SizedBox(height: 8),
                        const Text(
                          'Alasan / Keterangan:',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            leave['reason']?.toString() ?? '-',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E293B),
                                height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CARD 3: BERKAS LAMPIRAN SURAT DOKTER / ORTU
                  _buildSectionHeader(
                      'Berkas Lampiran Bukti (${attachments.length})'),
                  if (attachments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Tidak ada lampiran foto/berkas yang diunggah.',
                          style: TextStyle(
                              fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: attachments.length,
                      itemBuilder: (ctx, idx) {
                        final att = attachments[idx];
                        final isImg = att['is_image'] == true;
                        final url = att['url']?.toString() ?? '';
                        final name = att['name']?.toString() ?? 'Lampiran';

                        return GestureDetector(
                          onTap: () =>
                              _openAttachmentViewer(url, isImg, name),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: isImg
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Center(
                                            child: Icon(
                                                Icons.broken_image_rounded,
                                                color: Color(0xFF94A3B8)),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 4),
                                            child: Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                              Icons.picture_as_pdf_rounded,
                                              color: Color(0xFFDC2626),
                                              size: 32),
                                          const SizedBox(height: 6),
                                          Padding(
                                            padding: const EdgeInsets
                                                .symmetric(horizontal: 6),
                                            child: Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 14),

                  // CARD 4: RIWAYAT AUDIT LOG
                  if (logs.isNotEmpty) ...[
                    _buildSectionHeader('Riwayat Log Persetujuan'),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: logs.map((lg) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${lg['action_label']} oleh ${lg['user_name']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (lg['reason'] != null &&
                                          lg['reason'].toString().isNotEmpty)
                                        Text(
                                          lg['reason'].toString(),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF475569)),
                                        ),
                                      Text(
                                        lg['created_at_formatted']
                                                ?.toString() ??
                                            '',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // BILAH AKSI KEPUTUSAN WALI KELAS (Bottom Bar)
          if (canApprove) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: _isActionProcessing
                  ? const Center(
                      child: SpinKitThreeBounce(
                          color: AppColors.primary, size: 24),
                    )
                  : Row(
                      children: [
                        if (isPending) ...[
                          // Tombol Tolak
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                side: const BorderSide(
                                    color: Color(0xFFDC2626)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleReject,
                              icon: const Icon(Icons.cancel_outlined,
                                  size: 16),
                              label: const Text('Tolak',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Tombol Setujui
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleApprove,
                              icon: const Icon(Icons.check_circle_rounded,
                                  size: 16),
                              label: const Text(
                                'Setujui Permohonan',
                                style:
                                    TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Status sudah approved / rejected -> Tampilkan opsi Reset ke Pending
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                side: const BorderSide(
                                    color: Color(0xFF94A3B8)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleReset,
                              icon: const Icon(Icons.restart_alt_rounded,
                                  size: 16),
                              label: const Text(
                                'Kembalikan ke Status Menunggu (Reset)',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  void _openAttachmentViewer(String url, bool isImage, String title) {
    if (isImage) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.white,
                      child: const Text('Gagal memuat gambar.'),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
