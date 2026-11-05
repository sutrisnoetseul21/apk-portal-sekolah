import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/perpustakaan_models.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/services/perpustakaan_service.dart';
import 'perpustakaan/detail_buku/buku_cover_metadata_header.dart';
import 'perpustakaan/detail_buku/buku_loan_status_banner.dart';
import 'perpustakaan/detail_buku/buku_bibliografi_card.dart';
import 'perpustakaan/detail_buku/buku_eksemplar_list_section.dart';

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
        BukuCoverMetadataHeader(buku: buku),
        const SizedBox(height: 20),
        BukuLoanStatusBanner(
          buku: buku,
          onOpenPdf: _openPdf,
        ),
        BukuBibliografiCard(buku: buku),
        const SizedBox(height: 24),
        BukuEksemplarListSection(buku: buku),
        const SizedBox(height: 30),
      ],
    );
  }
}
