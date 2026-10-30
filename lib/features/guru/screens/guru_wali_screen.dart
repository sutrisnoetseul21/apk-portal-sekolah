import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/guru_wali_dashboard_model.dart';
import '../models/jurnal_guru_wali_model.dart';
import '../models/konsultasi_guru_wali_model.dart';
import '../services/guru_wali_service.dart';
import 'widgets/guru_wali/modal_jurnal_individu.dart';
import 'widgets/guru_wali/modal_jurnal_klasikal.dart';
import 'widgets/guru_wali/modal_pemantauan_sheet.dart';
import 'widgets/guru_wali/dialog_cetak_pdf.dart';
import 'widgets/guru_wali/chat_konsultasi_sheet.dart';

/// Halaman Utama Menu 5: Guru Wali (SI-WALI)
/// Mengimplementasikan Single Command Center (Layar Utama Terpadu)
/// dengan Model Kotak-Kotak (Grid Cards 2 Kolom) Siswa Asuh
class GuruWaliScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;
  final String? initialKonsultasiId;
  final int initialTabIndex;

  const GuruWaliScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    this.schoolName = 'SMP Negeri 3 Kedungreja',
    this.initialKonsultasiId,
    this.initialTabIndex = 0,
  });

  @override
  State<GuruWaliScreen> createState() => _GuruWaliScreenState();
}

class _GuruWaliScreenState extends State<GuruWaliScreen> {
  late final GuruWaliService _service;

  bool _isLoading = true;
  String? _errorMessage;

  // Active Tab: 0 = Siswa Asuh (Grid), 1 = Riwayat Jurnal, 2 = Ruang Aman Cerita
  int _activeTabIndex = 0;

  // Data Dashboard
  GuruWaliDashboardResponse? _dashboardResponse;
  GuruWaliDashboardData? get _dashboardData => _dashboardResponse?.data;

  // Sub Tab di Tab Siswa Asuh: 'aktif' | 'arsip'
  String _siswaSubTab = 'aktif';
  final TextEditingController _searchSiswaController = TextEditingController();
  String _searchSiswaQuery = '';

  // Tab 2: Riwayat Jurnal
  bool _isLoadingJurnal = false;
  List<JurnalGuruWaliItem> _jurnals = [];
  String _selectedPilarFilter = 'semua';
  final TextEditingController _searchJurnalController = TextEditingController();

  // Tab 3: Ruang Aman Cerita
  bool _isLoadingKonsultasi = false;
  List<KonsultasiGuruWaliItem> _konsultasis = [];
  String _konsultasiStatusFilter = 'semua';

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialKonsultasiId != null ? 2 : widget.initialTabIndex;
    _service = GuruWaliService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    _loadDashboard();
    if (widget.initialKonsultasiId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openChat(widget.initialKonsultasiId!);
      });
    }
  }

  @override
  void dispose() {
    _searchSiswaController.dispose();
    _searchJurnalController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _service.getDashboard(search: _searchSiswaQuery);
      if (mounted) {
        setState(() {
          _dashboardResponse = res;
          _isLoading = false;
        });

        // Muat tab lain jika aktif
        if (_activeTabIndex == 1) {
          _loadJurnals();
        } else if (_activeTabIndex == 2) {
          _loadKonsultasi();
        }
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

  Future<void> _loadJurnals() async {
    setState(() => _isLoadingJurnal = true);
    try {
      final res = await _service.getJurnalList(
        kategori: _selectedPilarFilter == 'semua' ? null : _selectedPilarFilter,
        search: _searchJurnalController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _jurnals = res.data;
          _isLoadingJurnal = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingJurnal = false);
      }
    }
  }

  Future<void> _loadKonsultasi() async {
    setState(() => _isLoadingKonsultasi = true);
    try {
      final res = await _service.getKonsultasiList(
        status: _konsultasiStatusFilter,
      );
      if (mounted) {
        setState(() {
          _konsultasis = res.data;
          _isLoadingKonsultasi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingKonsultasi = false);
      }
    }
  }

  // =========================================================================
  // AKSI CEPAT ACTION BAR
  // =========================================================================

  void _onTambahKlasikal() {
    final list = _dashboardData?.siswaAktif ?? [];
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada siswa aktif dalam kelompok dampingan ini.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalJurnalKlasikal(
        siswaList: list,
        service: _service,
      ),
    ).then((res) {
      if (res == true) {
        _loadDashboard();
      }
    });
  }

  void _onBukaPemantauan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalPemantauanSheet(
        service: _service,
      ),
    );
  }

  void _onCetakPdf() {
    showDialog(
      context: context,
      builder: (_) => DialogCetakPdf(
        service: _service,
      ),
    );
  }

  void _onTambahJurnalIndividu(SiswaAsuhModel siswa) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModalJurnalIndividu(
        siswa: siswa,
        service: _service,
      ),
    ).then((res) {
      if (res == true) {
        _loadDashboard();
      }
    });
  }

  void _onLihatRiwayatSiswa(SiswaAsuhModel siswa) {
    setState(() {
      _activeTabIndex = 1;
      _searchJurnalController.text = siswa.name;
    });
    _loadJurnals();
  }

  void _openChat(String konsultasiId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChatKonsultasiSheet(
        konsultasiId: konsultasiId,
        service: _service,
        onUpdated: () {
          _loadKonsultasi();
          _loadDashboard();
        },
      ),
    ).then((_) {
      _loadKonsultasi();
      _loadDashboard();
    });
  }

  // =========================================================================
  // BUILD UTAMA
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guru Wali (SI-WALI)',
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
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: SpinKitThreeBounce(
          color: Color(0xFF2563EB),
          size: 32.0,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDashboard,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_dashboardResponse?.hasKelompok == false) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.groups_outlined,
                      size: 48, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Penugasan Guru Wali',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _dashboardResponse?.message ??
                      'Anda belum ditugaskan sebagai Guru Wali kelompok asuh aktif oleh pihak sekolah.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = _dashboardData;
    if (data == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: const Color(0xFF2563EB),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO HEADER SUMMARY CARD
            _buildHeroHeader(data),

            const SizedBox(height: 12),

            // 2. ACTION BAR CEPAT
            _buildActionBar(),

            const SizedBox(height: 14),

            // 3. SEGMENTED TAB SWITCHER
            _buildTabSwitcher(data),

            const SizedBox(height: 14),

            // 4. KONTEN TAB SESUAI PILIHAN
            if (_activeTabIndex == 0)
              _buildTabSiswaAsuh(data)
            else if (_activeTabIndex == 1)
              _buildTabRiwayatJurnal()
            else
              _buildTabRuangAmanCerita(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // KOMPONEN 1: HERO HEADER SUMMARY CARD
  // =========================================================================

  Widget _buildHeroHeader(GuruWaliDashboardData data) {
    final kelompokName = data.kelompok?.namaKelompok ?? 'Kelompok Asuh';
    final teacherName = data.teacher?.name ?? widget.teacherName;
    final stats = data.statistik;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Permendikdasmen No. 11/2025
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  'SI-WALI • Permendikdasmen No. 11/2025',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Nama Kelompok & Guru
          Text(
            kelompokName,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pembimbing: $teacherName • 2 JP/Minggu',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),

          // 4 Metric Mini Stat Cards
          Row(
            children: [
              _buildMetricCard(
                label: 'Siswa Asuh',
                value: '${stats.totalSiswaAktif}',
                unit: 'anak',
                valueColor: Colors.white,
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                label: 'Didampingi',
                value: '${stats.totalDidampingiBulanIni}',
                unit: '/ ${stats.totalSiswaAktif}',
                valueColor: const Color(0xFF6EE7B7), // Emerald
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                label: 'Kepatuhan',
                value: '${stats.persenKepatuhan}%',
                unit: data.bulanIni,
                valueColor: stats.persenKepatuhan >= 100
                    ? const Color(0xFF6EE7B7)
                    : (stats.persenKepatuhan >= 50
                        ? const Color(0xFFFDE047)
                        : const Color(0xFFFCA5A5)),
              ),
              const SizedBox(width: 8),
              _buildMetricCard(
                label: 'Cerita Masuk',
                value: '${stats.pendingKonsultasiCount}',
                unit: 'respon',
                valueColor: stats.pendingKonsultasiCount > 0
                    ? const Color(0xFFFCA5A5)
                    : Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: valueColor,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    unit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // KOMPONEN 2: ACTION BAR CEPAT
  // =========================================================================

  Widget _buildActionBar() {
    return Row(
      children: [
        // Tombol + Bimbingan Klasikal
        Expanded(
          flex: 4,
          child: ElevatedButton.icon(
            onPressed: _onTambahKlasikal,
            icon: const Icon(Icons.group_add_rounded, size: 16),
            label: const Text(
              '+ Klasikal',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Tombol Pemantauan Progres
        Expanded(
          flex: 4,
          child: OutlinedButton.icon(
            onPressed: _onBukaPemantauan,
            icon: const Icon(Icons.bar_chart_rounded,
                size: 16, color: Color(0xFF334155)),
            label: const Text(
              'Pemantauan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Tombol Cetak PDF
        Expanded(
          flex: 3,
          child: OutlinedButton.icon(
            onPressed: _onCetakPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded,
                size: 15, color: Color(0xFFDC2626)),
            label: const Text(
              'PDF',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC2626),
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFFECACA)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // KOMPONEN 3: SEGMENTED TAB SWITCHER
  // =========================================================================

  Widget _buildTabSwitcher(GuruWaliDashboardData data) {
    final pendingCerita = data.statistik.pendingKonsultasiCount;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // Tab 0: Siswa Asuh
          _buildSegmentButton(
            index: 0,
            label: 'Siswa Asuh',
            count: data.siswaAktif.length,
          ),

          // Tab 1: Riwayat Jurnal
          _buildSegmentButton(
            index: 1,
            label: 'Riwayat Jurnal',
            count: null,
          ),

          // Tab 2: Ruang Aman Cerita
          _buildSegmentButton(
            index: 2,
            label: 'Ruang Cerita',
            count: pendingCerita > 0 ? pendingCerita : null,
            isAlertCount: pendingCerita > 0,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String label,
    int? count,
    bool isAlertCount = false,
  }) {
    final isSelected = _activeTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _activeTabIndex = index);
          if (index == 1 && _jurnals.isEmpty) {
            _loadJurnals();
          } else if (index == 2 && _konsultasis.isEmpty) {
            _loadKonsultasi();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
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
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF64748B),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isAlertCount
                        ? const Color(0xFFDC2626)
                        : (isSelected
                            ? const Color(0xFF2563EB).withOpacity(0.15)
                            : const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isAlertCount
                          ? Colors.white
                          : (isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF475569)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 1: MODEL KOTAK-KOTAK SISWA ASUH (GRID 2 KOLOM)
  // =========================================================================

  Widget _buildTabSiswaAsuh(GuruWaliDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-Tabs: Siswa Aktif vs Riwayat Arsip + Search Box
        Row(
          children: [
            // Switcher Aktif / Arsip
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  _buildSubTabButton('aktif', 'Aktif (${data.siswaAktif.length})'),
                  _buildSubTabButton('arsip', 'Arsip (${data.siswaArsip.length})'),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Search Bar
            Expanded(
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchSiswaController,
                  onChanged: (val) {
                    _searchSiswaQuery = val;
                    _loadDashboard();
                  },
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari nama / NISN...',
                    hintStyle: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchSiswaQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () {
                              _searchSiswaController.clear();
                              _searchSiswaQuery = '';
                              _loadDashboard();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Konten Grid / List
        if (_siswaSubTab == 'aktif')
          _buildGridSiswaAktif(data.siswaAktif)
        else
          _buildListSiswaArsip(data.siswaArsip),
      ],
    );
  }

  Widget _buildSubTabButton(String key, String label) {
    final isSelected = _siswaSubTab == key;
    return InkWell(
      onTap: () => setState(() => _siswaSubTab = key),
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  /// Model Kotak-Kotak (Grid Cards 2 Kolom) Siswa Asuh
  Widget _buildGridSiswaAktif(List<SiswaAsuhModel> list) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                size: 40, color: Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            const Text(
              'Tidak ada siswa yang sesuai',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _searchSiswaQuery.isNotEmpty
                  ? 'Coba kata kunci pencarian yang lain.'
                  : 'Belum ada siswa aktif yang ditambahkan oleh admin.',
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 550 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.76, // Kotak tegak proporsional
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final siswa = list[index];
            return _buildSiswaCardKotak(siswa);
          },
        );
      },
    );
  }

  /// Kartu Siswa Asuh Model Kotak
  Widget _buildSiswaCardKotak(SiswaAsuhModel siswa) {
    final hasBimbingan = siswa.hasBimbingan;
    final ringColor =
        hasBimbingan ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar dengan Ring Status & Rombel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar dengan Ring Status 🟢/🟡
              Stack(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ringColor, width: 2),
                    ),
                    child: ClipOval(
                      child: siswa.avatarUrl != null &&
                              siswa.avatarUrl!.isNotEmpty
                          ? Image.network(
                              siswa.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildAvatarFallback(siswa),
                            )
                          : _buildAvatarFallback(siswa),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: ringColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Rombel & Badge Cerita
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        siswa.kelasName,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    if (siswa.hasActiveKonsultasi) ...[
                      const SizedBox(height: 3),
                      GestureDetector(
                        onTap: () {
                          setState(() => _activeTabIndex = 2);
                          _loadKonsultasi();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            siswa.unreadKonsultasiCount > 0
                                ? '💬 ${siswa.unreadKonsultasiCount}'
                                : '💬 Cerita',
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Nama Siswa & NISN
          Text(
            siswa.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'NISN: ${siswa.nisn}',
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Status Dampingan Bulan Ini
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: hasBimbingan
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasBimbingan
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFFDE68A),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasBimbingan
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 11,
                      color: hasBimbingan
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hasBimbingan
                            ? 'Didampingi (${siswa.bimbinganCount}x)'
                            : 'Belum Dampingan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: hasBimbingan
                              ? const Color(0xFF065F46)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasBimbingan && siswa.lastBimbinganDateFormatted != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${siswa.lastBimbinganDateFormatted} • ${siswa.lastKategori ?? ""}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Action Buttons: [+ Jurnal] & [Riwayat]
          Row(
            children: [
              Expanded(
                flex: 5,
                child: InkWell(
                  onTap: () => _onTambahJurnalIndividu(siswa),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '+ Jurnal',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: () => _onLihatRiwayatSiswa(siswa),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(SiswaAsuhModel siswa) {
    final initial = siswa.name.isNotEmpty ? siswa.name[0].toUpperCase() : 'S';
    return Container(
      color: const Color(0xFF2563EB).withOpacity(0.12),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }

  Widget _buildListSiswaArsip(List<SiswaArsipModel> list) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'Belum ada riwayat siswa arsip/mutasi.',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.archive_outlined,
                    size: 16, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'NISN: ${item.nisn} • ${item.kelasName}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Th. ${item.tahunMasuk ?? "-"}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 2: RIWAYAT JURNAL
  // =========================================================================

  Widget _buildTabRiwayatJurnal() {
    if (_isLoadingJurnal) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: SpinKitThreeBounce(color: Color(0xFF2563EB), size: 28),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Pilar & Search
        Row(
          children: [
            Expanded(
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchJurnalController,
                  onChanged: (val) => _loadJurnals(),
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Cari topik / nama siswa...',
                    hintStyle: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 18, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Pilarnya: Chips Horizontal
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPilarChip('semua', 'Semua Pilar'),
              _buildPilarChip('Akademik', 'Akademik'),
              _buildPilarChip('Karakter & Kedisiplinan', 'Karakter'),
              _buildPilarChip('Minat & Bakat / Ekskul', 'Minat & Bakat'),
              _buildPilarChip('Sosial & Psikologis', 'Sosial-Psikologis'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // List Riwayat Jurnal
        if (_jurnals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'Belum ada catatan jurnal bimbingan.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _jurnals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final jurnal = _jurnals[index];
              return _buildJurnalItemCard(jurnal);
            },
          ),
      ],
    );
  }

  Widget _buildPilarChip(String key, String label) {
    final isSelected = _selectedPilarFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 10.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF2563EB),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (val) {
          setState(() => _selectedPilarFilter = key);
          _loadJurnals();
        },
      ),
    );
  }

  Widget _buildJurnalItemCard(JurnalGuruWaliItem jurnal) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Jenis & Pilar + Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${jurnal.jenisPendampingan} • ${jurnal.kategoriPendampingan}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              Text(
                jurnal.tanggalWaktuFormatted,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Nama Siswa & Kelas
          Text(
            jurnal.studentName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            '${jurnal.kelasName} • NISN: ${jurnal.studentNisn}',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 8),

          // Uraian Pembahasan
          Text(
            jurnal.uraianPembahasan,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF334155),
              height: 1.4,
            ),
          ),

          if (jurnal.rencanaTindakLanjut.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right_alt_rounded,
                      size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Tindak Lanjut: ${jurnal.rencanaTindakLanjut}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF475569),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Footer Status & Rujuk BK
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  jurnal.statusSesi,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
              if (jurnal.isRujukBk)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Dirujuk ke BK',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 3: RUANG AMAN CERITA (KONSULTASI SISWA)
  // =========================================================================

  Widget _buildTabRuangAmanCerita() {
    if (_isLoadingKonsultasi) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: SpinKitThreeBounce(color: Color(0xFF2563EB), size: 28),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildKonsultasiFilterChip('semua', 'Semua Status'),
              _buildKonsultasiFilterChip('menunggu', 'Menunggu Respon'),
              _buildKonsultasiFilterChip('dijadwalkan', 'Dijadwalkan'),
              _buildKonsultasiFilterChip('selesai', 'Selesai'),
              _buildKonsultasiFilterChip('ditolak', 'Ditolak'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (_konsultasis.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'Belum ada permohonan bimbingan/cerita dari siswa.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _konsultasis.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _konsultasis[index];
              return _buildKonsultasiCard(item);
            },
          ),
      ],
    );
  }

  Widget _buildKonsultasiFilterChip(String key, String label) {
    final isSelected = _konsultasiStatusFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 10.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF2563EB),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (val) {
          setState(() => _konsultasiStatusFilter = key);
          _loadKonsultasi();
        },
      ),
    );
  }

  Widget _buildKonsultasiCard(KonsultasiGuruWaliItem item) {
    Color badgeBg;
    Color badgeText;
    switch (item.statusPengajuan) {
      case 'Menunggu Konfirmasi':
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFB45309);
        break;
      case 'Dijadwalkan':
        badgeBg = const Color(0xFFDBEAFE);
        badgeText = const Color(0xFF1D4ED8);
        break;
      case 'Selesai':
      case 'Dikonversi ke Jurnal':
        badgeBg = const Color(0xFFD1FAE5);
        badgeText = const Color(0xFF047857);
        break;
      default:
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFB91C1C);
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openChat(item.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.statusPengajuan,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: badgeText,
                      ),
                    ),
                  ),
                  Text(
                    item.createdAtFormatted,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                item.studentName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '${item.kelasName} • Mode: ${item.modeKonsultasi} • [${item.kategoriPendampingan}]',
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 6),

              Text(
                item.topikKonsultasi,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.detailPermasalahan,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 10),

              // Action Button: Buka Percakapan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.unreadMessagesCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.unreadMessagesCount} Pesan Baru',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton.icon(
                    onPressed: () => _openChat(item.id),
                    icon: const Icon(Icons.forum_rounded, size: 14),
                    label: const Text(
                      'Buka Obrolan',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
