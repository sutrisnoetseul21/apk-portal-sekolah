import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../models/perpustakaan_models.dart';
import '../cards/pinjaman_siswa_card.dart';

/// Tab 5: Riwayat Peminjaman Buku Siswa di Kelas yang Diampu Guru
class TabPinjamanSiswaBinaan extends StatelessWidget {
  final List<KelasAmpuItem> kelasList;
  final KelasAmpuItem? selectedKelas;
  final ValueChanged<KelasAmpuItem> onKelasChanged;
  final bool isLoadingKelas;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final List<PinjamanSiswaItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<PinjamanSiswaItem> onSendWa;

  const TabPinjamanSiswaBinaan({
    super.key,
    required this.kelasList,
    required this.selectedKelas,
    required this.onKelasChanged,
    required this.isLoadingKelas,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.onRetry,
    required this.onSendWa,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card Info Khusus Siswa Kelas Ampu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50.withValues(alpha: 0.5),
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
                          color: Colors.teal.shade800.withValues(alpha: 0.8),
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
          if (isLoadingKelas)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (kelasList.isEmpty)
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
                  hintText: 'Cari nama siswa, NISN, atau judul buku...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.teal.shade600,
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

            const SizedBox(height: 16),

            // Content List Peminjaman Siswa
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              _buildPinjamanSiswaErrorState()
            else if (items.isEmpty)
              _buildPinjamanSiswaEmptyState()
            else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return PinjamanSiswaCard(
                    item: item,
                    onSendWa: onSendWa,
                  );
                },
              ),

              if (isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
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
        children: kelasList.map((kelas) {
          final isSelected = selectedKelas?.id == kelas.id;
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
                          ? Colors.white.withValues(alpha: 0.25)
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
              onSelected: (_) => onKelasChanged(kelas),
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
      padding: const EdgeInsets.all(32),
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
            error ?? 'Gagal memuat peminjaman siswa',
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

