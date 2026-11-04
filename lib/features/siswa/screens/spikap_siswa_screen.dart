import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_spikap_model.dart';
import '../services/siswa_spikap_service.dart';
import 'form_spikap_siswa_screen.dart';

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
    this.schoolName = 'SMP Negeri 3 Kedungreja',
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModalTrackingSpikap(
        laporanItem: item,
        service: _service,
        identifier: widget.identifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

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
              widget.schoolName,
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
                        _buildHeroBanner(),
                        const SizedBox(height: 14),
                        _buildHotlineBanner(),
                        const SizedBox(height: 14),
                        _buildSummaryMetrics(),
                        const SizedBox(height: 14),
                        _buildSearchSection(),
                        const SizedBox(height: 14),
                        _buildLaporanSection(isTablet),
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

  Widget _buildHeroBanner() {
    final branding = _dashboardData?.branding;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFF9F1239)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33E11D48),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lencana Hero SPIKAP
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 12, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'SPIKAP • Ruang Aman & Layanan Pengaduan Murid',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branding?.namaAplikasi ?? 'SPIKAP',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      branding?.subJudul ?? 'Anti-Perundungan & Pengaduan Siswa',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            branding?.penjelasan ??
                'Ruang aman, nyaman, dan terlindungi kerahasiaannya untuk menyampaikan aduan perundungan, kekerasan fisik/verbal, atau perselisihan di sekolah.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotlineBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFFE11D48), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Perlindungan Kerahasiaan Terjamin',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9F1239),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Untuk situasi darurat/kritis, pilih opsi "🚨 Darurat" agar laporan langsung diteruskan hari ini juga ke Kepala Sekolah dan Tim Penanganan Kekerasan.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF881337), height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grid 2 Baris x 3 Kolom Kotak Metrik SPIKAP (Tepat 3 Kotak per Baris, Tanpa Scroll Horizontal)
  Widget _buildSummaryMetrics() {
    final counts = _dashboardData?.counts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Baris 1: Status Aduan (3 Kotak: Semua Aduan, Diterima, Investigasi)
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Semua Aduan',
                  count: counts?.total ?? 0,
                  icon: Icons.shield_outlined,
                  color: const Color(0xFFE11D48),
                  bg: const Color(0xFFFFF1F2),
                  isSelected: _activeMetric == 'all',
                  onTap: () => _selectMetric('all'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Diterima',
                  count: counts?.diterima ?? 0,
                  icon: Icons.hourglass_top_rounded,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFFFBEB),
                  isSelected: _activeMetric == 'diterima',
                  onTap: () => _selectMetric('diterima'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Investigasi',
                  count: counts?.dalamInvestigasi ?? 0,
                  icon: Icons.policy_rounded,
                  color: const Color(0xFF0284C7),
                  bg: const Color(0xFFF0F9FF),
                  isSelected: _activeMetric == 'dalam_investigasi',
                  onTap: () => _selectMetric('dalam_investigasi'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Baris 2: Kelanjutan Status & Sifat (3 Kotak: Selesai, Darurat, Biasa)
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Selesai',
                  count: counts?.selesai ?? 0,
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFECFDF5),
                  isSelected: _activeMetric == 'selesai',
                  onTap: () => _selectMetric('selesai'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Darurat',
                  count: counts?.darurat ?? 0,
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFEF2F2),
                  isSelected: _activeMetric == 'darurat',
                  onTap: () => _selectMetric('darurat'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Biasa',
                  count: counts?.biasa ?? 0,
                  icon: Icons.info_outline_rounded,
                  color: const Color(0xFF7C3AED),
                  bg: const Color(0xFFF5F3FF),
                  isSelected: _activeMetric == 'biasa',
                  onTap: () => _selectMetric('biasa'),
                ),
              ),
            ],
          ),
        ],
      ),
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
                color: isSelected
                    ? color.withValues(alpha: 0.14)
                    : const Color(0xFF1E293B).withValues(alpha: 0.03),
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
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bagian Pencarian Bersih Tanpa Chip Filter Lagi di Bawahnya
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

  Widget _buildLaporanSection(bool isTablet) {
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
        return _buildLaporanCard(items[index]);
      },
    );
  }

  Widget _buildLaporanCard(SiswaSpikapLaporanItem item) {
    Color statusBg = const Color(0xFFF1F5F9);
    Color statusText = const Color(0xFF475569);

    if (item.status == 'diterima') {
      statusBg = const Color(0xFFFEF3C7);
      statusText = const Color(0xFF92400E);
    } else if (item.status == 'dalam_investigasi') {
      statusBg = const Color(0xFFE0F2FE);
      statusText = const Color(0xFF075985);
    } else if (item.status == 'selesai') {
      statusBg = const Color(0xFFD1FAE5);
      statusText = const Color(0xFF065F46);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.isDarurat ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
          width: item.isDarurat ? 1.5 : 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTrackingModal(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stripe atas untuk darurat
            if (item.isDarurat)
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFF97316)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Atas
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Sifat
                      if (item.isDarurat)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: const Text(
                            '🚨 Darurat',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFBE123C),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Biasa',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),

                      // Jenis Perundungan
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.labelJenis,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.labelStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Tujuan Penerima
                  Text(
                    'Tujuan: ${item.labelTujuan}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Uraian Kejadian
                  Text(
                    item.uraianKejadian,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info Tambahan & Bukti
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        item.createdAtFormatted ?? item.createdAtHuman ?? '',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      if (item.jumlahLampiran > 0) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.attach_file_rounded, size: 14, color: Color(0xFF2563EB)),
                        const SizedBox(width: 2),
                        Text(
                          '${item.jumlahLampiran} Bukti',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (item.lokasiKejadian != null && item.lokasiKejadian!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.lokasiKejadian!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Action Footer
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Tracking & Detail Kasus',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFE11D48)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal BottomSheet Detail Laporan & Timeline Alur Investigasi SPIKAP
class _ModalTrackingSpikap extends StatefulWidget {
  final SiswaSpikapLaporanItem laporanItem;
  final SiswaSpikapService service;
  final String identifier;

  const _ModalTrackingSpikap({
    required this.laporanItem,
    required this.service,
    required this.identifier,
  });

  @override
  State<_ModalTrackingSpikap> createState() => _ModalTrackingSpikapState();
}

class _ModalTrackingSpikapState extends State<_ModalTrackingSpikap> {
  bool _isLoading = true;
  SiswaSpikapDetailResponse? _detailData;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final detail = await widget.service.getLaporanDetail(
        widget.laporanItem.id,
        identifier: widget.identifier,
      );
      if (mounted) {
        setState(() {
          _detailData = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _showImageDialog(String url, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                tooltip: 'Tutup Foto',
                onPressed: () => Navigator.pop(context),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (context, url) => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: const Text('Gagal memuat pratinjau gambar.'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _detailData?.laporan ?? widget.laporanItem;
    final logs = _detailData?.trackingLogs ?? [];
    final lampiranList = _detailData?.lampiran ?? [];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Modal
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan #${item.id} (${item.labelSifat})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item.createdAtFormatted ?? '',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMsg != null
                    ? Center(
                        child: Text(_errorMsg!, style: const TextStyle(color: Color(0xFFE11D48))),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info Ringkas
                            _buildSummaryCard(item),
                            const SizedBox(height: 20),

                            // Uraian Kejadian
                            const Text(
                              'Uraian Kejadian Dilaporkan:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                item.uraianKejadian,
                                style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Lampiran Bukti
                            if (lampiranList.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.attach_file_rounded, size: 18, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Berkas Bukti Terlampir (${lampiranList.length}):',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...lampiranList.map((lamp) => _buildLampiranTile(lamp)),
                              const SizedBox(height: 20),
                            ],

                            // Alur Tracking Investigasi
                            Row(
                              children: const [
                                Icon(Icons.timeline_rounded, size: 18, color: Color(0xFFE11D48)),
                                SizedBox(width: 6),
                                Text(
                                  'Perkembangan Penanganan Kasus:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            if (logs.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Laporan telah diterima sistem dan sedang menunggu tinjauan dari Guru / Tim TPPK.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  return _buildTimelineStep(
                                    logs[index],
                                    isLast: index == logs.length - 1,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(SiswaSpikapLaporanItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildItemMeta('Jenis Perundungan', item.labelJenis),
              ),
              Expanded(
                child: _buildItemMeta('Sifat Laporan', item.labelSifat),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildItemMeta('Tujuan', item.labelTujuan),
              ),
              Expanded(
                child: _buildItemMeta('Status Kasus', item.labelStatus),
              ),
            ],
          ),
          if (item.lokasiKejadian != null && item.lokasiKejadian!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildItemMeta('Lokasi Kejadian', item.lokasiKejadian!),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemMeta(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildLampiranTile(SiswaSpikapLampiranItem lamp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            lamp.isFoto ? Icons.image_rounded : Icons.videocam_rounded,
            color: lamp.isFoto ? const Color(0xFF2563EB) : const Color(0xFFE11D48),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lamp.namaAsli,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  lamp.ukuranLabel,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (lamp.isFoto)
            TextButton.icon(
              icon: const Icon(Icons.visibility_rounded, size: 16),
              label: const Text('Lihat'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => _showImageDialog(lamp.url, lamp.namaAsli),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(SiswaSpikapTrackingLog log, {required bool isLast}) {
    Color stepColor = const Color(0xFF2563EB);
    IconData stepIcon = Icons.hourglass_top_rounded;

    if (log.statusBaru == 'selesai') {
      stepColor = const Color(0xFF059669);
      stepIcon = Icons.check_circle_rounded;
    } else if (log.statusBaru == 'dalam_investigasi') {
      stepColor = const Color(0xFF0284C7);
      stepIcon = Icons.search_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: stepColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: stepColor, width: 1.5),
              ),
              child: Icon(stepIcon, color: stepColor, size: 14),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.labelStatusBaru,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: stepColor,
                      ),
                    ),
                    Text(
                      log.createdAtFormatted ?? '',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Oleh: ${log.petugas.nama} (${log.petugas.peran})',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  log.catatan,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
