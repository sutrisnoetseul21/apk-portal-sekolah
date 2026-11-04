import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_guru_wali_model.dart';
import '../cards/siwali_konsultasi_card.dart';

/// Tab Konten 1: Konsultasi Mandiri Siswa (Daftar sesi curhat, search bar, status & grid)
class TabKonsultasiMandiri extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchSubmitted;
  final VoidCallback onSearchCleared;
  final bool isLoading;
  final List<SiswaKonsultasiItem>? items;
  final ValueChanged<SiswaKonsultasiItem> onKonsultasiTap;
  final VoidCallback onMulaiBercerita;

  const TabKonsultasiMandiri({
    super.key,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.onSearchCleared,
    required this.isLoading,
    required this.items,
    required this.onKonsultasiTap,
    required this.onMulaiBercerita,
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
              hintText: 'Cari topik curhat atau kata kunci...',
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

        // List Konsultasi
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : (items == null || items!.isEmpty)
                  ? _buildEmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Belum Ada Sesi Konsultasi',
                      desc:
                          'Anda belum memiliki riwayat bimbingan atau curhat dengan Guru Wali pada filter ini.',
                      buttonText: 'Mulai Bercerita Sekarang',
                      onAction: onMulaiBercerita,
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth >= 600;

                        if (isTablet) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.45,
                            ),
                            itemCount: items!.length,
                            itemBuilder: (context, index) {
                              return SiwaliKonsultasiCard(
                                item: items![index],
                                onTap: () => onKonsultasiTap(items![index]),
                              );
                            },
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: items!.length,
                          separatorBuilder: (_, i) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return SiwaliKonsultasiCard(
                              item: items![index],
                              onTap: () => onKonsultasiTap(items![index]),
                            );
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
    String? buttonText,
    VoidCallback? onAction,
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
            if (buttonText != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(buttonText,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

