import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bar pencarian nama/NISN siswa dan deretan chip filter horizontal
class DataSiswaSearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String selectedFilterChip;
  final ValueChanged<String> onFilterChipChanged;
  final int totalCount;
  final int berbarcodeCount;
  final int belumBarcodeCount;

  const DataSiswaSearchFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedFilterChip,
    required this.onFilterChipChanged,
    required this.totalCount,
    required this.berbarcodeCount,
    required this.belumBarcodeCount,
  });

  Widget _buildFilterChip(String key, String label) {
    final isSelected = selectedFilterChip == key;
    return InkWell(
      onTap: () => onFilterChipChanged(key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Search Box
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama, NISN, atau NIS siswa...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: Color(0xFF64748B),
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
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
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Chips Horisontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Semua ($totalCount)'),
                const SizedBox(width: 6),
                _buildFilterChip('with_barcode', 'Ada Barcode ($berbarcodeCount)'),
                const SizedBox(width: 6),
                _buildFilterChip('without_barcode', 'Belum Barcode ($belumBarcodeCount)'),
                const SizedBox(width: 6),
                _buildFilterChip('missing_nohp', 'Belum No. HP'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

