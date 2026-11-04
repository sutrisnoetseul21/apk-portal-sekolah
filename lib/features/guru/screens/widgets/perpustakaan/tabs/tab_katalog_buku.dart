import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../models/perpustakaan_models.dart';
import '../cards/perpustakaan_buku_card.dart';

/// Tab 1: Katalog Buku Perpustakaan (Pencarian, Filter Kategori, Grid/List Buku)
class TabKatalogBuku extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String selectedSortBy;
  final ValueChanged<String> onSortChanged;
  final List<KategoriBuku> kategoriList;
  final String? selectedKategoriId;
  final ValueChanged<String?> onKategoriSelected;
  final List<BukuItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final ValueChanged<BukuItem> onDetailTap;
  final VoidCallback onResetFilter;

  const TabKatalogBuku({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedSortBy,
    required this.onSortChanged,
    required this.kategoriList,
    required this.selectedKategoriId,
    required this.onKategoriSelected,
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.error,
    required this.onRetry,
    required this.onLoadMore,
    required this.onDetailTap,
    required this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
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
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari judul, penulis, atau ISBN...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              color: AppColors.textSecondary,
                              onPressed: onClearSearch,
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
                  initialValue: selectedSortBy,
                  tooltip: 'Urutkan Katalog',
                  onSelected: onSortChanged,
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
                            color: selectedSortBy == 'terbaru'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Buku Terbaru',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: selectedSortBy == 'terbaru'
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selectedSortBy == 'terbaru'
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
                            color: selectedSortBy == 'populer'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sering Dipinjam',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: selectedSortBy == 'populer'
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selectedSortBy == 'populer'
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
                          selectedSortBy == 'terbaru'
                              ? Icons.schedule_rounded
                              : Icons.trending_up_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          selectedSortBy == 'terbaru' ? 'Terbaru' : 'Populer',
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
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            _buildKatalogErrorState()
          else if (items.isEmpty)
            _buildKatalogEmptyState()
          else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final buku = items[index];
                return PerpustakaanBukuCard(
                  buku: buku,
                  onTap: () => onDetailTap(buku),
                );
              },
            ),

            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (hasMore)
              Center(
                child: TextButton.icon(
                  onPressed: onLoadMore,
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
                  fontWeight: selectedKategoriId == null
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selectedKategoriId == null
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              selected: selectedKategoriId == null,
              onSelected: (_) => onKategoriSelected(null),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: selectedKategoriId == null
                      ? AppColors.primary
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),

          // Chips Kategori Dinamis
          ...kategoriList.map((kat) {
            final isSelected = selectedKategoriId == kat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(
                  '${kat.namaKategori} (${kat.totalBuku})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onKategoriSelected(kat.id),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }),
        ],
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
            onPressed: onResetFilter,
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
            error ?? 'Terjadi kesalahan memuat katalog',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
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
}

