import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../models/perpustakaan_models.dart';
import '../services/perpustakaan_service.dart';
import 'widgets/detail_buku_bottom_sheet.dart';
import 'widgets/perpustakaan/sections/perpustakaan_header_banner.dart';
import 'widgets/perpustakaan/sections/perpustakaan_tab_selector.dart';
import 'widgets/perpustakaan/tabs/tab_katalog_buku.dart';
import 'widgets/perpustakaan/tabs/tab_kunjungan_fisik.dart';
import 'widgets/perpustakaan/tabs/tab_pinjaman_saya.dart';
import 'widgets/perpustakaan/tabs/tab_pinjaman_siswa_binaan.dart';
import 'widgets/perpustakaan/tabs/tab_riwayat_pinjaman.dart';

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

    if (_selectedTabIndex == 1) {
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
              PerpustakaanHeaderBanner(
                summary: _summary,
                isLoadingSummary: _isLoadingSummary,
              ),

              const SizedBox(height: 16),

              // 2. Tab Bar Pill Responsif (5 Tab)
              PerpustakaanTabSelector(
                selectedTabIndex: _selectedTabIndex,
                onTabChanged: _onTabChanged,
              ),

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

  Widget _buildCurrentTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return TabKatalogBuku(
          searchController: _searchController,
          onSearchChanged: _onSearchChanged,
          onClearSearch: () {
            _searchController.clear();
            _loadKatalog(reset: true);
          },
          selectedSortBy: _selectedSortBy,
          onSortChanged: _onSortChanged,
          kategoriList: _kategoriList,
          selectedKategoriId: _selectedKategoriId,
          onKategoriSelected: _onKategoriSelected,
          items: _katalogItems,
          isLoading: _isLoadingKatalog,
          isLoadingMore: _isLoadingMoreKatalog,
          hasMore: _hasMoreKatalog,
          error: _katalogError,
          onRetry: () => _loadKatalog(reset: true),
          onLoadMore: _loadMoreKatalog,
          onDetailTap: (buku) {
            DetailBukuBottomSheet.show(
              context: context,
              bukuId: buku.id,
              initialBuku: buku,
              service: _service,
            );
          },
          onResetFilter: () {
            _searchController.clear();
            setState(() => _selectedKategoriId = null);
            _loadKatalog(reset: true);
          },
        );
      case 1:
        return TabPinjamanSaya(
          items: _pinjamanSayaItems,
          isLoading: _isLoadingPinjamanSaya,
          isLoadingMore: _isLoadingMorePinjamanSaya,
          hasMore: _hasMorePinjamanSaya,
          error: _pinjamanSayaError,
          onRetry: () => _loadPinjamanSaya(reset: true),
          onLoadMore: _loadMorePinjamanSaya,
          onDetailTap: (item) {
            if (item.buku != null) {
              DetailBukuBottomSheet.show(
                context: context,
                bukuId: item.buku!.id,
                service: _service,
              );
            }
          },
          onOpenKatalog: () => _onTabChanged(0),
        );
      case 2:
        return TabRiwayatPinjaman(
          items: _riwayatPinjamanItems,
          isLoading: _isLoadingRiwayatPinjaman,
          isLoadingMore: _isLoadingMoreRiwayatPinjaman,
          hasMore: _hasMoreRiwayatPinjaman,
          error: _riwayatPinjamanError,
          onRetry: () => _loadRiwayatPinjaman(reset: true),
          onLoadMore: _loadMoreRiwayatPinjaman,
          onDetailTap: (item) {
            if (item.buku != null) {
              DetailBukuBottomSheet.show(
                context: context,
                bukuId: item.buku!.id,
                service: _service,
              );
            }
          },
        );
      case 3:
        return TabKunjunganFisik(
          items: _kunjunganItems,
          isLoading: _isLoadingKunjungan,
          isLoadingMore: _isLoadingMoreKunjungan,
          hasMore: _hasMoreKunjungan,
          error: _kunjunganError,
          onRetry: () => _loadKunjungan(reset: true),
          onLoadMore: _loadMoreKunjungan,
        );
      case 4:
        return TabPinjamanSiswaBinaan(
          kelasList: _kelasList,
          selectedKelas: _selectedKelas,
          onKelasChanged: _onKelasChanged,
          isLoadingKelas: _isLoadingKelas,
          searchController: _siswaSearchController,
          onSearchChanged: _onSiswaSearchChanged,
          onClearSearch: () {
            _siswaSearchController.clear();
            _loadPinjamanSiswa(reset: true);
          },
          items: _pinjamanSiswaItems,
          isLoading: _isLoadingPinjamanSiswa,
          isLoadingMore: _isLoadingMorePinjamanSiswa,
          error: _pinjamanSiswaError,
          onRetry: () => _loadPinjamanSiswa(reset: true),
          onSendWa: _sendWaReminder,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
