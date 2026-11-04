import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../core/config/app_config.dart';
import '../models/guru_wali_dashboard_model.dart';
import '../models/jurnal_guru_wali_model.dart';
import '../models/konsultasi_guru_wali_model.dart';
import '../services/guru_wali_service.dart';
import 'detail_presensi_siswa_screen.dart';
import 'widgets/guru_wali/chat_konsultasi_sheet.dart';
import 'widgets/guru_wali/dialog_cetak_pdf.dart';
import 'widgets/guru_wali/modal_jurnal_individu.dart';
import 'widgets/guru_wali/modal_jurnal_klasikal.dart';
import 'widgets/guru_wali/modal_pemantauan_sheet.dart';
import 'widgets/guru_wali/sections/guru_wali_action_bar.dart';
import 'widgets/guru_wali/sections/guru_wali_hero_header.dart';
import 'widgets/guru_wali/sections/guru_wali_tab_switcher.dart';
import 'widgets/guru_wali/tabs/tab_riwayat_jurnal.dart';
import 'widgets/guru_wali/tabs/tab_ruang_aman_cerita.dart';
import 'widgets/guru_wali/tabs/tab_siswa_asuh.dart';

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
    this.schoolName = '',
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
    _activeTabIndex =
        widget.initialKonsultasiId != null ? 2 : widget.initialTabIndex;
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
        kategori:
            _selectedPilarFilter == 'semua' ? null : _selectedPilarFilter,
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
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ModalJurnalKlasikal(
          siswaList: list,
          service: _service,
        ),
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
      useSafeArea: true,
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
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ModalJurnalIndividu(
          siswa: siswa,
          service: _service,
        ),
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

  void _onBukaDetailPresensiSiswa(String studentId, String studentName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailPresensiSiswaScreen(
          studentId: studentId,
          studentName: studentName,
          token: widget.token,
          identifier: widget.identifier,
        ),
      ),
    );
  }

  void _openChat(String konsultasiId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
              widget.schoolName.isNotEmpty
                  ? widget.schoolName
                  : AppConfig.appName,
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
                  color: Colors.black.withValues(alpha: 0.04),
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
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
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
            GuruWaliHeroHeader(
              data: data,
              defaultTeacherName: widget.teacherName,
            ),
            const SizedBox(height: 12),

            // 2. ACTION BAR CEPAT
            GuruWaliActionBar(
              onTambahKlasikal: _onTambahKlasikal,
              onBukaPemantauan: _onBukaPemantauan,
              onCetakPdf: _onCetakPdf,
            ),
            const SizedBox(height: 14),

            // 3. SEGMENTED TAB SWITCHER
            GuruWaliTabSwitcher(
              activeTabIndex: _activeTabIndex,
              totalSiswaAktif: data.siswaAktif.length,
              pendingCeritaCount: data.statistik.pendingKonsultasiCount,
              onTabChanged: (index) {
                setState(() => _activeTabIndex = index);
                if (index == 1 && _jurnals.isEmpty) {
                  _loadJurnals();
                } else if (index == 2 && _konsultasis.isEmpty) {
                  _loadKonsultasi();
                }
              },
            ),
            const SizedBox(height: 14),

            // 4. KONTEN TAB SESUAI PILIHAN
            if (_activeTabIndex == 0)
              TabSiswaAsuh(
                data: data,
                siswaSubTab: _siswaSubTab,
                onSubTabChanged: (key) => setState(() => _siswaSubTab = key),
                searchController: _searchSiswaController,
                searchQuery: _searchSiswaQuery,
                onSearchChanged: (val) {
                  _searchSiswaQuery = val;
                  _loadDashboard();
                },
                onSearchCleared: () {
                  _searchSiswaController.clear();
                  _searchSiswaQuery = '';
                  _loadDashboard();
                },
                onBukaDetailPresensi: _onBukaDetailPresensiSiswa,
                onBukaCeritaTab: () {
                  setState(() => _activeTabIndex = 2);
                  _loadKonsultasi();
                },
                onTambahJurnal: _onTambahJurnalIndividu,
                onLihatRiwayat: _onLihatRiwayatSiswa,
              )
            else if (_activeTabIndex == 1)
              TabRiwayatJurnal(
                isLoading: _isLoadingJurnal,
                jurnals: _jurnals,
                selectedPilarFilter: _selectedPilarFilter,
                onPilarFilterChanged: (key) {
                  setState(() => _selectedPilarFilter = key);
                  _loadJurnals();
                },
                searchController: _searchJurnalController,
                onSearchChanged: (val) => _loadJurnals(),
              )
            else
              TabRuangAmanCerita(
                isLoading: _isLoadingKonsultasi,
                konsultasis: _konsultasis,
                statusFilter: _konsultasiStatusFilter,
                onStatusFilterChanged: (key) {
                  setState(() => _konsultasiStatusFilter = key);
                  _loadKonsultasi();
                },
                onOpenChat: _openChat,
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
