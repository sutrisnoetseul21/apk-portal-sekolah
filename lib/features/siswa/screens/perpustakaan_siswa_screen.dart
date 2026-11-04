import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_perpustakaan_model.dart';
import '../services/siswa_perpustakaan_service.dart';
import 'widgets/perpustakaan/sections/perpustakaan_siswa_hero_banner.dart';
import 'widgets/perpustakaan/sections/perpustakaan_siswa_metric_tabs.dart';
import 'widgets/perpustakaan/tabs/tab_pinjaman_aktif_siswa.dart';
import 'widgets/perpustakaan/tabs/tab_riwayat_kunjungan_siswa.dart';
import 'widgets/perpustakaan/tabs/tab_riwayat_pinjam_siswa.dart';

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
    this.schoolName = '',
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
    final pinjamanAktifCount = _aktifData?.total ?? _summaryData?.counts.pinjamanAktif ?? 0;
    final riwayatCount = _summaryData?.counts.totalRiwayatPinjam ?? 0;
    final kunjunganCount = _summaryData?.counts.totalKunjungan ?? 0;
    final terlambatCount = _summaryData?.counts.pinjamanTerlambat ?? 0;

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
                  widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName,
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
                        // 1. Hero Banner Modern
                        PerpustakaanSiswaHeroBanner(
                          student: _summaryData?.student,
                          fallbackStudentName: widget.studentName,
                          fallbackIdentifier: widget.identifier,
                        ),

                        const SizedBox(height: 16),

                        // 2. Tiga Kotak Metrik Menu (Sedang Dipinjam, Riwayat, Kunjungan)
                        PerpustakaanSiswaMetricTabs(
                          selectedIndex: _selectedTabIndex,
                          pinjamanAktifCount: pinjamanAktifCount,
                          riwayatCount: riwayatCount,
                          kunjunganCount: kunjunganCount,
                          terlambatCount: terlambatCount,
                          onTabSelected: (index) {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                        ),

                        const SizedBox(height: 18),

                        // 3. Konten Dinamis Berdasarkan Kotak yang Dipilih
                        if (_selectedTabIndex == 0)
                          TabPinjamanAktifSiswa(
                            isLoading: _isLoadingAktif,
                            items: _aktifData?.items ?? [],
                          )
                        else if (_selectedTabIndex == 1)
                          TabRiwayatPinjamSiswa(
                            isLoading: _isLoadingRiwayat,
                            items: _riwayatData?.items ?? [],
                            searchController: _searchRiwayatController,
                            onSearchSubmitted: _refreshRiwayat,
                            onSearchCleared: () {
                              _searchRiwayatController.clear();
                              _refreshRiwayat();
                            },
                          )
                        else
                          TabRiwayatKunjunganSiswa(
                            isLoading: _isLoadingKunjungan,
                            items: _kunjunganData?.items ?? [],
                          ),

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
}
