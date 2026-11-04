import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/spikap_models.dart';

/// Toolbar pencarian dan chip filter kategori & status SPIKAP Guru
class SpikapFilterToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final SpikapKpiStats stats;
  final String selectedStatus;
  final String selectedSifat;
  final String selectedJenis;
  final ValueChanged<String> onStatusSelected;
  final ValueChanged<String> onSifatSelected;
  final ValueChanged<String> onJenisSelected;

  const SpikapFilterToolbar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.stats,
    required this.selectedStatus,
    required this.selectedSifat,
    required this.selectedJenis,
    required this.onStatusSelected,
    required this.onSifatSelected,
    required this.onJenisSelected,
  });

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color activeColor = AppColors.primary,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : const Color(0xFF475569),
      ),
      selectedColor: activeColor,
      backgroundColor: const Color(0xFFF1F5F9),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      onSelected: (_) => onSelected(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari siswa, NISN, lokasi, kejadian...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16),
                      onPressed: onClearSearch,
                    )
                  : null,
              fillColor: const Color(0xFFF8FAFC),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 1. Status & Urgensi Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua (${stats.total})',
                  isSelected: selectedStatus.isEmpty && selectedSifat.isEmpty,
                  onSelected: () {
                    onStatusSelected('');
                    onSifatSelected('');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: '🚨 Darurat (${stats.darurat})',
                  isSelected: selectedSifat == 'darurat',
                  activeColor: const Color(0xFFDC2626),
                  onSelected: () {
                    onSifatSelected(selectedSifat == 'darurat' ? '' : 'darurat');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Diterima',
                  isSelected: selectedStatus == 'diterima',
                  onSelected: () {
                    onStatusSelected(selectedStatus == 'diterima' ? '' : 'diterima');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Investigasi (${stats.aktif})',
                  isSelected: selectedStatus == 'dalam_investigasi',
                  onSelected: () {
                    onStatusSelected(selectedStatus == 'dalam_investigasi' ? '' : 'dalam_investigasi');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Selesai (${stats.selesai})',
                  isSelected: selectedStatus == 'selesai',
                  activeColor: const Color(0xFF059669),
                  onSelected: () {
                    onStatusSelected(selectedStatus == 'selesai' ? '' : 'selesai');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 2. Kategori Jenis Perundungan Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua Kategori',
                  isSelected: selectedJenis.isEmpty,
                  onSelected: () => onJenisSelected(''),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Kekerasan Fisik',
                  isSelected: selectedJenis == 'fisik',
                  activeColor: const Color(0xFFDC2626),
                  onSelected: () {
                    onJenisSelected(selectedJenis == 'fisik' ? '' : 'fisik');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Verbal',
                  isSelected: selectedJenis == 'verbal',
                  activeColor: const Color(0xFFD97706),
                  onSelected: () {
                    onJenisSelected(selectedJenis == 'verbal' ? '' : 'verbal');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Sosial / Relasional',
                  isSelected: selectedJenis == 'sosial',
                  activeColor: const Color(0xFF2563EB),
                  onSelected: () {
                    onJenisSelected(selectedJenis == 'sosial' ? '' : 'sosial');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Siber / Digital',
                  isSelected: selectedJenis == 'digital',
                  activeColor: const Color(0xFF7C3AED),
                  onSelected: () {
                    onJenisSelected(selectedJenis == 'digital' ? '' : 'digital');
                  },
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Lainnya',
                  isSelected: selectedJenis == 'lainnya',
                  activeColor: const Color(0xFF64748B),
                  onSelected: () {
                    onJenisSelected(selectedJenis == 'lainnya' ? '' : 'lainnya');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

