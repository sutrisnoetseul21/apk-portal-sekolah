import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_perpustakaan_model.dart';
import '../services/siswa_perpustakaan_service.dart';

/// Layar Menu 5: Perpustakaan Portal Siswa
/// Menampilkan ringkasan keanggotaan dan 3 Kotak Menu Interaktif:
/// 1. Sedang Dipinjam (Buku aktif + kalkulasi sisa hari & jatuh tempo)
/// 2. Riwayat Peminjaman (Buku yang pernah dipinjam & sudah dikembalikan)
/// 3. Riwayat Kunjungan (Catatan absensi fisik siswa di perpustakaan)
/// Sesuai permintaan pengguna, modul pencarian/katalog buku publik ditiadakan.
class PerpustakaanSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;
  final SiswaPerpustakaanService? service;

  const PerpustakaanSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = 'SMP Negeri 3 Kedungreja',
    this.token,
    this.service,
  });

  @override
  State<PerpustakaanSiswaScreen> createState() => _PerpustakaanSiswaScreenState();
}

class _PerpustakaanSiswaScreenState extends State<PerpustakaanSiswaScreen> {
  late SiswaPerpustakaanService _service;

  // 0: Sedang Dipinjam, 1: Riwayat Pinjam, 2: Riwayat Kunjungan
  int _selectedTabIndex = 0;

  bool _isLoading = true;
  String? _errorMessage;

  SiswaPerpustakaanSummaryResponse? _summaryData;

  // Tab 0: Sedang Dipinjam
  bool _isLoadingAktif = false;
  SiswaPinjamanAktifResponse? _aktifData;

  // Tab 1: Riwayat Pinjam
  bool _isLoadingRiwayat = false;
  SiswaRiwayatPinjamResponse? _riwayatData;
  final TextEditingController _searchRiwayatController = TextEditingController();

  // Tab 2: Riwayat Kunjungan
  bool _isLoadingKunjungan = false;
  SiswaRiwayatKunjunganResponse? _kunjunganData;

  @override
  void initState() {
    super.initState();
    _service = widget.service ??
        SiswaPerpustakaanService.create(
          token: widget.token,
          identifier: widget.identifier,
        );
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchRiwayatController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await _service.getSummary(identifier: widget.identifier);
      final aktif = await _service.getPinjamanAktif(identifier: widget.identifier);
      final riwayat = await _service.getRiwayatPinjam(identifier: widget.identifier);
      final kunjungan = await _service.getRiwayatKunjungan(identifier: widget.identifier);

      if (mounted) {
        setState(() {
          _summaryData = summary;
          _aktifData = aktif;
          _riwayatData = riwayat;
          _kunjunganData = kunjungan;
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

  Future<void> _refreshAktif() async {
    setState(() => _isLoadingAktif = true);
    try {
      final res = await _service.getPinjamanAktif(identifier: widget.identifier);
      if (mounted) {
        setState(() {
          _aktifData = res;
          _isLoadingAktif = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAktif = false);
    }
  }

  Future<void> _refreshRiwayat() async {
    setState(() => _isLoadingRiwayat = true);
    try {
      final res = await _service.getRiwayatPinjam(
        search: _searchRiwayatController.text,
        identifier: widget.identifier,
      );
      if (mounted) {
        setState(() {
          _riwayatData = res;
          _isLoadingRiwayat = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRiwayat = false);
    }
  }

  Future<void> _refreshKunjungan() async {
    setState(() => _isLoadingKunjungan = true);
    try {
      final res = await _service.getRiwayatKunjungan(identifier: widget.identifier);
      if (mounted) {
        setState(() {
          _kunjunganData = res;
          _isLoadingKunjungan = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingKunjungan = false);
    }
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
              colors: [Color(0xFF3730A3), Color(0xFF4338CA), Color(0xFF4F46E5)],
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
              'Perpustakaan Siswa',
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
            tooltip: 'Segarkan Perpustakaan',
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: () async {
                    if (_selectedTabIndex == 0) {
                      await _refreshAktif();
                    } else if (_selectedTabIndex == 1) {
                      await _refreshRiwayat();
                    } else {
                      await _refreshKunjungan();
                    }
                  },
                  color: const Color(0xFF4F46E5),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Hero Banner Modern (Sesuai Referensi Web)
                        _buildHeroBanner(),

                        const SizedBox(height: 16),

                        // 2. Tiga Kotak Metrik Menu (Sedang Dipinjam, Riwayat, Kunjungan)
                        _buildMetricTabCards(),

                        const SizedBox(height: 18),

                        // 3. Konten Dinamis Berdasarkan Kotak yang Dipilih
                        if (_selectedTabIndex == 0)
                          _buildTabSedangDipinjam()
                        else if (_selectedTabIndex == 1)
                          _buildTabRiwayatPinjam()
                        else
                          _buildTabRiwayatKunjungan(),

                        const SizedBox(height: 24),
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
              _errorMessage ?? 'Terjadi kesalahan sistem saat memuat data perpustakaan.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Hero Banner Modern (Ungu Indigo sesuai http://localhost:8001/portal-siswa/perpustakaan)
  Widget _buildHeroBanner() {
    final student = _summaryData?.student;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF3730A3), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perpustakaan Sekolah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cari buku yang ingin kamu pinjam dan pantau riwayat peminjamannya.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE0E7FF),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Student Info Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, size: 14, color: Color(0xFFC7D2FE)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${student?.name ?? widget.studentName} • Kelas ${student?.kelas ?? '-'} • NISN: ${student?.nisn ?? widget.identifier}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Menu 3 Kotak (1 Baris 3 Kotak) seperti tampilan Guru Wali & SPIKAP
  Widget _buildMetricTabCards() {
    final pinjamanAktifCount = _aktifData?.total ?? _summaryData?.counts.pinjamanAktif ?? 0;
    final riwayatCount = _summaryData?.counts.totalRiwayatPinjam ?? 0;
    final kunjunganCount = _summaryData?.counts.totalKunjungan ?? 0;
    final terlambatCount = _summaryData?.counts.pinjamanTerlambat ?? 0;

    return Row(
      children: [
        // Kotak 1: Sedang Dipinjam
        Expanded(
          child: _buildMetricTabItem(
            index: 0,
            icon: Icons.auto_stories_rounded,
            title: 'Sedang Dipinjam',
            count: pinjamanAktifCount,
            hasAlert: terlambatCount > 0,
            alertText: '$terlambatCount terlambat',
          ),
        ),
        const SizedBox(width: 8),

        // Kotak 2: Riwayat Pinjam
        Expanded(
          child: _buildMetricTabItem(
            index: 1,
            icon: Icons.history_rounded,
            title: 'Riwayat Pinjam',
            count: riwayatCount,
          ),
        ),
        const SizedBox(width: 8),

        // Kotak 3: Riwayat Kunjungan
        Expanded(
          child: _buildMetricTabItem(
            index: 2,
            icon: Icons.badge_outlined,
            title: 'Kunjungan',
            count: kunjunganCount,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTabItem({
    required int index,
    required IconData icon,
    required String title,
    required int count,
    bool hasAlert = false,
    String? alertText,
  }) {
    final isSelected = _selectedTabIndex == index;
    final activeColor = const Color(0xFF4F46E5);

    return Semantics(
      button: true,
      label: '$title, $count item, ${isSelected ? 'terpilih' : 'tidak terpilih'}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? activeColor : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? activeColor : const Color(0xFF64748B),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? activeColor : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? activeColor : const Color(0xFF64748B),
                  ),
                ),
                if (hasAlert && alertText != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alertText,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── TAB 0: SEDANG DIPINJAM ────────────────────────────────────────────────
  Widget _buildTabSedangDipinjam() {
    final items = _aktifData?.items ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Card (Sesuai Referensi Web)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bookmark_added_rounded, color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Buku Yang Sedang Anda Pinjam',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Daftar buku perpustakaan yang saat ini masih Anda pinjam.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (_isLoadingAktif)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (items.isEmpty)
          // Tampilan Kosong Persis Web
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book_outlined, size: 40, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Anda saat ini tidak sedang meminjam buku perpustakaan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildPinjamanCard(items[index]),
          ),
      ],
    );
  }

  Widget _buildPinjamanCard(SiswaPinjamanItem item) {
    final isTerlambat = item.isTerlambat;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTerlambat ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
          width: isTerlambat ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTerlambat)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Buku
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 68,
                    height: 94,
                    color: const Color(0xFFF1F5F9),
                    child: item.buku.sampulUrl != null && item.buku.sampulUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.buku.sampulUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => _buildCoverFallback(),
                          )
                        : _buildCoverFallback(),
                  ),
                ),
                const SizedBox(width: 14),

                // Info Buku
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori & No. Eksemplar
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.buku.kategori,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.kodeEksemplar,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Judul Buku
                      Text(
                        item.buku.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Penulis
                      Text(
                        item.buku.penulis,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),

                      // Tanggal Pinjam & Batas Kembali
                      Row(
                        children: [
                          const Icon(Icons.event_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Pinjam: ${item.tanggalPinjamFormatted}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: isTerlambat ? const Color(0xFFE11D48) : const Color(0xFF059669),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Batas: ${item.tanggalJatuhTempoFormatted}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isTerlambat ? const Color(0xFFE11D48) : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Countdown Sisa Hari / Badge Status
                      if (isTerlambat)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFE11D48)),
                              const SizedBox(width: 4),
                              Text(
                                'Terlambat ${item.terlambatHari} Hari! Segera kembalikan',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFBE123C),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (item.sisaHari != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.sisaHari! <= 2 ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.sisaHari == 0
                                ? 'Jatuh tempo hari ini!'
                                : 'Sisa ${item.sisaHari} hari lagi',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item.sisaHari! <= 2 ? const Color(0xFF92400E) : const Color(0xFF065F46),
                            ),
                          ),
                        ),
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

  Widget _buildCoverFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.book_rounded, size: 28, color: Color(0xFF94A3B8)),
        SizedBox(height: 2),
        Text(
          'Buku',
          style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ─── TAB 1: RIWAYAT PEMINJAMAN ─────────────────────────────────────────────
  Widget _buildTabRiwayatPinjam() {
    final items = _riwayatData?.items ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history_rounded, color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Riwayat Peminjaman Buku',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Histori seluruh peminjaman buku yang telah Anda kembalikan.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Search Bar Riwayat Buku
        TextField(
          controller: _searchRiwayatController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _refreshRiwayat(),
          decoration: InputDecoration(
            hintText: 'Cari riwayat judul buku atau penulis...',
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
            suffixIcon: _searchRiwayatController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    tooltip: 'Hapus pencarian',
                    onPressed: () {
                      _searchRiwayatController.clear();
                      _refreshRiwayat();
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

        const SizedBox(height: 14),

        if (_isLoadingRiwayat)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: const [
                Icon(Icons.history_rounded, size: 44, color: Color(0xFF94A3B8)),
                SizedBox(height: 14),
                Text(
                  'Belum Ada Riwayat Peminjaman',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  'Buku yang sudah Anda kembalikan akan tercatat riwayatnya di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildRiwayatCard(items[index]),
          ),
      ],
    );
  }

  Widget _buildRiwayatCard(SiswaPinjamanItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 82,
              color: const Color(0xFFF1F5F9),
              child: item.buku.sampulUrl != null && item.buku.sampulUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.buku.sampulUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _buildCoverFallback(),
                    )
                  : _buildCoverFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.buku.kategori,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Sudah Dikembalikan',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.buku.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  item.buku.penulis,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.date_range_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Dipinjam: ${item.tanggalPinjamFormatted}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      'Kembali: ${item.tanggalKembaliFormatted}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF059669)),
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

  // ─── TAB 2: RIWAYAT KUNJUNGAN FISIK ────────────────────────────────────────
  Widget _buildTabRiwayatKunjungan() {
    final items = _kunjunganData?.items ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.badge_outlined, color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Catatan Kunjungan Fisik',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Histori presensi kehadiran fisik Anda di ruang perpustakaan.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (_isLoadingKunjungan)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.badge_outlined, size: 40, color: Color(0xFFD97706)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Riwayat Kunjungan Fisik',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Presensi kunjungan fisik perpustakaan Anda akan tercatat secara otomatis di sini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.login_rounded, color: Color(0xFF4F46E5), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.tanggalFormatted,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                item.waktuMasukFormatted,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.labelTujuan,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
