import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_spikap_model.dart';
import '../services/siswa_spikap_service.dart';
import 'form_spikap_siswa_screen.dart';
import 'widgets/spikap/cards/spikap_siswa_card.dart';
import 'widgets/spikap/modals/modal_tracking_spikap.dart';
import 'widgets/spikap/sections/spikap_siswa_hero_banner.dart';
import 'widgets/spikap/sections/spikap_siswa_summary_metrics.dart';

/// Layar Menu 4: SPIKAP Portal Siswa (Anti-Perundungan & Pengaduan Siswa)
/// Menampilkan hero banner ramah anak, statistik aduan, daftar riwayat laporan,
/// tracking timeline perkembangan investigasi kasus, dan FAB lapor baru.
class SpikapSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;
  final SiswaSpikapService? service;

  const SpikapSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = '',
    this.token,
    this.service,
  });

  @override
  State<SpikapSiswaScreen> createState() => _SpikapSiswaScreenState();
}

class _SpikapSiswaScreenState extends State<SpikapSiswaScreen> {
  late SiswaSpikapService _service;

  bool _isLoading = true;
  String? _errorMessage;

  SiswaSpikapDashboardResponse? _dashboardData;
  SiswaSpikapListResponse? _listData;

  String _activeMetric = 'all'; // all, diterima, dalam_investigasi, selesai, darurat, biasa
  String _statusFilter = 'all'; // all, diterima, dalam_investigasi, selesai
  String _sifatFilter = 'all'; // all, darurat, biasa
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _service = widget.service ??
        SiswaSpikapService.create(
          token: widget.token,
          identifier: widget.identifier,
        );
    _loadInitialData();
  }

  void _selectMetric(String key) {
    setState(() {
      _activeMetric = key;
      if (key == 'all') {
        _statusFilter = 'all';
        _sifatFilter = 'all';
      } else if (key == 'diterima') {
        _statusFilter = 'diterima';
        _sifatFilter = 'all';
      } else if (key == 'dalam_investigasi') {
        _statusFilter = 'dalam_investigasi';
        _sifatFilter = 'all';
      } else if (key == 'selesai') {
        _statusFilter = 'selesai';
        _sifatFilter = 'all';
      } else if (key == 'darurat') {
        _statusFilter = 'all';
        _sifatFilter = 'darurat';
      } else if (key == 'biasa') {
        _statusFilter = 'all';
        _sifatFilter = 'biasa';
      }
    });
    _refreshListOnly();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dashboard = await _service.getDashboard(identifier: widget.identifier);
      final list = await _service.getLaporanList(
        status: _statusFilter,
        sifatLaporan: _sifatFilter,
        search: _searchController.text,
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _dashboardData = dashboard;
          _listData = list;
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

  Future<void> _refreshListOnly() async {
    try {
      final list = await _service.getLaporanList(
        status: _statusFilter,
        sifatLaporan: _sifatFilter,
        search: _searchController.text,
        identifier: widget.identifier,
      );
      if (mounted) {
        setState(() {
          _listData = list;
        });
      }
    } catch (_) {}
  }

  void _navigateToCreateReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormSpikapSiswaScreen(
          identifier: widget.identifier,
          studentName: widget.studentName,
          schoolName: widget.schoolName,
          token: widget.token,
        ),
      ),
    );

    if (result == true) {
      _loadInitialData();
    }
  }

  void _showTrackingModal(SiswaSpikapLaporanItem item) {
    ModalTrackingSpikap.show(
      context,
      laporanItem: item,
      service: _service,
      identifier: widget.identifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SPIKAP (Layanan Pengaduan)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Laporan',
            onPressed: _loadInitialData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE11D48),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_moderator_rounded),
        label: const Text(
          'Buat Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        tooltip: 'Buat Laporan Baru',
        onPressed: _navigateToCreateReport,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Hero Banner Ramah Anak
                        SpikapSiswaHeroBanner(
                          branding: _dashboardData?.branding,
                        ),

                        const SizedBox(height: 14),

                        // 2. Metrik Statistik Kasus (2 baris x 3 kotak)
                        SpikapSiswaSummaryMetrics(
                          counts: _dashboardData?.counts,
                          activeMetric: _activeMetric,
                          onSelectMetric: _selectMetric,
                        ),

                        const SizedBox(height: 14),

                        // 3. Search Bar
                        _buildSearchSection(),

                        const SizedBox(height: 14),

                        // 4. Daftar Kasus
                        _buildLaporanSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 54, color: Color(0xFFE11D48)),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Terjadi kesalahan sistem.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _refreshListOnly(),
        decoration: InputDecoration(
          hintText: 'Cari kata kunci, lokasi, atau isi aduan...',
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _searchController.clear();
                    _refreshListOnly();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }

  Widget _buildLaporanSection() {
    final items = _listData?.items ?? [];

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, size: 52, color: Color(0xFFE11D48)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Laporan Pengaduan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mari wujudkan lingkungan sekolah yang aman, damai, dan bebas perundungan. Jika Anda melihat atau mengalami kekerasan, jangan ragu untuk melapor.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return SpikapSiswaCard(
          item: item,
          onTap: () => _showTrackingModal(item),
        );
      },
    );
  }
}
