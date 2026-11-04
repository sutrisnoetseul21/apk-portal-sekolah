import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/guru_wali_dashboard_model.dart';
import '../cards/siswa_asuh_kotak_card.dart';

/// Tab 1 Guru Wali: Model Kotak-Kotak Siswa Asuh (Siswa Aktif & Arsip)
class TabSiswaAsuh extends StatelessWidget {
  final GuruWaliDashboardData data;
  final String siswaSubTab;
  final ValueChanged<String> onSubTabChanged;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final void Function(String studentId, String studentName) onBukaDetailPresensi;
  final VoidCallback onBukaCeritaTab;
  final ValueChanged<SiswaAsuhModel> onTambahJurnal;
  final ValueChanged<SiswaAsuhModel> onLihatRiwayat;

  const TabSiswaAsuh({
    super.key,
    required this.data,
    required this.siswaSubTab,
    required this.onSubTabChanged,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onBukaDetailPresensi,
    required this.onBukaCeritaTab,
    required this.onTambahJurnal,
    required this.onLihatRiwayat,
  });

  @override
  Widget build(BuildContext context) {
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
                  _buildSubTabButton(
                      'aktif', 'Aktif (${data.siswaAktif.length})'),
                  _buildSubTabButton(
                      'arsip', 'Arsip (${data.siswaArsip.length})'),
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
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari nama / NISN...',
                    hintStyle: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: Color(0xFF94A3B8)),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: onSearchCleared,
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
        if (siswaSubTab == 'aktif')
          _buildGridSiswaAktif(data.siswaAktif)
        else
          _buildListSiswaArsip(data.siswaArsip),
      ],
    );
  }

  Widget _buildSubTabButton(String key, String label) {
    final isSelected = siswaSubTab == key;
    return InkWell(
      onTap: () => onSubTabChanged(key),
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
              searchQuery.isNotEmpty
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
            return SiswaAsuhKotakCard(
              siswa: siswa,
              onBukaDetailPresensi: onBukaDetailPresensi,
              onBukaCeritaTab: onBukaCeritaTab,
              onTambahJurnal: onTambahJurnal,
              onLihatRiwayat: onLihatRiwayat,
            );
          },
        );
      },
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
        return InkWell(
          onTap: () => onBukaDetailPresensi(item.studentId, item.name),
          borderRadius: BorderRadius.circular(14),
          child: Container(
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
                    color: const Color(0xFF64748B).withValues(alpha: 0.1),
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
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

