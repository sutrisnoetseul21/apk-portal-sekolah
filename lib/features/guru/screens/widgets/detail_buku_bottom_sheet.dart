import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/perpustakaan_models.dart';
import '../../services/perpustakaan_service.dart';

/// Modal Bottom Sheet untuk menampilkan detail lengkap buku perpustakaan
class DetailBukuBottomSheet extends StatefulWidget {
  final String bukuId;
  final BukuItem? initialBuku;
  final PerpustakaanService service;

  const DetailBukuBottomSheet({
    super.key,
    required this.bukuId,
    this.initialBuku,
    required this.service,
  });

  static Future<void> show({
    required BuildContext context,
    required String bukuId,
    BukuItem? initialBuku,
    required PerpustakaanService service,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetailBukuBottomSheet(
        bukuId: bukuId,
        initialBuku: initialBuku,
        service: service,
      ),
    );
  }

  @override
  State<DetailBukuBottomSheet> createState() => _DetailBukuBottomSheetState();
}

class _DetailBukuBottomSheetState extends State<DetailBukuBottomSheet> {
  BukuItem? _buku;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _buku = widget.initialBuku;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await widget.service.getBukuDetail(widget.bukuId);
      if (mounted) {
        setState(() {
          _buku = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka file PDF'),
            backgroundColor: AppColors.alpa,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Detail Buku',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content Body
              Expanded(
                child: _isLoading && _buku == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _errorMessage != null && _buku == null
                        ? _buildErrorState()
                        : _buildDetailContent(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.pink.shade400),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Terjadi kesalahan memuat detail buku',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDetail,
              icon: const Icon(Icons.refresh_rounded, size: 18),
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
      ),
    );
  }

  Widget _buildDetailContent(ScrollController scrollController) {
    final buku = _buku!;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Bagian Atas: Cover dan Ringkasan Info
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Buku
            Container(
              width: 105,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
            const SizedBox(width: 16),

            // Metadata Utama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Ketersediaan Badge
                  _buildStatusBadge(buku),
                  const SizedBox(height: 8),

                  // Judul Buku
                  Text(
                    buku.judul,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Penulis
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          buku.penulis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Kategori & Lokasi Rak Tag
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (buku.kategori != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            buku.kategori!.namaKategori,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 12, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Rak: ${buku.lokasiRak}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Banner Status Pinjaman Khusus Guru
        if (buku.dipinjamOlehSaya)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFFB45309), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sedang Anda Pinjam',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                      if (buku.earliestReturnDate != null)
                        Text(
                          'Batas pengembalian: ${buku.earliestReturnDate}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else if (buku.eksemplarTersediaCount == 0 &&
            buku.earliestReturnDate != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    color: Color(0xFFBE123C), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semua Eksemplar Sedang Dipinjam',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color(0xFFBE123C),
                        ),
                      ),
                      Text(
                        'Estimasi tersedia kembali sekitar: ${buku.earliestReturnDate}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF9F1239),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Action: Tombol Baca PDF jika tersedia
        if (buku.hasPdf &&
            buku.filePdfUrl != null &&
            buku.filePdfUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              onPressed: () => _openPdf(buku.filePdfUrl!),
              icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
              label: Text(
                'Baca E-Book Digital (PDF)',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),

        // Tabel Informasi Spesifikasi Buku
        Text(
          'Informasi Bibliografi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInfoRow('Penerbit', buku.penerbit),
              _buildDivider(),
              _buildInfoRow(
                  'Tahun Terbit', buku.tahunTerbit?.toString() ?? '-'),
              _buildDivider(),
              _buildInfoRow('ISBN', buku.isbn ?? '-'),
              _buildDivider(),
              _buildInfoRow('Lokasi Rak', buku.lokasiRak),
              _buildDivider(),
              _buildInfoRow('Nomor Panggil',
                  buku.callNumber?.replaceAll('\n', ' ') ?? '-'),
              if (buku.klasifikasiDdc != null) ...[
                _buildDivider(),
                _buildInfoRow('Klasifikasi DDC',
                    '${buku.klasifikasiDdc!.kodeDdc ?? ''} - ${buku.klasifikasiDdc!.namaKlasifikasi ?? ''}'),
              ],
              if (buku.mataPelajaran != null) ...[
                _buildDivider(),
                _buildInfoRow(
                    'Mata Pelajaran', buku.mataPelajaran!.namaMapel ?? '-'),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Daftar Eksemplar Fisik
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Eksemplar Fisik',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${buku.eksemplarTersediaCount} dari ${buku.totalEksemplar} Tersedia',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (buku.eksemplar.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                'Belum ada data eksemplar terdaftar untuk buku ini.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...buku.eksemplar.map((eks) => _buildEksemplarCard(eks)),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStatusBadge(BukuItem buku) {
    if (buku.dipinjamOlehSaya) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFD97706),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Sedang Dipinjam',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB45309),
              ),
            ),
          ],
        ),
      );
    } else if (buku.eksemplarTersediaCount > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Tersedia (${buku.eksemplarTersediaCount})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF047857),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Habis Dipinjam',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFBE123C),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildEksemplarCard(EksemplarBukuItem eks) {
    final bool isTersedia = eks.status.toLowerCase() == 'tersedia';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTersedia ? Colors.grey.shade200 : Colors.pink.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTersedia
                  ? Colors.teal.shade50
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 20,
              color: isTersedia
                  ? Colors.teal.shade700
                  : Colors.amber.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eks.kodeEksemplar,
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Kondisi: ${eks.kondisiFisik.toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isTersedia
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isTersedia ? 'Tersedia' : eks.status.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isTersedia
                    ? const Color(0xFF047857)
                    : const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 12, color: Colors.grey.shade200);
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: Colors.blue.shade50,
      child: Center(
        child: Icon(
          Icons.auto_stories_rounded,
          size: 38,
          color: Colors.blue.shade300,
        ),
      ),
    );
  }
}

