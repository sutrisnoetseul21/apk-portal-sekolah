import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_guru_wali_model.dart';
import '../services/siswa_guru_wali_service.dart';

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
    this.schoolName = 'SMP Negeri 3 Kedungreja',
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
  final TextEditingController _searchKonsultasiController = TextEditingController();

  // Tab 2: Pendampingan Klasikal & Kelompok
  bool _isLoadingKlasikal = false;
  SiswaKlasikalListResponse? _klasikalData;
  String _jenisKlasikalFilter = 'all'; // all, Klasikal, Kelompok Kecil
  final String _kategoriKlasikalFilter = 'all';
  final TextEditingController _searchKlasikalController = TextEditingController();

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
          const SnackBar(content: Text('Tidak dapat membuka aplikasi WhatsApp.')),
        );
      }
    }
  }

  // ==================== MODAL POP-UP BERIKUTNYA ====================

  /// Pop-up Form Dialog "Mulai Bercerita / Curhat ke Guru Wali"
  void _showModalBercerita() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModalCurhatForm(
        service: _service,
        identifier: widget.identifier,
        onSuccess: () {
          _refreshKonsultasi();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permohonan curhat/konsultasi berhasil dikirimkan ke Guru Wali Anda!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
        },
      ),
    );
  }

  /// Detail Konsultasi & Percakapan Pesan Inline
  void _showDetailKonsultasi(SiswaKonsultasiItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModalDetailKonsultasi(
        service: _service,
        identifier: widget.identifier,
        initialItem: item,
        onChanged: _refreshKonsultasi,
      ),
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
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Row(
              children: [
                const Icon(Icons.school_rounded, size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  widget.schoolName,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          icon: const Icon(Icons.edit_note_rounded, size: 22),
          label: const Text(
            'Mulai Bercerita',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.2),
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
                                _buildHeroBanner(),

                                const SizedBox(height: 14),

                                // 2. Kartu Guru Wali Pendamping
                                if (_dashboardData?.guruWali != null)
                                  _buildGuruWaliCard(_dashboardData!.guruWali!),

                                const SizedBox(height: 14),

                                // 3. Ringkasan Metrik Interaktif
                                _buildSummaryMetrics(),
                              ],
                            ),
                          ),
                        ),
                        // 4. Persistent TabBar
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              controller: _tabController,
                              indicatorColor: const Color(0xFF2563EB),
                              indicatorWeight: 3,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: const Color(0xFF2563EB),
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              tabs: [
                                Tab(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.person_pin_rounded, size: 18),
                                        const SizedBox(width: 6),
                                        const Text('Konsultasi Mandiri'),
                                        if ((_dashboardData?.counts.semua ?? 0) > 0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(10),
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.groups_rounded, size: 18),
                                        const SizedBox(width: 6),
                                        const Text('Bimbingan Klasikal'),
                                        if ((_dashboardData?.counts.klasikal ?? 0) > 0) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(10),
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
                        _buildKonsultasiTabContent(),

                        // Tab 2: Pendampingan Klasikal & Kelompok
                        _buildKlasikalTabContent(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ==================== WIDGET HERO & PROFIL GURU ====================

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, color: Color(0xFF60A5FA), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'SI-WALI • Ruang Aman & Nyaman Murid',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ruang Bimbingan & Curhat Privat',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          const Text(
            'Saluran privat untuk menyampaikan kendala belajar, minat bakat, atau hal pribadi langsung kepada Guru Wali asuh Anda.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildGuruWaliCard(SiswaGuruWaliProfile guru) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto Guru / Squircle Fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: guru.photoUrl != null && guru.photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: guru.photoUrl!,
                    width: 62,
                    height: 62,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 62,
                      height: 62,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => _buildAvatarFallback(guru.name),
                  )
                : _buildAvatarFallback(guru.name),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lencana Guru Wali Asuh & Tombol WhatsApp
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.school_rounded, size: 11, color: Color(0xFF2563EB)),
                          SizedBox(width: 4),
                          Text(
                            'Guru Wali Asuh',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                    ),
                    if (guru.phone != null && guru.phone!.isNotEmpty)
                      Material(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _launchWhatsApp(guru.phone!),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_rounded, color: Color(0xFF16A34A), size: 13),
                                SizedBox(width: 4),
                                Text(
                                  'WhatsApp',
                                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                // Nama Guru
                Text(
                  guru.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Kelompok Asuh
                Row(
                  children: [
                    const Icon(Icons.groups_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        guru.namaKelompok,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Tanggal Bergabung
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        guru.formattedTanggalBergabung ?? 'NIP: ${guru.nip}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final clean = name.trim();
    final initials = clean.isNotEmpty
        ? clean.split(' ').where((w) => w.isNotEmpty).take(2).map((e) => e[0]).join().toUpperCase()
        : 'GW';

    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            initials.isNotEmpty ? initials : 'GW',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school_rounded, size: 10, color: Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics() {
    final counts = _dashboardData?.counts;

    return Column(
      children: [
        // Baris 1: Konsultasi Mandiri (3 kotak: Konsultasi, Menunggu, Dijadwalkan)
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                title: 'Konsultasi',
                count: counts?.semua ?? 0,
                icon: Icons.chat_bubble_outline_rounded,
                color: const Color(0xFF2563EB),
                bg: const Color(0xFFEFF6FF),
                isSelected: _tabController.index == 0 && _statusFilter == 'all',
                onTap: () {
                  setState(() {
                    _tabController.animateTo(0);
                    _statusFilter = 'all';
                  });
                  _refreshKonsultasi();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                title: 'Menunggu',
                count: counts?.menunggu ?? 0,
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFD97706),
                bg: const Color(0xFFFFFBEB),
                isSelected: _tabController.index == 0 && _statusFilter == 'menunggu',
                onTap: () {
                  setState(() {
                    _tabController.animateTo(0);
                    _statusFilter = 'menunggu';
                  });
                  _refreshKonsultasi();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                title: 'Dijadwalkan',
                count: counts?.dijadwalkan ?? 0,
                icon: Icons.event_available_rounded,
                color: const Color(0xFF0284C7),
                bg: const Color(0xFFF0F9FF),
                isSelected: _tabController.index == 0 && _statusFilter == 'dijadwalkan',
                onTap: () {
                  setState(() {
                    _tabController.animateTo(0);
                    _statusFilter = 'dijadwalkan';
                  });
                  _refreshKonsultasi();
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Baris 2: Selesai, Klasikal, Kelompok Kecil (3 kotak)
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                title: 'Selesai',
                count: counts?.selesai ?? 0,
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF059669),
                bg: const Color(0xFFECFDF5),
                isSelected: _tabController.index == 0 && _statusFilter == 'selesai',
                onTap: () {
                  setState(() {
                    _tabController.animateTo(0);
                    _statusFilter = 'selesai';
                  });
                  _refreshKonsultasi();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                title: 'Klasikal',
                count: counts?.klasikal ?? 0,
                icon: Icons.groups_outlined,
                color: const Color(0xFF7C3AED),
                bg: const Color(0xFFF5F3FF),
                isSelected: _tabController.index == 1 && _jenisKlasikalFilter == 'Klasikal',
                onTap: () {
                  setState(() {
                    _tabController.animateTo(1);
                    _jenisKlasikalFilter = 'Klasikal';
                  });
                  _refreshKlasikal();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricItem(
                title: 'Kelompok Kecil',
                count: counts?.kelompokKecil ?? 0,
                icon: Icons.group_work_outlined,
                color: const Color(0xFF0D9488),
                bg: const Color(0xFFF0FDFA),
                isSelected: _tabController.index == 1 && _jenisKlasikalFilter == 'Kelompok Kecil',
                onTap: () {
                  setState(() {
                    _tabController.animateTo(1);
                    _jenisKlasikalFilter = 'Kelompok Kecil';
                  });
                  _refreshKlasikal();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? bg.withValues(alpha: 0.5) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? bg.withValues(alpha: 0.4) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? color.withValues(alpha: 0.14) : const Color(0xFF1E293B).withValues(alpha: 0.03),
                blurRadius: isSelected ? 6 : 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAB 1: KONSULTASI MANDIRI ====================

  Widget _buildKonsultasiTabContent() {
    return Column(
      children: [
        // Menu Pencarian (Hanya Pencarian, tanpa menu lagi di bawahnya)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: _searchKonsultasiController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _refreshKonsultasi(),
            decoration: InputDecoration(
              hintText: 'Cari topik curhat atau kata kunci...',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
              suffixIcon: _searchKonsultasiController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _searchKonsultasiController.clear();
                        _refreshKonsultasi();
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
        ),

        // List Konsultasi
        Expanded(
          child: _isLoadingKonsultasi
              ? const Center(child: CircularProgressIndicator())
              : (_konsultasiData?.items.isEmpty ?? true)
                  ? _buildEmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Belum Ada Sesi Konsultasi',
                      desc: 'Anda belum memiliki riwayat bimbingan atau curhat dengan Guru Wali pada filter ini.',
                      buttonText: 'Mulai Bercerita Sekarang',
                      onAction: _showModalBercerita,
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth >= 600;

                        if (isTablet) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.45,
                            ),
                            itemCount: _konsultasiData!.items.length,
                            itemBuilder: (context, index) {
                              return _buildKonsultasiCard(_konsultasiData!.items[index]);
                            },
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _konsultasiData!.items.length,
                          separatorBuilder: (_, i) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildKonsultasiCard(_konsultasiData!.items[index]);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildKonsultasiCard(SiswaKonsultasiItem item) {
    Color statusBg;
    Color statusFg;
    Color dotColor;
    IconData statusIcon;

    switch (item.statusKey) {
      case 'dijadwalkan':
        statusBg = const Color(0xFFEFF6FF);
        statusFg = const Color(0xFF1D4ED8);
        dotColor = const Color(0xFF3B82F6);
        statusIcon = Icons.event_available_rounded;
        break;
      case 'selesai':
        statusBg = const Color(0xFFECFDF5);
        statusFg = const Color(0xFF047857);
        dotColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'ditolak':
        statusBg = const Color(0xFFFEF2F2);
        statusFg = const Color(0xFFB91C1C);
        dotColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel_rounded;
        break;
      case 'menunggu':
      default:
        statusBg = const Color(0xFFFFFBEB);
        statusFg = const Color(0xFFB45309);
        dotColor = const Color(0xFFF59E0B);
        statusIcon = Icons.hourglass_top_rounded;
        break;
    }

    IconData kategoriIcon;
    switch (item.kategori) {
      case 'Akademik':
        kategoriIcon = Icons.school_outlined;
        break;
      case 'Karakter & Kedisiplinan':
        kategoriIcon = Icons.psychology_outlined;
        break;
      case 'Minat & Bakat / Ekskul':
        kategoriIcon = Icons.auto_awesome_outlined;
        break;
      case 'Sosial & Psikologis':
      default:
        kategoriIcon = Icons.people_outline_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showDetailKonsultasi(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Kategori & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(kategoriIcon, size: 13, color: const Color(0xFF475569)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                item.kategori,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: dotColor.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: dotColor),
                          const SizedBox(width: 5),
                          Text(
                            item.statusLabel,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusFg),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Topik
                Text(
                  item.topik,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Quote Box Uraian Curhat
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 3.5,
                            color: dotColor.withValues(alpha: 0.7),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Text(
                                item.detail,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Notice Jadwal Pasti jika dijadwalkan
                if (item.formattedJadwalPasti != null && item.formattedJadwalPasti!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.alarm_on_rounded, size: 14, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Jadwal Pertemuan: ${item.formattedJadwalPasti}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Feedback rating preview jika selesai
                if (item.feedbackRating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        'Ulasan: ${item.feedbackRating}/5 (${item.feedbackEmoji ?? 'Lega'})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Footer: Mode & Tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.mode == 'Tatap Muka' ? Icons.people_alt_rounded : Icons.mark_chat_read_rounded,
                            size: 15,
                            color: const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              item.mode,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.unreadMessagesCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${item.unreadMessagesCount} pesan',
                                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          item.formattedCreatedAt,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ],
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

  // ==================== TAB 2: PENDAMPINGAN KLASIKAL ====================

  Widget _buildKlasikalTabContent() {
    return Column(
      children: [
        // Menu Pencarian (Hanya Pencarian, tanpa menu lagi di bawahnya)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: _searchKlasikalController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _refreshKlasikal(),
            decoration: InputDecoration(
              hintText: 'Cari materi klasikal atau arahan motivasi...',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
              suffixIcon: _searchKlasikalController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _searchKlasikalController.clear();
                        _refreshKlasikal();
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
        ),

        // List Klasikal
        Expanded(
          child: _isLoadingKlasikal
              ? const Center(child: CircularProgressIndicator())
              : (_klasikalData?.items.isEmpty ?? true)
                  ? _buildEmptyState(
                      icon: Icons.menu_book_rounded,
                      title: 'Belum Ada Sesi Bimbingan Klasikal',
                      desc: 'Guru Wali belum mencatat sesi bimbingan klasikal bersama kelas atau kelompok asuh Anda.',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth >= 600;

                        if (isTablet) {
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.95,
                            ),
                            itemCount: _klasikalData!.items.length,
                            itemBuilder: (context, index) {
                              return _buildKlasikalCard(_klasikalData!.items[index]);
                            },
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _klasikalData!.items.length,
                          separatorBuilder: (_, i) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return _buildKlasikalCard(_klasikalData!.items[index]);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildKlasikalCard(SiswaBimbinganKlasikalItem item) {
    Color jenisBg;
    Color jenisFg;
    IconData jenisIcon;

    switch (item.jenisPendampingan) {
      case 'Kelompok Kecil':
        jenisBg = const Color(0xFFF0FDFA);
        jenisFg = const Color(0xFF0D9488);
        jenisIcon = Icons.group_rounded;
        break;
      case 'Individu':
        jenisBg = const Color(0xFFEEF2FF);
        jenisFg = const Color(0xFF4F46E5);
        jenisIcon = Icons.person_rounded;
        break;
      case 'Klasikal':
      default:
        jenisBg = const Color(0xFFF5F3FF);
        jenisFg = const Color(0xFF7C3AED);
        jenisIcon = Icons.groups_rounded;
        break;
    }

    final parsed = _StructuredKlasikalContent.parse(item.uraianPembahasan);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Jenis & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: jenisBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(jenisIcon, size: 12, color: jenisFg),
                        const SizedBox(width: 4),
                        Text(
                          item.jenisPendampingan,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: jenisFg),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.kategoriPendampingan,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    item.formattedDate,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Konten Terstruktur
          if (parsed.isStructured) ...[
            // 1. Topik Bimbingan
            if (parsed.topik != null && parsed.topik!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_rounded, size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Topik Bimbingan',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            parsed.topik!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 2. Permasalahan Siswa
            if (parsed.permasalahan != null && parsed.permasalahan!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person_pin_rounded, size: 18, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Permasalahan / Cerita Siswa',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${parsed.permasalahan}"',
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontStyle: FontStyle.italic, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 3. Tanggapan Guru
            if (parsed.tanggapan != null && parsed.tanggapan!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.record_voice_over_rounded, size: 18, color: Color(0xFF059669)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Arahan & Tanggapan Guru Wali',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            parsed.tanggapan!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // 4. Ulasan & Refleksi Siswa
            if (parsed.ulasan != null && parsed.ulasan!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ulasan & Refleksi Siswa',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            parsed.ulasan!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ] else ...[
            // Konten Standar (Unstructured)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFF7C3AED)),
                      SizedBox(width: 6),
                      Text(
                        'Arahan & Materi Bimbingan',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    parsed.rawText,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Rencana Tindak Lanjut / Komitmen
          if (item.rencanaTindakLanjut != null && item.rencanaTindakLanjut!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rencana Tindak Lanjut / Komitmen',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.rencanaTindakLanjut!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Pembimbing & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.school_rounded, size: 14, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pembimbing: ${item.guruName}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      item.statusSesi,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String desc,
    String? buttonText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            if (buttonText != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: onAction,
              ),
            ],
          ],
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
            const Icon(Icons.cloud_off_rounded, size: 52, color: Color(0xFFDC2626)),
            const SizedBox(height: 14),
            const Text(
              'Gagal Memuat Data SI-WALI',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Terjadi kesalahan sistem.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

// ==================== SLIVER DELEGATE ====================

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

/// Helper Class Pengurai Konten Bimbingan Terstruktur
class _StructuredKlasikalContent {
  final String? topik;
  final String? permasalahan;
  final String? tanggapan;
  final String? ulasan;
  final String rawText;
  final bool isStructured;

  const _StructuredKlasikalContent({
    this.topik,
    this.permasalahan,
    this.tanggapan,
    this.ulasan,
    required this.rawText,
    required this.isStructured,
  });

  factory _StructuredKlasikalContent.parse(String text) {
    final trimmed = text.trim();
    final hasKeys = trimmed.contains('Topik:') ||
        trimmed.contains('Permasalahan Siswa:') ||
        trimmed.contains('Tanggapan Guru:') ||
        trimmed.contains('Ulasan & Refleksi Siswa:');

    if (!hasKeys) {
      return _StructuredKlasikalContent(rawText: trimmed, isStructured: false);
    }

    String? topik;
    String? permasalahan;
    String? tanggapan;
    String? ulasan;

    final topikMatch = RegExp(
      r'Topik:\s*(.*?)(?=\n\s*(?:Permasalahan Siswa:|Tanggapan Guru:|Ulasan & Refleksi Siswa:|$))',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (topikMatch != null) {
      topik = topikMatch.group(1)?.trim();
      if (topik != null && topik.startsWith('"') && topik.endsWith('"') && topik.length > 2) {
        topik = topik.substring(1, topik.length - 1).trim();
      }
    }

    final permasalahanMatch = RegExp(
      r'Permasalahan Siswa:\s*(.*?)(?=\n\s*(?:Tanggapan Guru:|Ulasan & Refleksi Siswa:|$))',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (permasalahanMatch != null) {
      permasalahan = permasalahanMatch.group(1)?.trim();
      if (permasalahan != null &&
          ((permasalahan.startsWith("'") && permasalahan.endsWith("'")) ||
              (permasalahan.startsWith('"') && permasalahan.endsWith('"'))) &&
          permasalahan.length > 2) {
        permasalahan = permasalahan.substring(1, permasalahan.length - 1).trim();
      }
    }

    final tanggapanMatch = RegExp(
      r'Tanggapan Guru:\s*(.*?)(?=\n\s*(?:Ulasan & Refleksi Siswa:|$))',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (tanggapanMatch != null) {
      tanggapan = tanggapanMatch.group(1)?.trim();
    }

    final ulasanMatch = RegExp(
      r'Ulasan & Refleksi Siswa:\s*(.*)',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (ulasanMatch != null) {
      ulasan = ulasanMatch.group(1)?.trim();
    }

    return _StructuredKlasikalContent(
      topik: topik,
      permasalahan: permasalahan,
      tanggapan: tanggapan,
      ulasan: ulasan,
      rawText: trimmed,
      isStructured: true,
    );
  }
}

// ==================== MODAL SUB-COMPONENTS ====================

/// Modal Form Curhat / Mulai Bercerita
class _ModalCurhatForm extends StatefulWidget {
  final SiswaGuruWaliService service;
  final String identifier;
  final VoidCallback onSuccess;

  const _ModalCurhatForm({
    required this.service,
    required this.identifier,
    required this.onSuccess,
  });

  @override
  State<_ModalCurhatForm> createState() => _ModalCurhatFormState();
}

class _ModalCurhatFormState extends State<_ModalCurhatForm> {
  final _formKey = GlobalKey<FormState>();
  String _kategori = 'Akademik';
  String _mode = 'Tatap Muka';
  final TextEditingController _topikController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  DateTime? _usulanWaktu;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _topikController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
      );

      if (time != null && mounted) {
        setState(() {
          _usulanWaktu = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.service.createKonsultasi(
        kategori: _kategori,
        mode: _mode,
        topik: _topikController.text.trim(),
        detail: _detailController.text.trim(),
        usulanTanggalWaktu: _usulanWaktu?.toIso8601String(),
        identifier: widget.identifier,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Mulai Bercerita ke Guru Wali',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pilihan Kategori (4 Pilar)
                    const Text(
                      'Pilih Kategori Permasalahan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Akademik',
                        'Karakter & Kedisiplinan',
                        'Minat & Bakat / Ekskul',
                        'Sosial & Psikologis',
                      ].map((cat) {
                        final isSel = _kategori == cat;
                        return ChoiceChip(
                          selected: isSel,
                          showCheckmark: false,
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              color: isSel ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selectedColor: const Color(0xFF2563EB),
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (_) => setState(() => _kategori = cat),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Pilihan Mode
                    const Text(
                      'Mode Konsultasi yang Diinginkan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _mode = 'Tatap Muka'),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _mode == 'Tatap Muka' ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _mode == 'Tatap Muka' ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                  width: _mode == 'Tatap Muka' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.people_alt_rounded,
                                    size: 20,
                                    color: _mode == 'Tatap Muka' ? const Color(0xFF2563EB) : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Tatap Muka',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _mode == 'Tatap Muka' ? const Color(0xFF2563EB) : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() => _mode = 'Pesan Portal'),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _mode == 'Pesan Portal' ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _mode == 'Pesan Portal' ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                  width: _mode == 'Pesan Portal' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_rounded,
                                    size: 20,
                                    color: _mode == 'Pesan Portal' ? const Color(0xFF2563EB) : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pesan Portal',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _mode == 'Pesan Portal' ? const Color(0xFF2563EB) : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Topik Konsultasi
                    const Text(
                      'Topik Konsultasi',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _topikController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Kesulitan belajar matematika, merasa cemas, dsb.',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().length < 5) return 'Topik minimal 5 karakter.';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Detail Permasalahan
                    const Text(
                      'Ceritakan Kendala / Hal yang Ingin Dikonsultasikan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _detailController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan secara terbuka dan jujur. Pesan ini bersifat privat antara Anda dan Guru Wali asuh Anda...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().length < 10) return 'Ceritakan lebih detail (minimal 10 karakter).';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Usulan Waktu Tatap Muka
                    if (_mode == 'Tatap Muka') ...[
                      const Text(
                        'Usulan Waktu Pertemuan (Opsional)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickDateTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _usulanWaktu != null
                                      ? '${_usulanWaktu!.day}/${_usulanWaktu!.month}/${_usulanWaktu!.year} pukul ${_usulanWaktu!.hour.toString().padLeft(2, '0')}:${_usulanWaktu!.minute.toString().padLeft(2, '0')}'
                                      : 'Pilih Usulan Tanggal & Jam',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _usulanWaktu != null ? AppColors.textPrimary : Colors.grey,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Tombol Kirim
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Kirimkan Cerita / Konsultasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal Detail Konsultasi & Thread Obrolan Pesan Siswa-Guru
class _ModalDetailKonsultasi extends StatefulWidget {
  final SiswaGuruWaliService service;
  final String identifier;
  final SiswaKonsultasiItem initialItem;
  final VoidCallback onChanged;

  const _ModalDetailKonsultasi({
    required this.service,
    required this.identifier,
    required this.initialItem,
    required this.onChanged,
  });

  @override
  State<_ModalDetailKonsultasi> createState() => _ModalDetailKonsultasiState();
}

class _ModalDetailKonsultasiState extends State<_ModalDetailKonsultasi> {
  late SiswaKonsultasiItem _item;
  List<SiswaPesanItem> _messages = [];
  bool _isLoading = true;
  final TextEditingController _pesanController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _item = widget.initialItem;
    _fetchDetail();
  }

  @override
  void dispose() {
    _pesanController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    try {
      final res = await widget.service.getKonsultasiDetail(
        id: _item.id,
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _item = res.item;
          _messages = res.messages;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _pesanController.text.trim();
    if (text.length < 2) return;

    setState(() => _isSending = true);

    try {
      final newMsg = await widget.service.sendPesan(
        id: _item.id,
        pesan: text,
        identifier: widget.identifier,
      );

      _pesanController.clear();

      if (mounted) {
        setState(() {
          _messages.add(newMsg);
          _isSending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _cancelKonsultasi() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Konsultasi?'),
        content: const Text('Apakah Anda yakin ingin membatalkan permohonan konsultasi ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Kembali')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await widget.service.cancelKonsultasi(id: _item.id, identifier: widget.identifier);
        if (mounted) {
          Navigator.pop(context);
          widget.onChanged();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }

  void _showFeedbackDialog() {
    int rating = 5;
    String emoji = 'Lega';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Ulasan Sesi Bimbingan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bagaimana perasaan Anda setelah sesi ini?', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Lega', 'Biasa', 'Masih Bingung'].map((e) {
                      final isSel = emoji == e;
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setDialogState(() => emoji = e),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              color: isSel ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text('Rating Bintang:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 28,
                        ),
                        tooltip: 'Beri ${index + 1} bintang',
                        onPressed: () => setDialogState(() => rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Pesan / catatan kesan (opsional)',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                onPressed: () async {
                  await widget.service.submitFeedback(
                    id: _item.id,
                    rating: rating,
                    emoji: emoji,
                    note: noteController.text.trim(),
                    identifier: widget.identifier,
                  );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    _fetchDetail();
                    widget.onChanged();
                  }
                },
                child: const Text('Kirim Ulasan'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _item.topik,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Status & Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFFF8FAFC),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Guru Wali: ${_item.guruName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _item.statusLabel,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF2563EB)),
                                  ),
                                ),
                              ],
                            ),
                            if (_item.formattedJadwalPasti != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.event_available_rounded, size: 16, color: Color(0xFF059669)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Jadwal: ${_item.formattedJadwalPasti}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF065F46)),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              _item.detail,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ],
                        ),
                      ),

                      // Thread Percakapan Pesan
                      Expanded(
                        child: _messages.isEmpty
                            ? Center(
                                child: Text(
                                  _item.mode == 'Pesan Portal'
                                      ? 'Belum ada pesan obrolan.\nTulis pesan di bawah untuk memulai.'
                                      : 'Konsultasi ini menggunakan mode Tatap Muka.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final msg = _messages[index];
                                  return Align(
                                    alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                      decoration: BoxDecoration(
                                        color: msg.isMe ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(14),
                                          topRight: const Radius.circular(14),
                                          bottomLeft: Radius.circular(msg.isMe ? 14 : 2),
                                          bottomRight: Radius.circular(msg.isMe ? 2 : 14),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg.pesan,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: msg.isMe ? Colors.white : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            msg.formattedTime,
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: msg.isMe ? Colors.white70 : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Baris Input Pesan atau Tombol Aksi
                      if (_item.canChat) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _pesanController,
                                  decoration: InputDecoration(
                                    hintText: 'Tulis pesan balasan...',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: _isSending
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.send_rounded, color: Color(0xFF2563EB)),
                                tooltip: 'Kirim pesan balasan',
                                onPressed: _isSending ? null : _sendMessage,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Tombol Feedback atau Batalkan
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            if (_item.isCancellable) ...[
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFDC2626),
                                    side: const BorderSide(color: Color(0xFFDC2626)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: _cancelKonsultasi,
                                  child: const Text('Batalkan Konsultasi Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                            if (_item.canFeedback) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF059669),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: const Icon(Icons.star_outline_rounded),
                                  label: Text(
                                    _item.feedbackRating != null ? 'Ubah Ulasan Sesi' : 'Beri Ulasan Bimbingan',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: _showFeedbackDialog,
                                ),
                              ),
                            ],
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
}
