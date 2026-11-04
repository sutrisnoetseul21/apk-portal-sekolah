import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/siswa_perpustakaan_model.dart';

/// Tab 0: Daftar buku yang sedang dipinjam siswa
class TabPinjamanAktifSiswa extends StatelessWidget {
  final bool isLoading;
  final List<SiswaPinjamanItem> items;

  const TabPinjamanAktifSiswa({
    super.key,
    required this.isLoading,
    required this.items,
  });

  Widget _buildCoverFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.book_rounded, size: 28, color: Color(0xFF94A3B8)),
        SizedBox(height: 2),
        Text(
          'Buku',
          style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPinjamanCard(SiswaPinjamanItem item) {
    final isTerlambat = item.isTerlambat;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTerlambat ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
          width: isTerlambat ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTerlambat)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Buku
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 68,
                    height: 94,
                    color: const Color(0xFFF1F5F9),
                    child: item.buku.sampulUrl != null && item.buku.sampulUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.buku.sampulUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => _buildCoverFallback(),
                          )
                        : _buildCoverFallback(),
                  ),
                ),
                const SizedBox(width: 14),

                // Info Buku
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori & No. Eksemplar
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.buku.kategori,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.kodeEksemplar,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Judul Buku
                      Text(
                        item.buku.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Penulis
                      Text(
                        item.buku.penulis,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),

                      // Tanggal Pinjam & Batas Kembali
                      Row(
                        children: [
                          const Icon(Icons.event_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Pinjam: ${item.tanggalPinjamFormatted}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: isTerlambat ? const Color(0xFFE11D48) : const Color(0xFF059669),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Batas: ${item.tanggalJatuhTempoFormatted}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isTerlambat ? const Color(0xFFE11D48) : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Countdown Sisa Hari / Badge Status
                      if (isTerlambat)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFE11D48)),
                              const SizedBox(width: 4),
                              Text(
                                'Terlambat ${item.terlambatHari} Hari! Segera kembalikan',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFBE123C),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (item.sisaHari != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.sisaHari! <= 2 ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.sisaHari == 0
                                ? 'Jatuh tempo hari ini!'
                                : 'Sisa ${item.sisaHari} hari lagi',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item.sisaHari! <= 2 ? const Color(0xFF92400E) : const Color(0xFF065F46),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bookmark_added_rounded, color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Buku Yang Sedang Anda Pinjam',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Daftar buku perpustakaan yang saat ini masih Anda pinjam.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book_outlined, size: 40, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Anda saat ini tidak sedang meminjam buku perpustakaan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildPinjamanCard(items[index]),
          ),
      ],
    );
  }
}

