import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../models/perpustakaan_models.dart';
import '../services/perpustakaan_service.dart';
import 'widgets/detail_buku_bottom_sheet.dart';

/// Layar Utama Menu 8: Perpustakaan (Portal Guru)
class PerpustakaanScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;
  final int initialTab;

  const PerpustakaanScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    required this.schoolName,
    this.initialTab = 0,
  });

  @override
  State<PerpustakaanScreen> createState() => _PerpustakaanScreenState();
}

class _PerpustakaanScreenState extends State<PerpustakaanScreen> {
  late final PerpustakaanService _service;

  // Tab State (0: Katalog, 1: Pinjaman Pribadi, 2: Riwayat Pribadi, 3: Kunjungan, 4: Siswa)
  late int _selectedTabIndex;

  // Summary & Kategori State
  PerpustakaanSummary _summary = const PerpustakaanSummary();
  bool _isLoadingSummary = false;
  List<KategoriBuku> _kategoriList = [];

  // =========================================================================
  // TAB 1: KATALOG STATE
  // =========================================================================
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _selectedSortBy = 'terbaru'; // 'terbaru' | 'populer'
  String? _selectedKategoriId;

  final ScrollController _katalogScrollController = ScrollController();
  List<BukuItem> _katalogItems = [];
  bool _isLoadingKatalog = false;
  bool _isLoadingMoreKatalog = false;
  int _katalogPage = 1;
  bool _hasMoreKatalog = false;
  String? _katalogError;

  // =========================================================================
  // TAB 2: PINJAMAN PRIBADI STATE
  // =========================================================================
  final ScrollController _pinjamanSayaScrollController = ScrollController();
  List<PeminjamanGuruItem> _pinjamanSayaItems = [];
  bool _isLoadingPinjamanSaya = false;
  bool _isLoadingMorePinjamanSaya = false;
  int _pinjamanSayaPage = 1;
  bool _hasMorePinjamanSaya = false;
  String? _pinjamanSayaError;

  // =========================================================================
  // TAB 3: RIWAYAT PINJAMAN PRIBADI STATE
  // =========================================================================
  final ScrollController _riwayatPinjamanScrollController = ScrollController();
  List<PeminjamanGuruItem> _riwayatPinjamanItems = [];
  bool _isLoadingRiwayatPinjaman = false;
  bool _isLoadingMoreRiwayatPinjaman = false;
  int _riwayatPinjamanPage = 1;
  bool _hasMoreRiwayatPinjaman = false;
  String? _riwayatPinjamanError;

  // =========================================================================
  // TAB 4: RIWAYAT KUNJUNGAN PRIBADI STATE
  // =========================================================================
  final ScrollController _kunjunganScrollController = ScrollController();
  List<KunjunganGuruItem> _kunjunganItems = [];
  bool _isLoadingKunjungan = false;
  bool _isLoadingMoreKunjungan = false;
  int _kunjunganPage = 1;
  bool _hasMoreKunjungan = false;
  String? _kunjunganError;

  // =========================================================================
  // TAB 5: PEMINJAMAN SISWA KELAS AMPU STATE
  // =========================================================================
  final ScrollController _siswaScrollController = ScrollController();
  final TextEditingController _siswaSearchController = TextEditingController();
  Timer? _siswaDebounceTimer;

  List<KelasAmpuItem> _kelasList = [];
  KelasAmpuItem? _selectedKelas;
  bool _isLoadingKelas = false;

  List<PinjamanSiswaItem> _pinjamanSiswaItems = [];
  bool _isLoadingPinjamanSiswa = false;
  bool _isLoadingMorePinjamanSiswa = false;
  int _pinjamanSiswaPage = 1;
  bool _hasMorePinjamanSiswa = false;
  String? _pinjamanSiswaError;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab;
    _service = PerpustakaanService.create(
      token: widget.token,
      identifier: widget.identifier,
    );

    _katalogScrollController.addListener(_onKatalogScroll);
    _pinjamanSayaScrollController.addListener(_onPinjamanSayaScroll);
    _riwayatPinjamanScrollController.addListener(_onRiwayatPinjamanScroll);
    _kunjunganScrollController.addListener(_onKunjunganScroll);
    _siswaScrollController.addListener(_onSiswaScroll);

    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _siswaSearchController.dispose();
    _siswaDebounceTimer?.cancel();

    _katalogScrollController.dispose();
    _pinjamanSayaScrollController.dispose();
    _riwayatPinjamanScrollController.dispose();
    _kunjunganScrollController.dispose();
    _siswaScrollController.dispose();
    super.dispose();
  }

  void _onKatalogScroll() {
    if (_katalogScrollController.position.pixels >=
            _katalogScrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMoreKatalog &&
        _hasMoreKatalog) {
      _loadMoreKatalog();
    }
  }

  void _onPinjamanSayaScroll() {
    if (_pinjamanSayaScrollController.position.pixels >=
            _pinjamanSayaScrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMorePinjamanSaya &&
        _hasMorePinjamanSaya) {
      _loadMorePinjamanSaya();
    }
  }

  void _onRiwayatPinjamanScroll() {
    if (_riwayatPinjamanScrollController.position.pixels >=
            _riwayatPinjamanScrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMoreRiwayatPinjaman &&
        _hasMoreRiwayatPinjaman) {
      _loadMoreRiwayatPinjaman();
    }
  }

  void _onKunjunganScroll() {
    if (_kunjunganScrollController.position.pixels >=
            _kunjunganScrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMoreKunjungan &&
        _hasMoreKunjungan) {
      _loadMoreKunjungan();
    }
  }

  void _onSiswaScroll() {
    if (_siswaScrollController.position.pixels >=
            _siswaScrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMorePinjamanSiswa &&
        _hasMorePinjamanSiswa) {
      _loadMorePinjamanSiswa();
    }
  }

  Future<void> _loadInitialData() async {
    _loadSummary();
    _loadKategori();
    if (_selectedTabIndex == 0) {
      _loadKatalog(reset: true);
    } else if (_selectedTabIndex == 1) {
      _loadPinjamanSaya(reset: true);
    } else if (_selectedTabIndex == 2) {
      _loadRiwayatPinjaman(reset: true);
    } else if (_selectedTabIndex == 3) {
      _loadKunjungan(reset: true);
    } else if (_selectedTabIndex == 4) {
      _loadKelasAmpu();
    } else {
      _loadKatalog(reset: true);
    }
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);

    if (index == 0 && _katalogItems.isEmpty) {
      _loadKatalog(reset: true);
    } else if (index == 1 && _pinjamanSayaItems.isEmpty) {
      _loadPinjamanSaya(reset: true);
    } else if (index == 2 && _riwayatPinjamanItems.isEmpty) {
      _loadRiwayatPinjaman(reset: true);
    } else if (index == 3 && _kunjunganItems.isEmpty) {
      _loadKunjungan(reset: true);
    } else if (index == 4 && _kelasList.isEmpty) {
      _loadKelasAmpu();
    }
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoadingSummary = true);
    try {
      final summary = await _service.getSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoadingSummary = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSummary = false);
    }
  }

  Future<void> _loadKategori() async {
    try {
      final list = await _service.getKategoriList();
      if (mounted) {
        setState(() => _kategoriList = list);
      }
    } catch (_) {}
  }

  // =========================================================================
  // TAB 1: KATALOG LOGIC
  // =========================================================================
  Future<void> _loadKatalog({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoadingKatalog = true;
        _katalogError = null;
        _katalogPage = 1;
      });
    }

    try {
      final result = await _service.getKatalog(
        search: _searchController.text.trim(),
        sortBy: _selectedSortBy,
        kategoriId: _selectedKategoriId,
        page: _katalogPage,
        perPage: 15,
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _katalogItems = result.items;
          } else {
            _katalogItems.addAll(result.items);
          }
          _hasMoreKatalog = result.pagination.hasMorePages;
          _isLoadingKatalog = false;
          _isLoadingMoreKatalog = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _katalogError = e.toString().replaceAll('Exception: ', '');
          _isLoadingKatalog = false;
          _isLoadingMoreKatalog = false;
        });
      }
    }
  }

  Future<void> _loadMoreKatalog() async {
    if (_isLoadingMoreKatalog || !_hasMoreKatalog) return;

    setState(() {
      _isLoadingMoreKatalog = true;
      _katalogPage++;
    });

    await _loadKatalog(reset: false);
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _loadKatalog(reset: true);
    });
  }

  void _onSortChanged(String newSort) {
    if (_selectedSortBy == newSort) return;
    setState(() => _selectedSortBy = newSort);
    _loadKatalog(reset: true);
  }

  void _onKategoriSelected(String? kategoriId) {
    if (_selectedKategoriId == kategoriId) return;
    setState(() => _selectedKategoriId = kategoriId);
    _loadKatalog(reset: true);
  }

  // =========================================================================
  // TAB 2: PINJAMAN PRIBADI LOGIC
  // =========================================================================
  Future<void> _loadPinjamanSaya({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoadingPinjamanSaya = true;
        _pinjamanSayaError = null;
        _pinjamanSayaPage = 1;
      });
    }

    try {
      final result = await _service.getPinjamanSaya(
        page: _pinjamanSayaPage,
        perPage: 10,
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _pinjamanSayaItems = result.items;
          } else {
            _pinjamanSayaItems.addAll(result.items);
          }
          _hasMorePinjamanSaya = result.pagination.hasMorePages;
          _isLoadingPinjamanSaya = false;
          _isLoadingMorePinjamanSaya = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pinjamanSayaError = e.toString().replaceAll('Exception: ', '');
          _isLoadingPinjamanSaya = false;
          _isLoadingMorePinjamanSaya = false;
        });
      }
    }
  }

  Future<void> _loadMorePinjamanSaya() async {
    if (_isLoadingMorePinjamanSaya || !_hasMorePinjamanSaya) return;

    setState(() {
      _isLoadingMorePinjamanSaya = true;
      _pinjamanSayaPage++;
    });

    await _loadPinjamanSaya(reset: false);
  }

  // =========================================================================
  // TAB 3: RIWAYAT PINJAMAN LOGIC
  // =========================================================================
  Future<void> _loadRiwayatPinjaman({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoadingRiwayatPinjaman = true;
        _riwayatPinjamanError = null;
        _riwayatPinjamanPage = 1;
      });
    }

    try {
      final result = await _service.getRiwayatPinjaman(
        page: _riwayatPinjamanPage,
        perPage: 10,
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _riwayatPinjamanItems = result.items;
          } else {
            _riwayatPinjamanItems.addAll(result.items);
          }
          _hasMoreRiwayatPinjaman = result.pagination.hasMorePages;
          _isLoadingRiwayatPinjaman = false;
          _isLoadingMoreRiwayatPinjaman = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _riwayatPinjamanError = e.toString().replaceAll('Exception: ', '');
          _isLoadingRiwayatPinjaman = false;
          _isLoadingMoreRiwayatPinjaman = false;
        });
      }
    }
  }

  Future<void> _loadMoreRiwayatPinjaman() async {
    if (_isLoadingMoreRiwayatPinjaman || !_hasMoreRiwayatPinjaman) return;

    setState(() {
      _isLoadingMoreRiwayatPinjaman = true;
      _riwayatPinjamanPage++;
    });

    await _loadRiwayatPinjaman(reset: false);
  }

  // =========================================================================
  // TAB 4: RIWAYAT KUNJUNGAN LOGIC
  // =========================================================================
  Future<void> _loadKunjungan({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoadingKunjungan = true;
        _kunjunganError = null;
        _kunjunganPage = 1;
      });
    }

    try {
      final result = await _service.getKunjunganSaya(
        page: _kunjunganPage,
        perPage: 10,
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _kunjunganItems = result.items;
          } else {
            _kunjunganItems.addAll(result.items);
          }
          _hasMoreKunjungan = result.pagination.hasMorePages;
          _isLoadingKunjungan = false;
          _isLoadingMoreKunjungan = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _kunjunganError = e.toString().replaceAll('Exception: ', '');
          _isLoadingKunjungan = false;
          _isLoadingMoreKunjungan = false;
        });
      }
    }
  }

  Future<void> _loadMoreKunjungan() async {
    if (_isLoadingMoreKunjungan || !_hasMoreKunjungan) return;

    setState(() {
      _isLoadingMoreKunjungan = true;
      _kunjunganPage++;
    });

    await _loadKunjungan(reset: false);
  }

  // =========================================================================
  // TAB 5: PEMINJAMAN SISWA KELAS AMPU LOGIC
  // =========================================================================
  Future<void> _loadKelasAmpu() async {
    setState(() => _isLoadingKelas = true);
    try {
      final classes = await _service.getKelasAmpu();
      if (mounted) {
        setState(() {
          _kelasList = classes;
          if (_selectedKelas == null && classes.isNotEmpty) {
            _selectedKelas = classes.first;
          }
          _isLoadingKelas = false;
        });

        if (_selectedKelas != null) {
          _loadPinjamanSiswa(reset: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingKelas = false;
          _pinjamanSiswaError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _loadPinjamanSiswa({bool reset = false}) async {
    if (_selectedKelas == null) return;

    if (reset) {
      setState(() {
        _isLoadingPinjamanSiswa = true;
        _pinjamanSiswaError = null;
        _pinjamanSiswaPage = 1;
      });
    }

    try {
      final result = await _service.getPinjamanSiswa(
        classId: _selectedKelas!.id,
        search: _siswaSearchController.text.trim(),
        page: _pinjamanSiswaPage,
        perPage: 15,
      );

      if (mounted) {
        setState(() {
          if (reset) {
            _pinjamanSiswaItems = result.items;
          } else {
            _pinjamanSiswaItems.addAll(result.items);
          }
          _hasMorePinjamanSiswa = result.pagination.hasMorePages;
          _isLoadingPinjamanSiswa = false;
          _isLoadingMorePinjamanSiswa = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pinjamanSiswaError = e.toString().replaceAll('Exception: ', '');
          _isLoadingPinjamanSiswa = false;
          _isLoadingMorePinjamanSiswa = false;
        });
      }
    }
  }

  Future<void> _loadMorePinjamanSiswa() async {
    if (_isLoadingMorePinjamanSiswa || !_hasMorePinjamanSiswa) return;

    setState(() {
      _isLoadingMorePinjamanSiswa = true;
      _pinjamanSiswaPage++;
    });

    await _loadPinjamanSiswa(reset: false);
  }

  void _onSiswaSearchChanged(String query) {
    _siswaDebounceTimer?.cancel();
    _siswaDebounceTimer = Timer(const Duration(milliseconds: 350), () {
      _loadPinjamanSiswa(reset: true);
    });
  }

  void _onKelasChanged(KelasAmpuItem kelas) {
    if (_selectedKelas?.id == kelas.id) return;
    setState(() {
      _selectedKelas = kelas;
      _pinjamanSiswaItems = [];
    });
    _loadPinjamanSiswa(reset: true);
  }

  Future<void> _sendWaReminder(PinjamanSiswaItem item) async {
    final siswaName = item.siswa.name;
    final judulBuku = item.buku.judul;
    final kodeEks = item.buku.kodeEksemplar;
    final dueDate = item.tanggalJatuhTempo ?? '-';
    final statusText = item.isTerlambat
        ? 'telah terlambat ${item.hariTerlambat} hari'
        : 'akan jatuh tempo pada $dueDate';

    final text = Uri.encodeComponent(
      'Halo, kami dari Perpustakaan ${widget.schoolName}.\n\n'
      'Mengingatkan bahwa peminjaman buku perpustakaan atas nama siswa *$siswaName*:\n'
      '📖 *Judul*: $judulBuku\n'
      '🏷️ *Kode Eksemplar*: $kodeEks\n'
      '📅 *Batas Kembali*: $dueDate ($statusText)\n\n'
      'Mohon untuk segera dikembalikan ke perpustakaan sekolah. Terima kasih.',
    );

    final waUrl = Uri.parse('https://wa.me/?text=$text');
    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(waUrl);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka aplikasi WhatsApp'),
            backgroundColor: AppColors.alpa,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perpustakaan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.schoolName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
            tooltip: 'Segarkan Data',
            onPressed: () {
              _loadSummary();
              if (_selectedTabIndex == 0) {
                _loadKatalog(reset: true);
              } else if (_selectedTabIndex == 1) {
                _loadPinjamanSaya(reset: true);
              } else if (_selectedTabIndex == 2) {
                _loadRiwayatPinjaman(reset: true);
              } else if (_selectedTabIndex == 3) {
                _loadKunjungan(reset: true);
              } else if (_selectedTabIndex == 4) {
                _loadPinjamanSiswa(reset: true);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await _loadSummary();
          if (_selectedTabIndex == 0) {
            await _loadKatalog(reset: true);
          } else if (_selectedTabIndex == 1) {
            await _loadPinjamanSaya(reset: true);
          } else if (_selectedTabIndex == 2) {
            await _loadRiwayatPinjaman(reset: true);
          } else if (_selectedTabIndex == 3) {
            await _loadKunjungan(reset: true);
          } else if (_selectedTabIndex == 4) {
            await _loadPinjamanSiswa(reset: true);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Banner Gradien Modern & Quick KPI
              _buildHeaderBanner(),

              const SizedBox(height: 16),

              // 2. Tab Bar Pill Responsif (5 Tab)
              _buildTabBarPill(),

              const SizedBox(height: 16),

              // 3. Tab Body
              _buildCurrentTabContent(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 1. BANNER HEADER GRADIEN MODERN
  // =========================================================================
  Widget _buildHeaderBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Badge Portal Guru
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Portal Guru',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'T.A. Aktif',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Judul & Deskripsi
          Text(
            'Koleksi & Sirkulasi Perpustakaan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cari buku, pantau pinjaman pribadi, dan pantau riwayat pinjaman siswa di kelas yang Anda ampu.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          // Quick KPI Cards
          Row(
            children: [
              _buildKpiCard(
                label: 'Koleksi Judul',
                value: _summary.totalBukuCount.toString(),
                icon: Icons.menu_book_rounded,
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                label: 'Stok Tersedia',
                value: _summary.totalEksemplarTersedia.toString(),
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 8),
              _buildKpiCard(
                label: 'Pinjaman Anda',
                value: _summary.pinjamanAktifCount.toString(),
                icon: Icons.bookmark_added_rounded,
                isHighlight: _summary.pinjamanAktifCount > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    bool isHighlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isHighlight
              ? const Color(0xFFFEF3C7).withOpacity(0.95)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlight
                ? const Color(0xFFF59E0B)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isHighlight ? const Color(0xFFB45309) : Colors.white70,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isHighlight
                          ? const Color(0xFFB45309)
                          : Colors.white.withOpacity(0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _isLoadingSummary ? '...' : value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isHighlight ? const Color(0xFF92400E) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 2. TAB BAR PILL RESPONSIF (5 TAB)
  // =========================================================================
  Widget _buildTabBarPill() {
    final tabs = [
      {'title': 'Katalog Buku', 'icon': Icons.search_rounded},
      {'title': 'Pinjaman Pribadi', 'icon': Icons.bookmark_border_rounded},
      {'title': 'Riwayat Pribadi', 'icon': Icons.history_rounded},
      {'title': 'Riwayat Kunjungan', 'icon': Icons.badge_outlined},
      {'title': 'Peminjaman Siswa', 'icon': Icons.groups_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          final tab = tabs[index];
          final isSiswaTab = index == 4;

          Color selectedBg =
              isSiswaTab ? Colors.teal.shade600 : AppColors.primary;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onTabChanged(index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedBg : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? selectedBg : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: selectedBg.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 16,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // =========================================================================
  // 3. TAB CONTENT DISPATCHER
  // =========================================================================
  Widget _buildCurrentTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildKatalogTab();
      case 1:
        return _buildPinjamanSayaTab();
      case 2:
        return _buildRiwayatPinjamanTab();
      case 3:
        return _buildKunjunganSayaTab();
      case 4:
        return _buildPinjamanSiswaTab();
      default:
        return _buildKatalogTab();
    }
  }

  // =========================================================================
  // TAB 1: KATALOG BUKU
  // =========================================================================
  Widget _buildKatalogTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar: Search Box & Sort Button
          Row(
            children: [
              // Search Input Box
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari judul, penulis, atau ISBN...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              color: AppColors.textSecondary,
                              onPressed: () {
                                _searchController.clear();
                                _loadKatalog(reset: true);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Sort Dropdown Button
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: PopupMenuButton<String>(
                  initialValue: _selectedSortBy,
                  tooltip: 'Urutkan Katalog',
                  onSelected: _onSortChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'terbaru',
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: _selectedSortBy == 'terbaru'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Buku Terbaru',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: _selectedSortBy == 'terbaru'
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedSortBy == 'terbaru'
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'populer',
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 18,
                            color: _selectedSortBy == 'populer'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sering Dipinjam',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: _selectedSortBy == 'populer'
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedSortBy == 'populer'
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          _selectedSortBy == 'terbaru'
                              ? Icons.schedule_rounded
                              : Icons.trending_up_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedSortBy == 'terbaru' ? 'Terbaru' : 'Populer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down_rounded,
                            color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Horizontal Filter Chips Kategori
          _buildKategoriFilterChips(),

          const SizedBox(height: 16),

          // Daftar Buku
          if (_isLoadingKatalog)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_katalogError != null)
            _buildKatalogErrorState()
          else if (_katalogItems.isEmpty)
            _buildKatalogEmptyState()
          else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _katalogItems.length,
              itemBuilder: (context, index) {
                final buku = _katalogItems[index];
                return _buildBukuCard(buku);
              },
            ),

            if (_isLoadingMoreKatalog)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasMoreKatalog)
              Center(
                child: TextButton.icon(
                  onPressed: _loadMoreKatalog,
                  icon: const Icon(Icons.expand_more_rounded),
                  label: const Text('Muat Lebih Banyak Buku'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildKategoriFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Chip "Semua Kategori"
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(
                'Semua Kategori',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: _selectedKategoriId == null
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: _selectedKategoriId == null
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              selected: _selectedKategoriId == null,
              onSelected: (_) => _onKategoriSelected(null),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _selectedKategoriId == null
                      ? AppColors.primary
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),

          // Chips Kategori Dinamis
          ..._kategoriList.map((kat) {
            final isSelected = _selectedKategoriId == kat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(
                  '${kat.namaKategori} (${kat.totalBuku})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => _onKategoriSelected(kat.id),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBukuCard(BukuItem buku) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            DetailBukuBottomSheet.show(
              context: context,
              bukuId: buku.id,
              initialBuku: buku,
              service: _service,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Gambar
                Container(
                  width: 80,
                  height: 115,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: buku.sampulBukuUrl != null &&
                          buku.sampulBukuUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: buku.sampulBukuUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (_, __, ___) => _buildCoverPlaceholder(),
                        )
                      : _buildCoverPlaceholder(),
                ),

                const SizedBox(width: 14),

                // Informasi Utama Buku
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris Kategori Tag & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCardStatusBadge(buku),
                          if (buku.kategori != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                buku.kategori!.namaKategori,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Judul Buku
                      Text(
                        buku.judul,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Penulis
                      Text(
                        buku.penulis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Box Info Ketersediaan / Rak
                      _buildCardLocationOrDueDate(buku),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardStatusBadge(BukuItem buku) {
    if (buku.dipinjamOlehSaya) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFD97706),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Anda Pinjam',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB45309),
              ),
            ),
          ],
        ),
      );
    } else if (buku.eksemplarTersediaCount > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Tersedia (${buku.eksemplarTersediaCount})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF047857),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Habis',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFBE123C),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCardLocationOrDueDate(BukuItem buku) {
    if (buku.dipinjamOlehSaya) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFEF3C7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded,
                size: 13, color: Color(0xFFB45309)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                buku.earliestReturnDate != null
                    ? 'Batas kembali: ${buku.earliestReturnDate}'
                    : 'Buku sedang Anda pinjam',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB45309),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else if (buku.eksemplarTersediaCount > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDCFCE7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 13, color: Color(0xFF047857)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Rak: ${buku.lokasiRak}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF047857),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFE4E6)),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_repeat_rounded,
                size: 13, color: Color(0xFFBE123C)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                buku.earliestReturnDate != null
                    ? 'Tersedia sktr: ${buku.earliestReturnDate}'
                    : 'Sedang dipinjam pihak lain',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFBE123C),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: Colors.blue.shade50,
      child: Center(
        child: Icon(
          Icons.auto_stories_rounded,
          size: 28,
          color: Colors.blue.shade300,
        ),
      ),
    );
  }

  Widget _buildKatalogEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Buku Tidak Ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci pencarian atau bersihkan filter kategori Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedKategoriId = null);
              _loadKatalog(reset: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildKatalogErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 40, color: Colors.pink.shade400),
          const SizedBox(height: 12),
          Text(
            _katalogError ?? 'Terjadi kesalahan memuat katalog',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _loadKatalog(reset: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: PINJAMAN PRIBADI GURU
  // =========================================================================
  Widget _buildPinjamanSayaTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buku Yang Sedang Anda Pinjam',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Daftar buku perpustakaan yang saat ini masih Anda pinjam.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (_isLoadingPinjamanSaya)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_pinjamanSayaError != null)
            _buildPinjamanSayaErrorState()
          else if (_pinjamanSayaItems.isEmpty)
            _buildPinjamanSayaEmptyState()
          else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pinjamanSayaItems.length,
              itemBuilder: (context, index) {
                final item = _pinjamanSayaItems[index];
                return _buildPinjamanSayaCard(item);
              },
            ),

            if (_isLoadingMorePinjamanSaya)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasMorePinjamanSaya)
              Center(
                child: TextButton.icon(
                  onPressed: _loadMorePinjamanSaya,
                  icon: const Icon(Icons.expand_more_rounded),
                  label: const Text('Muat Lebih Banyak'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPinjamanSayaCard(PeminjamanGuruItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isTerlambat
              ? Colors.pink.shade200
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.buku != null
              ? () {
                  DetailBukuBottomSheet.show(
                    context: context,
                    bukuId: item.buku!.id,
                    service: _service,
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Gambar Buku
                    Container(
                      width: 70,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: item.buku?.sampulBukuUrl != null &&
                              item.buku!.sampulBukuUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.buku!.sampulBukuUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (_, __, ___) =>
                                  _buildCoverPlaceholder(),
                            )
                          : _buildCoverPlaceholder(),
                    ),

                    const SizedBox(width: 14),

                    // Detail Buku & Status Pinjam
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Badge & Kode Eksemplar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildPinjamanStatusBadge(item),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  item.kodeEksemplar,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Judul Buku
                          Text(
                            item.buku?.judul ?? 'Judul Buku Tidak Diketahui',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          // Penulis
                          Text(
                            item.buku?.penulis ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Info Tanggal
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                'Pinjam: ${item.tanggalPinjam ?? '-'}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: item.isTerlambat
                                    ? Colors.pink.shade600
                                    : Colors.amber.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Batas: ${item.tanggalJatuhTempo ?? '-'}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: item.isTerlambat
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: item.isTerlambat
                                      ? Colors.pink.shade700
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Box Keterlambatan / Sisa Hari
                if (item.isTerlambat)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 16, color: Color(0xFFBE123C)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Terlambat ${item.hariTerlambat} hari! Harap segera kembalikan ke perpustakaan.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFBE123C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFEF3C7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 16, color: Color(0xFFB45309)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Sisa masa pinjam: ${item.sisaHari} hari lagi.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinjamanStatusBadge(PeminjamanGuruItem item) {
    if (item.isTerlambat) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Terlambat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFBE123C),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFD97706),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Sedang Dipinjam',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB45309),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPinjamanSayaEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_remove_rounded,
              size: 40,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tidak Ada Buku Dipinjam',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anda saat ini tidak sedang meminjam buku perpustakaan. Kunjungi Katalog Buku untuk mencari buku yang menarik!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _onTabChanged(0),
            icon: const Icon(Icons.search_rounded, size: 16),
            label: const Text('Buka Katalog Buku'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinjamanSayaErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 40, color: Colors.pink.shade400),
          const SizedBox(height: 12),
          Text(
            _pinjamanSayaError ?? 'Terjadi kesalahan memuat pinjaman Anda',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _loadPinjamanSaya(reset: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 3: RIWAYAT PINJAMAN PRIBADI GURU
  // =========================================================================
  Widget _buildRiwayatPinjamanTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Peminjaman Pribadi Anda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Daftar buku yang sudah pernah Anda pinjam dan kembalikan sebelumnya.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (_isLoadingRiwayatPinjaman)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_riwayatPinjamanError != null)
            _buildRiwayatPinjamanErrorState()
          else if (_riwayatPinjamanItems.isEmpty)
            _buildRiwayatPinjamanEmptyState()
          else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _riwayatPinjamanItems.length,
              itemBuilder: (context, index) {
                final item = _riwayatPinjamanItems[index];
                return _buildRiwayatPinjamanCard(item);
              },
            ),

            if (_isLoadingMoreRiwayatPinjaman)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasMoreRiwayatPinjaman)
              Center(
                child: TextButton.icon(
                  onPressed: _loadMoreRiwayatPinjaman,
                  icon: const Icon(Icons.expand_more_rounded),
                  label: const Text('Muat Lebih Banyak Riwayat'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiwayatPinjamanCard(PeminjamanGuruItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.buku != null
              ? () {
                  DetailBukuBottomSheet.show(
                    context: context,
                    bukuId: item.buku!.id,
                    service: _service,
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Gambar Buku
                Container(
                  width: 70,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: item.buku?.sampulBukuUrl != null &&
                          item.buku!.sampulBukuUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.buku!.sampulBukuUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (_, __, ___) =>
                              _buildCoverPlaceholder(),
                        )
                      : _buildCoverPlaceholder(),
                ),

                const SizedBox(width: 14),

                // Detail Buku
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRiwayatStatusBadge(item),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              item.kodeEksemplar,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Judul Buku
                      Text(
                        item.buku?.judul ?? 'Judul Buku Tidak Diketahui',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Penulis
                      Text(
                        item.buku?.penulis ?? '-',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Info Waktu Pinjam & Kembali
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            'Dipinjam: ${item.tanggalPinjam ?? '-'}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 12, color: Colors.teal.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Kembali: ${item.tanggalKembali ?? '-'}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatStatusBadge(PeminjamanGuruItem item) {
    if (item.status.toLowerCase() == 'dikembalikan') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Dikembalikan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF047857),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          item.status.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
  }

  Widget _buildRiwayatPinjamanEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 40,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum Ada Riwayat Peminjaman',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anda belum memiliki catatan riwayat peminjaman buku perpustakaan sebelumnya.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatPinjamanErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 40, color: Colors.pink.shade400),
          const SizedBox(height: 12),
          Text(
            _riwayatPinjamanError ?? 'Terjadi kesalahan memuat riwayat Anda',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _loadRiwayatPinjaman(reset: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 4: RIWAYAT KUNJUNGAN PRIBADI GURU
  // =========================================================================
  Widget _buildKunjunganSayaTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Kunjungan Pribadi Anda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Catatan riwayat presensi kunjungan fisik Anda ke perpustakaan.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (_isLoadingKunjungan)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_kunjunganError != null)
            _buildKunjunganErrorState()
          else if (_kunjunganItems.isEmpty)
            _buildKunjunganEmptyState()
          else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _kunjunganItems.length,
              itemBuilder: (context, index) {
                final item = _kunjunganItems[index];
                return _buildKunjunganCard(item);
              },
            ),

            if (_isLoadingMoreKunjungan)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasMoreKunjungan)
              Center(
                child: TextButton.icon(
                  onPressed: _loadMoreKunjungan,
                  icon: const Icon(Icons.expand_more_rounded),
                  label: const Text('Muat Lebih Banyak Kunjungan'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildKunjunganCard(KunjunganGuruItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tanggal & Jam
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.event_available_rounded,
                        size: 18, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.tanggal,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            'Masuk: ${item.waktuMasuk} WIB',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Badge Tujuan
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  item.tujuanKunjunganLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),

          if (item.catatan != null && item.catatan!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.catatan!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKunjunganEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.meeting_room_outlined,
              size: 40,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum Ada Kunjungan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anda belum memiliki catatan kunjungan presensi di perpustakaan sekolah.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKunjunganErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 40, color: Colors.pink.shade400),
          const SizedBox(height: 12),
          Text(
            _kunjunganError ?? 'Terjadi kesalahan memuat riwayat kunjungan',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _loadKunjungan(reset: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 5: PEMINJAMAN SISWA KELAS AMPU
  // =========================================================================
  Widget _buildPinjamanSiswaTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Info Khusus Siswa Kelas Ampu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Peminjaman Siswa',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      Text(
                        'Pantau peminjaman buku oleh siswa dari kelas yang Anda ampu.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.teal.shade800.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Selector Kelas Ampu
          if (_isLoadingKelas)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_kelasList.isEmpty)
            _buildNoKelasAmpuState()
          else ...[
            _buildKelasAmpuChips(),

            const SizedBox(height: 14),

            // Search Bar Siswa / Buku
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _siswaSearchController,
                onChanged: _onSiswaSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari nama siswa, NISN, atau judul buku...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.teal.shade600,
                    size: 20,
                  ),
                  suffixIcon: _siswaSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          color: AppColors.textSecondary,
                          onPressed: () {
                            _siswaSearchController.clear();
                            _loadPinjamanSiswa(reset: true);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content List Peminjaman Siswa
            if (_isLoadingPinjamanSiswa)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_pinjamanSiswaError != null)
              _buildPinjamanSiswaErrorState()
            else if (_pinjamanSiswaItems.isEmpty)
              _buildPinjamanSiswaEmptyState()
            else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pinjamanSiswaItems.length,
                itemBuilder: (context, index) {
                  final item = _pinjamanSiswaItems[index];
                  return _buildPinjamanSiswaCard(item);
                },
              ),

              if (_isLoadingMorePinjamanSiswa)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildKelasAmpuChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _kelasList.map((kelas) {
          final isSelected = _selectedKelas?.id == kelas.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    kelas.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.teal.shade900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.25)
                          : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      kelas.role,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : Colors.teal.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => _onKelasChanged(kelas),
              selectedColor: Colors.teal.shade600,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? Colors.teal.shade600
                      : Colors.teal.shade200,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPinjamanSiswaCard(PinjamanSiswaItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isTerlambat
              ? Colors.pink.shade200
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Siswa & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Center(
                      child: Text(
                        item.siswa.name.isNotEmpty
                            ? item.siswa.name
                                .trim()
                                .split(' ')
                                .map((e) => e.isNotEmpty ? e[0] : '')
                                .take(2)
                                .join()
                                .toUpperCase()
                            : 'S',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.siswa.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (item.siswa.nisn != null &&
                          item.siswa.nisn!.isNotEmpty)
                        Text(
                          'NISN: ${item.siswa.nisn}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Status Badge
              if (item.isTerlambat)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE11D48),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Terlambat ${item.hariTerlambat} Hari',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFBE123C),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Dipinjam',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const Divider(height: 18),

          // Detail Buku Yang Dipinjam
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.buku.judul,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Penulis: ${item.buku.penulis}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Eksemplar: ${item.buku.kodeEksemplar}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Tanggal
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Pinjam: ${item.tanggalPinjam ?? '-'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Batas: ${item.tanggalJatuhTempo ?? '-'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight:
                          item.isTerlambat ? FontWeight.w700 : FontWeight.w500,
                      color: item.isTerlambat
                          ? Colors.pink.shade700
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tombol WhatsApp Pengingat Otomatis
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _sendWaReminder(item),
              icon: const Icon(Icons.chat_rounded,
                  size: 16, color: Color(0xFF25D366)),
              label: Text(
                'Kirim Pengingat WhatsApp',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF15803D),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF86EFAC)),
                backgroundColor: const Color(0xFFF0FDF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoKelasAmpuState() {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 44, color: Colors.teal.shade300),
          const SizedBox(height: 12),
          Text(
            'Tidak Ada Kelas yang Diampu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anda saat ini belum mengampu mata pelajaran atau ditugaskan sebagai wali kelas/BK pada periode aktif ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinjamanSiswaEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 40, color: Colors.teal.shade300),
          const SizedBox(height: 12),
          Text(
            'Tidak Ada Peminjaman Siswa',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tidak ada catatan peminjaman buku aktif oleh siswa untuk kelas ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinjamanSiswaErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 40, color: Colors.pink.shade400),
          const SizedBox(height: 12),
          Text(
            _pinjamanSiswaError ?? 'Gagal memuat peminjaman siswa',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _loadPinjamanSiswa(reset: true),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
