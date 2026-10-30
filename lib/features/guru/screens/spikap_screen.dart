import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../models/spikap_models.dart';
import '../services/spikap_service.dart';
import 'spikap_detail_screen.dart';
import 'spikap_analitik_screen.dart';
import 'widgets/dialog_akses_spikap_ditolak.dart';

/// Halaman Utama Kotak Masuk SPIKAP (Anti-Perundungan & Pengaduan Siswa)
class SpikapScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;

  const SpikapScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    required this.schoolName,
  });

  @override
  State<SpikapScreen> createState() => _SpikapScreenState();
}

class _SpikapScreenState extends State<SpikapScreen> {
  late final SpikapService _spikapService;

  bool _isLoading = true;
  String? _errorMessage;

  // Data
  List<SpikapLaporanItem> _reports = [];
  SpikapKpiStats _stats =
      const SpikapKpiStats(total: 0, darurat: 0, aktif: 0, selesai: 0);
  SpikapAccessInfo? _accessInfo;

  // Pagination State
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = false;
  bool _isLoadingMore = false;

  // Filter & Search State
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _selectedStatus = ''; // '', 'diterima', 'dalam_investigasi', 'selesai'
  String _selectedSifat = ''; // '', 'darurat', 'biasa'
  String _selectedJenis = ''; // '', 'fisik', 'verbal', 'sosial', 'digital', 'lainnya'

  @override
  void initState() {
    super.initState();
    _spikapService = SpikapService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    _scrollController.addListener(_onScroll);
    _loadInbox();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadInbox() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });

    try {
      final result = await _spikapService.getInbox(
        search: _searchController.text.trim(),
        status: _selectedStatus.isNotEmpty ? _selectedStatus : null,
        sifat: _selectedSifat.isNotEmpty ? _selectedSifat : null,
        jenis: _selectedJenis.isNotEmpty ? _selectedJenis : null,
        page: 1,
      );

      if (mounted) {
        setState(() {
          _reports = result.reports;
          _stats = result.stats;
          _accessInfo = result.access;
          _hasMore = result.hasMore;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final result = await _spikapService.getInbox(
        search: _searchController.text.trim(),
        status: _selectedStatus.isNotEmpty ? _selectedStatus : null,
        sifat: _selectedSifat.isNotEmpty ? _selectedSifat : null,
        jenis: _selectedJenis.isNotEmpty ? _selectedJenis : null,
        page: nextPage,
      );

      if (mounted) {
        setState(() {
          _reports.addAll(result.reports);
          _currentPage = nextPage;
          _hasMore = result.hasMore;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _loadInbox();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = '';
      _selectedSifat = '';
      _selectedJenis = '';
    });
    _loadInbox();
  }

  bool get _hasActiveFilters =>
      _searchController.text.trim().isNotEmpty ||
      _selectedStatus.isNotEmpty ||
      _selectedSifat.isNotEmpty ||
      _selectedJenis.isNotEmpty;

  void _openDetail(SpikapLaporanItem item) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SpikapDetailScreen(
              laporanId: item.id,
              ticketNumber: item.ticketNumber,
              teacherName: widget.teacherName,
              token: widget.token,
              identifier: widget.identifier,
              schoolName: widget.schoolName,
            ),
          ),
        )
        .then((_) => _loadInbox());
  }

  void _openAnalitik() {
    if (_accessInfo == null) return;
    if (!_accessInfo!.isKs && !_accessInfo!.isBk && !_accessInfo!.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dasbor analitik hanya dapat diakses oleh Kepala Sekolah dan Guru BK.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpikapAnalitikScreen(
          teacherName: widget.teacherName,
          token: widget.token,
          identifier: widget.identifier,
          schoolName: widget.schoolName,
          roleLabel: _accessInfo!.roleLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canViewAnalytics =
        _accessInfo != null &&
        (_accessInfo!.isKs || _accessInfo!.isBk || _accessInfo!.isAdmin);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SPIKAP (Anti-Perundungan)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.schoolName}${_accessInfo != null ? ' • ${_accessInfo!.roleLabel}' : ''}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          if (canViewAnalytics)
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'Dasbor Analitik',
              onPressed: _openAnalitik,
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: _loadInbox,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal Memuat Laporan SPIKAP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInbox,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInbox,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Ringkasan Kartu Metrik KPI
          _buildKpiSection(),
          const SizedBox(height: 14),

          // 2. Toolbar Pencarian & Filter
          _buildSearchAndFilterSection(),
          const SizedBox(height: 14),

          // 3. Header Daftar Laporan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Laporan Masuk (${_reports.length})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              if (_hasActiveFilters)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFDC2626)),
                  label: Text(
                    'Reset Filter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // 4. List Tiket Aduan
          if (_reports.isEmpty)
            _buildEmptyState()
          else
            ..._reports.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTicketCard(item),
                )),

          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildKpiSection() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _buildKpiCard(
          title: 'Total Laporan',
          value: _stats.total.toString(),
          icon: Icons.shield_outlined,
          color: const Color(0xFF475569),
          bgColor: const Color(0xFFF1F5F9),
          onTap: _resetFilters,
        ),
        _buildKpiCard(
          title: 'Laporan Darurat',
          value: _stats.darurat.toString(),
          icon: Icons.warning_rounded,
          color: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEE2E2),
          isUrgent: _stats.darurat > 0,
          onTap: () {
            setState(() {
              _selectedSifat = _selectedSifat == 'darurat' ? '' : 'darurat';
            });
            _loadInbox();
          },
        ),
        _buildKpiCard(
          title: 'Perlu Penanganan',
          value: _stats.aktif.toString(),
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
          onTap: () {
            setState(() {
              _selectedStatus =
                  _selectedStatus == 'dalam_investigasi' ? '' : 'dalam_investigasi';
            });
            _loadInbox();
          },
        ),
        _buildKpiCard(
          title: 'Tuntas / Selesai',
          value: _stats.selesai.toString(),
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF059669),
          bgColor: const Color(0xFFD1FAE5),
          onTap: () {
            setState(() {
              _selectedStatus =
                  _selectedStatus == 'selesai' ? '' : 'selesai';
            });
            _loadInbox();
          },
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    bool isUrgent = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
            width: isUrgent ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUrgent
                  ? const Color(0xFFDC2626).withOpacity(0.08)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
              ],
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari siswa, NISN, lokasi, kejadian...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        _loadInbox();
                      },
                    )
                  : null,
              fillColor: const Color(0xFFF8FAFC),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 1. Status & Urgensi Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua (${_stats.total})',
                  isSelected: _selectedStatus.isEmpty && _selectedSifat.isEmpty,
                  onSelected: () {
                    setState(() {
                      _selectedStatus = '';
                      _selectedSifat = '';
                    });
                    _loadInbox();
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: '🚨 Darurat (${_stats.darurat})',
                  isSelected: _selectedSifat == 'darurat',
                  activeColor: const Color(0xFFDC2626),
                  onSelected: () {
                    setState(() {
                      _selectedSifat =
                          _selectedSifat == 'darurat' ? '' : 'darurat';
                    });
                    _loadInbox();
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Diterima',
                  isSelected: _selectedStatus == 'diterima',
                  onSelected: () {
                    setState(() {
                      _selectedStatus =
                          _selectedStatus == 'diterima' ? '' : 'diterima';
                    });
                    _loadInbox();
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Investigasi (${_stats.aktif})',
                  isSelected: _selectedStatus == 'dalam_investigasi',
                  onSelected: () {
                    setState(() {
                      _selectedStatus = _selectedStatus == 'dalam_investigasi'
                          ? ''
                          : 'dalam_investigasi';
                    });
                    _loadInbox();
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Selesai (${_stats.selesai})',
                  isSelected: _selectedStatus == 'selesai',
                  activeColor: const Color(0xFF059669),
                  onSelected: () {
                    setState(() {
                      _selectedStatus =
                          _selectedStatus == 'selesai' ? '' : 'selesai';
                    });
                    _loadInbox();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 2. Kategori Jenis Perundungan Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua Kategori',
                  isSelected: _selectedJenis.isEmpty,
                  onSelected: () {
                    setState(() => _selectedJenis = '');
                    _loadInbox();
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Kekerasan Fisik',
                  isSelected: _selectedJenis == 'fisik',
                  activeColor: const Color(0xFFDC2626),
                  onSelected: () {
                    setState(() {
                      _selectedJenis =
                          _selectedJenis == 'fisik' ? '' : 'fisik';
                    });
                    _loadInbox();
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Verbal',
                  isSelected: _selectedJenis == 'verbal',
                  activeColor: const Color(0xFFD97706),
                  onSelected: () {
                    setState(() {
                      _selectedJenis =
                          _selectedJenis == 'verbal' ? '' : 'verbal';
                    });
                    _loadInbox();
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Sosial / Relasional',
                  isSelected: _selectedJenis == 'sosial',
                  activeColor: const Color(0xFF2563EB),
                  onSelected: () {
                    setState(() {
                      _selectedJenis =
                          _selectedJenis == 'sosial' ? '' : 'sosial';
                    });
                    _loadInbox();
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Siber / Digital',
                  isSelected: _selectedJenis == 'digital',
                  activeColor: const Color(0xFF7C3AED),
                  onSelected: () {
                    setState(() {
                      _selectedJenis =
                          _selectedJenis == 'digital' ? '' : 'digital';
                    });
                    _loadInbox();
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Lainnya',
                  isSelected: _selectedJenis == 'lainnya',
                  activeColor: const Color(0xFF64748B),
                  onSelected: () {
                    setState(() {
                      _selectedJenis =
                          _selectedJenis == 'lainnya' ? '' : 'lainnya';
                    });
                    _loadInbox();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color activeColor = AppColors.primary,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : const Color(0xFF475569),
      ),
      selectedColor: activeColor,
      backgroundColor: const Color(0xFFF1F5F9),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildTicketCard(SpikapLaporanItem item) {
    return InkWell(
      onTap: () => _openDetail(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isDarurat && item.status != 'selesai'
                ? const Color(0xFFFCA5A5)
                : const Color(0xFFE2E8F0),
            width: item.isDarurat && item.status != 'selesai' ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: item.isDarurat && item.status != 'selesai'
                  ? const Color(0xFFDC2626).withOpacity(0.06)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Urgensi & Ticket Number & Relatif
            Row(
              children: [
                if (item.isDarurat)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFF87171)),
                    ),
                    child: Text(
                      '🚨 DARURAT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF93C5FD)),
                    ),
                    child: Text(
                      'Biasa',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  item.ticketNumber,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Text(
                  item.waktuRelatif,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Identitas Siswa
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFEFF6FF),
                  backgroundImage: item.student.photoUrl != null
                      ? CachedNetworkImageProvider(item.student.photoUrl!)
                      : null,
                  child: item.student.photoUrl == null
                      ? Text(
                          item.student.name.isNotEmpty
                              ? item.student.name[0].toUpperCase()
                              : 'S',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2563EB),
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.student.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'NISN: ${item.student.nisn} • Kelas: ${item.student.className}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tag Jenis & Lokasi
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.jenisLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.lokasiKejadian,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.hasLampiran)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.attach_file_rounded,
                          size: 11,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${item.lampiranCount} Bukti',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Cuplikan Uraian
            Text(
              item.uraianPreview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF334155),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Footer: Status Badge & Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(item.status, item.statusLabel),
                Row(
                  children: [
                    Text(
                      'Tinjau Kasus',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    Color bg;
    Color fg;
    switch (status) {
      case 'diterima':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      case 'dalam_investigasi':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case 'selesai':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF047857);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 40,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Tidak Ada Laporan Ditemukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _hasActiveFilters
                  ? 'Tidak ada laporan yang sesuai dengan kriteria filter pencarian Anda.'
                  : 'Lingkungan sekolah aman kondusif. Belum ada laporan perundungan yang masuk ke modul Anda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _resetFilters,
                child: const Text('Reset Filter'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

