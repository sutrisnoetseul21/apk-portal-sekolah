import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/spikap_models.dart';
import '../services/spikap_service.dart';
import 'spikap_analitik_screen.dart';
import 'spikap_detail_screen.dart';
import 'widgets/spikap/cards/spikap_ticket_card.dart';
import 'widgets/spikap/sections/spikap_filter_toolbar.dart';
import 'widgets/spikap/sections/spikap_kpi_grid.dart';

/// Halaman Utama Kotak Masuk SPIKAP Guru (Anti-Perundungan & Pengaduan Siswa)
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
          // 1. Ringkasan Kartu Metrik KPI (4 kotak)
          SpikapKpiGrid(
            stats: _stats,
            selectedStatus: _selectedStatus,
            selectedSifat: _selectedSifat,
            onReset: _resetFilters,
            onToggleStatus: (status) {
              setState(() {
                _selectedStatus = _selectedStatus == status ? '' : status;
              });
              _loadInbox();
            },
            onToggleSifat: (sifat) {
              setState(() {
                _selectedSifat = _selectedSifat == sifat ? '' : sifat;
              });
              _loadInbox();
            },
          ),
          const SizedBox(height: 14),

          // 2. Toolbar Pencarian & Filter
          SpikapFilterToolbar(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onClearSearch: () {
              _searchController.clear();
              _loadInbox();
            },
            stats: _stats,
            selectedStatus: _selectedStatus,
            selectedSifat: _selectedSifat,
            selectedJenis: _selectedJenis,
            onStatusSelected: (status) {
              setState(() => _selectedStatus = status);
              _loadInbox();
            },
            onSifatSelected: (sifat) {
              setState(() => _selectedSifat = sifat);
              _loadInbox();
            },
            onJenisSelected: (jenis) {
              setState(() => _selectedJenis = jenis);
              _loadInbox();
            },
          ),
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
                  child: SpikapTicketCard(
                    item: item,
                    onTap: () => _openDetail(item),
                  ),
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
