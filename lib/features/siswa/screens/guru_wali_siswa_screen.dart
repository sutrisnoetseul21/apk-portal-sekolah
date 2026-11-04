import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_guru_wali_model.dart';
import '../services/siswa_guru_wali_service.dart';
import 'form_curhat_siswa_screen.dart';
import 'widgets/guru_wali/modals/modal_detail_konsultasi.dart';
import 'widgets/guru_wali/sections/siwali_guru_wali_card.dart';
import 'widgets/guru_wali/sections/siwali_hero_banner.dart';
import 'widgets/guru_wali/sections/siwali_summary_metrics.dart';
import 'widgets/guru_wali/sections/siwali_tab_bar_delegate.dart';
import 'widgets/guru_wali/tabs/tab_bimbingan_klasikal.dart';
import 'widgets/guru_wali/tabs/tab_konsultasi_mandiri.dart';

/// Layar Menu 3: SI-WALI Portal Siswa (Konsultasi Guru Wali & Bimbingan Klasikal)
/// Menyediakan profil Guru Wali asuh, Tab Konsultasi Mandiri (Curhat),
/// Tab Pendampingan Klasikal & Kelompok, Modal Pop-up Bercerita, Thread Obrolan, dan Rating Feedback.
class GuruWaliSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;
  final SiswaGuruWaliService? service;

  const GuruWaliSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = '',
    this.token,
    this.service,
  });

  @override
  State<GuruWaliSiswaScreen> createState() => _GuruWaliSiswaScreenState();
}

class _GuruWaliSiswaScreenState extends State<GuruWaliSiswaScreen>
    with SingleTickerProviderStateMixin {
  late SiswaGuruWaliService _service;
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;

  // Data Dashboard
  SiswaGuruWaliDashboardResponse? _dashboardData;

  // Tab 1: Konsultasi Mandiri
  bool _isLoadingKonsultasi = false;
  SiswaKonsultasiListResponse? _konsultasiData;
  String _statusFilter = 'all'; // all, menunggu, dijadwalkan, selesai, ditolak
  final String _kategoriKonsultasiFilter = 'all';
  final TextEditingController _searchKonsultasiController =
      TextEditingController();

  // Tab 2: Pendampingan Klasikal & Kelompok
  bool _isLoadingKlasikal = false;
  SiswaKlasikalListResponse? _klasikalData;
  String _jenisKlasikalFilter = 'all'; // all, Klasikal, Kelompok Kecil
  final String _kategoriKlasikalFilter = 'all';
  final TextEditingController _searchKlasikalController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _service = widget.service ??
        SiswaGuruWaliService.create(
          token: widget.token,
          identifier: widget.identifier,
        );

    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchKonsultasiController.dispose();
    _searchKlasikalController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dash = await _service.getDashboard(identifier: widget.identifier);
      final konsul = await _service.getKonsultasiList(
        status: _statusFilter,
        kategori: _kategoriKonsultasiFilter,
        search: _searchKonsultasiController.text.trim(),
        identifier: widget.identifier,
      );
      final klasikal = await _service.getPendampinganKlasikalList(
        jenis: _jenisKlasikalFilter,
        kategori: _kategoriKlasikalFilter,
        search: _searchKlasikalController.text.trim(),
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _dashboardData = dash;
          _konsultasiData = konsul;
          _klasikalData = klasikal;
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

  Future<void> _refreshKonsultasi() async {
    setState(() => _isLoadingKonsultasi = true);
    try {
      final konsul = await _service.getKonsultasiList(
        status: _statusFilter,
        kategori: _kategoriKonsultasiFilter,
        search: _searchKonsultasiController.text.trim(),
        identifier: widget.identifier,
      );
      final dash = await _service.getDashboard(identifier: widget.identifier);

      if (mounted) {
        setState(() {
          _konsultasiData = konsul;
          _dashboardData = dash;
          _isLoadingKonsultasi = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingKonsultasi = false);
    }
  }

  Future<void> _refreshKlasikal() async {
    setState(() => _isLoadingKlasikal = true);
    try {
      final klasikal = await _service.getPendampinganKlasikalList(
        jenis: _jenisKlasikalFilter,
        kategori: _kategoriKlasikalFilter,
        search: _searchKlasikalController.text.trim(),
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _klasikalData = klasikal;
          _isLoadingKlasikal = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingKlasikal = false);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak dapat membuka aplikasi WhatsApp.')),
        );
      }
    }
  }

  void _showModalBercerita() {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormCurhatSiswaScreen(
          service: _service,
          identifier: widget.identifier,
        ),
      ),
    ).then((res) {
      if (res == true && mounted) {
        _refreshKonsultasi();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Permohonan curhat/konsultasi berhasil dikirimkan ke Guru Wali Anda!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    });
  }

  void _showDetailKonsultasi(SiswaKonsultasiItem item) {
    ModalDetailKonsultasi.show(
      context,
      service: _service,
      identifier: widget.identifier,
      initialItem: item,
      onChanged: _refreshKonsultasi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF2563EB),
                Color(0xFF3B82F6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guru Wali (SI-WALI)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.school_rounded,
                    size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  widget.schoolName.isNotEmpty
                      ? widget.schoolName
                      : AppConfig.appName,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Segarkan Halaman',
            onPressed: _loadInitialData,
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          icon: const Icon(Icons.edit_note_rounded, size: 22),
          label: const Text(
            'Mulai Bercerita',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.2),
          ),
          tooltip: 'Mulai Bercerita atau Curhat ke Guru Wali',
          onPressed: _showModalBercerita,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  color: AppColors.primary,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // 1. Hero Banner SI-WALI
                                const SiwaliHeroBanner(),
                                const SizedBox(height: 14),

                                // 2. Kartu Guru Wali Pendamping
                                if (_dashboardData?.guruWali != null)
                                  SiwaliGuruWaliCard(
                                    guru: _dashboardData!.guruWali!,
                                    onWhatsAppTap: _launchWhatsApp,
                                  ),
                                const SizedBox(height: 14),

                                // 3. Ringkasan Metrik Interaktif
                                SiwaliSummaryMetrics(
                                  counts: _dashboardData?.counts,
                                  currentTabIndex: _tabController.index,
                                  statusFilter: _statusFilter,
                                  jenisKlasikalFilter: _jenisKlasikalFilter,
                                  onSelectKonsultasiStatus: (status) {
                                    setState(() {
                                      _tabController.animateTo(0);
                                      _statusFilter = status;
                                    });
                                    _refreshKonsultasi();
                                  },
                                  onSelectKlasikalJenis: (jenis) {
                                    setState(() {
                                      _tabController.animateTo(1);
                                      _jenisKlasikalFilter = jenis;
                                    });
                                    _refreshKlasikal();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 4. Persistent TabBar
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: SiwaliTabBarDelegate(
                            TabBar(
                              controller: _tabController,
                              indicatorColor: const Color(0xFF2563EB),
                              indicatorWeight: 3,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: const Color(0xFF2563EB),
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                              unselectedLabelStyle: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                              tabs: [
                                Tab(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.person_pin_rounded,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        const Text('Konsultasi Mandiri'),
                                        if ((_dashboardData?.counts.semua ??
                                                0) >
                                            0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2563EB)
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${_dashboardData!.counts.semua}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF2563EB),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.groups_rounded,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        const Text('Bimbingan Klasikal'),
                                        if ((_dashboardData?.counts.klasikal ??
                                                0) >
                                            0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF7C3AED)
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${_dashboardData!.counts.klasikal}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF7C3AED),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Konsultasi Mandiri
                        TabKonsultasiMandiri(
                          searchController: _searchKonsultasiController,
                          onSearchSubmitted: _refreshKonsultasi,
                          onSearchCleared: () {
                            _searchKonsultasiController.clear();
                            _refreshKonsultasi();
                          },
                          isLoading: _isLoadingKonsultasi,
                          items: _konsultasiData?.items,
                          onKonsultasiTap: _showDetailKonsultasi,
                          onMulaiBercerita: _showModalBercerita,
                        ),

                        // Tab 2: Pendampingan Klasikal & Kelompok
                        TabBimbinganKlasikal(
                          searchController: _searchKlasikalController,
                          onSearchSubmitted: _refreshKlasikal,
                          onSearchCleared: () {
                            _searchKlasikalController.clear();
                            _refreshKlasikal();
                          },
                          isLoading: _isLoadingKlasikal,
                          items: _klasikalData?.items,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 52, color: Color(0xFFDC2626)),
            const SizedBox(height: 14),
            const Text(
              'Gagal Memuat Data SI-WALI',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Terjadi kesalahan sistem.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              onPressed: _loadInitialData,
            ),
          ],
        ),
      ),
    );
  }
}
