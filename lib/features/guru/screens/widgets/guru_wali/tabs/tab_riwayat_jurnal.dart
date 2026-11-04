import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/jurnal_guru_wali_model.dart';
import '../cards/jurnal_item_card.dart';

/// Tab 2 Guru Wali: Riwayat Jurnal Dampingan Siswa
class TabRiwayatJurnal extends StatelessWidget {
  final bool isLoading;
  final List<JurnalGuruWaliItem> jurnals;
  final String selectedPilarFilter;
  final ValueChanged<String> onPilarFilterChanged;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const TabRiwayatJurnal({
    super.key,
    required this.isLoading,
    required this.jurnals,
    required this.selectedPilarFilter,
    required this.onPilarFilterChanged,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Cari topik / nama siswa...',
                    hintStyle:
                        TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
        if (jurnals.isEmpty)
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
            itemCount: jurnals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return JurnalItemCard(jurnal: jurnals[index]);
            },
          ),
      ],
    );
  }

  Widget _buildPilarChip(String key, String label) {
    final isSelected = selectedPilarFilter == key;
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
          color: isSelected
              ? const Color(0xFF2563EB)
              : const Color(0xFFCBD5E1),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (val) => onPilarFilterChanged(key),
      ),
    );
  }
}

