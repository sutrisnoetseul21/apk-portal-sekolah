import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab;
    _service = PerpustakaanService.create(
      token: widget.token,
      identifier: widget.identifier,
    );

    _katalogScrollController.addListener(_onKatalogScroll);

    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _katalogScrollController.dispose();
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

  Future<void> _loadInitialData() async {
    _loadSummary();
    _loadKategori();
    _loadKatalog(reset: true);
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
              _loadKatalog(reset: true);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await _loadInitialData();
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

          Color selectedBg = isSiswaTab ? Colors.teal.shade600 : AppColors.primary;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedTabIndex = index);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedBg : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? selectedBg
                          : Colors.grey.shade300,
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
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color:
                              isSelected ? Colors.white : AppColors.textSecondary,
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
        return _buildPlaceholderTab(
          title: 'Pinjaman Pribadi',
          description:
              'Daftar buku perpustakaan yang sedang Anda pinjam saat ini.',
          icon: Icons.bookmark_added_rounded,
          badgeText: 'Tahap 4',
        );
      case 2:
        return _buildPlaceholderTab(
          title: 'Riwayat Peminjaman Pribadi',
          description:
              'Daftar riwayat buku yang telah selesai Anda pinjam dan kembalikan.',
          icon: Icons.history_edu_rounded,
          badgeText: 'Tahap 4',
        );
      case 3:
        return _buildPlaceholderTab(
          title: 'Riwayat Kunjungan Pribadi',
          description:
              'Catatan presensi kehadiran fisik Anda di perpustakaan sekolah.',
          icon: Icons.badge_outlined,
          badgeText: 'Tahap 5',
        );
      case 4:
        return _buildPlaceholderTab(
          title: 'Peminjaman Siswa Kelas Ampu',
          description:
              'Pantau keterlambatan dan peminjaman buku oleh siswa pada kelas yang Anda ampu.',
          icon: Icons.groups_rounded,
          badgeText: 'Tahap 5',
        );
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
              size: 40, color: Colors.rose.shade400),
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
  // PLACEHOLDER TAB (UNTUK TAHAP 4 & TAHAP 5)
  // =========================================================================
  Widget _buildPlaceholderTab({
    required String title,
    required String description,
    required IconData icon,
    required String badgeText,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Akan Dibangun pada $badgeText',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB45309),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
