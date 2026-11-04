import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_guru_wali_model.dart';
import '../cards/siwali_klasikal_card.dart';

/// Tab Konten 2: Pendampingan Klasikal & Kelompok Siswa
class TabBimbinganKlasikal extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchSubmitted;
  final VoidCallback onSearchCleared;
  final bool isLoading;
  final List<SiswaBimbinganKlasikalItem>? items;

  const TabBimbinganKlasikal({
    super.key,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.onSearchCleared,
    required this.isLoading,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Menu Pencarian
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearchSubmitted(),
            decoration: InputDecoration(
              hintText: 'Cari materi klasikal atau arahan motivasi...',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 20, color: Colors.grey),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      tooltip: 'Hapus pencarian',
                      onPressed: onSearchCleared,
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                borderSide:
                    const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
        ),

        // List Klasikal
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : (items == null || items!.isEmpty)
                  ? _buildEmptyState(
                      icon: Icons.menu_book_rounded,
                      title: 'Belum Ada Sesi Bimbingan Klasikal',
                      desc:
                          'Guru Wali belum mencatat sesi bimbingan klasikal bersama kelas atau kelompok asuh Anda.',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth >= 600;

                        if (isTablet) {
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.95,
                            ),
                            itemCount: items!.length,
                            itemBuilder: (context, index) {
                              return SiwaliKlasikalCard(item: items![index]);
                            },
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: items!.length,
                          separatorBuilder: (_, i) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return SiwaliKlasikalCard(item: items![index]);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

