import 'package:barcode_widget/barcode_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/pdf_print_util.dart';
import '../models/siswa_kartu_model.dart';
import '../services/siswa_kartu_service.dart';

/// Layar Menu 6: Kartu Pelajar Digital & Unduh PDF
class KartuSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;
  final SiswaKartuService? service;

  const KartuSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = 'SMP Negeri 3 Kedungreja',
    this.token,
    this.service,
  });

  @override
  State<KartuSiswaScreen> createState() => _KartuSiswaScreenState();
}

class _KartuSiswaScreenState extends State<KartuSiswaScreen> {
  late SiswaKartuService _service;

  bool _isLoading = true;
  String? _errorMessage;
  SiswaKartuDigitalInfo? _kartuInfo;
  bool _isBackSide = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ??
        SiswaKartuService.create(
          token: widget.token,
          identifier: widget.identifier,
        );
    _loadDigitalInfo();
  }

  Future<void> _loadDigitalInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _service.getDigitalInfo(identifier: widget.identifier);
      if (mounted) {
        setState(() {
          _kartuInfo = res.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openPdf(String urlString, String title) async {
    await PdfPrintUtil.printOrSavePdf(
      context: context,
      url: urlString,
      title: title,
      token: widget.token,
      identifier: widget.identifier,
    );
  }

  Future<void> _copyBarcode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kode barcode ($code) berhasil disalin ke papan klip!',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showFullscreenBarcode(SiswaKartuDigitalInfo info) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFF4F46E5),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mode Scan Barcode',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    tooltip: 'Tutup layar scan',
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Petunjuk
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Dekatkan layar ini ke sinar laser atau kamera scanner gerbang / perpustakaan sekolah.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Barcode Kontras Tinggi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: Column(
                  children: [
                    Semantics(
                      label: 'Barcode Code 128 dengan nilai ${info.barcodeCode}',
                      child: BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: info.barcodeCode,
                        height: 90,
                        width: double.infinity,
                        drawText: false,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      info.barcodeCode,
                      style: GoogleFonts.robotoMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Identitas Singkat Siswa
              Text(
                info.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                info.nis != '-' && info.nis.isNotEmpty
                    ? 'NISN: ${info.nisn} • NIS: ${info.nis}'
                    : 'NISN: ${info.nisn}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Salin & Tutup
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyBarcode(info.barcodeCode),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text(
                        'Salin Kode',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        foregroundColor: const Color(0xFF334155),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(
                        'Selesai',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Kartu Pelajar & Cetak PDF',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF4338CA), // Indigo primary
        leading: IconButton(
          tooltip: 'Kembali ke Dashboard',
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang Kartu',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadDigitalInfo,
          ),
        ],
      ),
      body: _buildBody(isTablet),
    );
  }

  Widget _buildBody(bool isTablet) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 16),
            Text(
              'Menyiapkan Kartu Pelajar Digital...',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Kartu Pelajar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadDigitalInfo,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final info = _kartuInfo;
    if (info == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 16,
        vertical: 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: isTablet ? _buildTabletLayout(info) : _buildMobileLayout(info),
        ),
      ),
    );
  }

  /// Tampilan untuk Smartphone (1 Kolom Vertikal)
  Widget _buildMobileLayout(SiswaKartuDigitalInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroBanner(),
        const SizedBox(height: 20),

        // Kartu Pelajar Interaktif
        _buildCardContainer(info),
        const SizedBox(height: 14),

        // Toggle Flip Depan / Belakang
        _buildFlipToggle(),
        const SizedBox(height: 24),

        // Tombol Aksi Utama (Scan Fullscreen, Download PDF, Biodata)
        _buildActionPanel(info),
        const SizedBox(height: 24),

        // Informasi Ketentuan & Panduan
        _buildPanduanCard(info),
      ],
    );
  }

  /// Tampilan untuk Tablet (Grid / 2 Kolom Side-by-Side)
  Widget _buildTabletLayout(SiswaKartuDigitalInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroBanner(),
        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom Kiri: Kartu Pelajar Interaktif + Flip Toggle
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildCardContainer(info),
                  const SizedBox(height: 14),
                  _buildFlipToggle(),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Kolom Kanan: Panel Aksi + Panduan
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildActionPanel(info),
                  const SizedBox(height: 20),
                  _buildPanduanCard(info),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Hero Banner Atas Bernuansa Indigo-Violet
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4338CA), // Deep Indigo
            Color(0xFF6D28D9), // Royal Violet
            Color(0xFF7C3AED), // Vibrant Purple
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.badge_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kartu Pelajar & Presensi Digital',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Identitas resmi terverifikasi dengan barcode Code-128 untuk presensi gerbang & perpustakaan sekolah.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle Button untuk Flip Sisi Depan vs Sisi Belakang
  Widget _buildFlipToggle() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: 'Tampilkan sisi depan kartu pelajar',
                selected: !_isBackSide,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_isBackSide) {
                      setState(() => _isBackSide = false);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !_isBackSide ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: !_isBackSide
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.credit_card_rounded,
                          size: 18,
                          color: !_isBackSide ? const Color(0xFF4338CA) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Sisi Depan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: !_isBackSide ? FontWeight.w800 : FontWeight.w600,
                              color: !_isBackSide ? const Color(0xFF4338CA) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Tampilkan sisi belakang ketentuan kartu pelajar',
                selected: _isBackSide,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!_isBackSide) {
                      setState(() => _isBackSide = true);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isBackSide ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _isBackSide
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flip_to_back_rounded,
                          size: 18,
                          color: _isBackSide ? const Color(0xFF4338CA) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Sisi Belakang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: _isBackSide ? FontWeight.w800 : FontWeight.w600,
                              color: _isBackSide ? const Color(0xFF4338CA) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kontainer Kartu Pelajar dengan Animasi Transisi
  Widget _buildCardContainer(SiswaKartuDigitalInfo info) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _isBackSide
          ? _buildCardBack(info, key: const ValueKey('card_back'))
          : _buildCardFront(info, key: const ValueKey('card_front')),
    );
  }

  /// Sisi Depan Kartu Pelajar (Identitas Terpusat, Foto, & Barcode Code-128 Selaras Web Blade)
  Widget _buildCardFront(SiswaKartuDigitalInfo info, {Key? key}) {
    final identifierLabel = info.scanMode == 'nis' ? 'NIS' : 'NISN';
    final identifierValue = info.scanMode == 'nis' ? info.nis : info.nisn;

    return Center(
      child: Container(
        key: key,
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Dekorasi Background Arc (Kanan Atas & Kiri Bawah)
            Positioned(
              right: -25,
              top: -25,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8F2FF),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF4E0),
                ),
              ),
            ),

            // Konten Utama
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Strip Atas (Dual Color: Biru Tua 2/3 + Amber 1/3)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(height: 4, color: const Color(0xFF1E3A8A)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(height: 4, color: const Color(0xFFF59E0B)),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 2. Kop Logo & Nama Sekolah
                      if (info.schoolLogoUrl != null && info.schoolLogoUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: CachedNetworkImage(
                            imageUrl: info.schoolLogoUrl!,
                            height: 34,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Icon(
                              Icons.school_rounded,
                              color: Color(0xFF1E3A8A),
                              size: 28,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.school_rounded,
                              color: Color(0xFF1E3A8A),
                              size: 28,
                            ),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Icon(
                            Icons.school_rounded,
                            color: Color(0xFF1E3A8A),
                            size: 28,
                          ),
                        ),

                      Text(
                        info.schoolName.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E3A8A),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Badge KARTU SISWA
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCD34D), width: 0.8),
                        ),
                        child: Text(
                          'KARTU SISWA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFD97706),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 3. Bingkai Foto Siswa Terpusat
                      Container(
                        width: 78,
                        height: 98,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (info.photoUrl != null && info.photoUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: info.photoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => _buildAvatarFallback(info.name),
                              )
                            : _buildAvatarFallback(info.name),
                      ),

                      const SizedBox(height: 10),

                      // 4. Nama Siswa (Tanpa Kelas agar Berlaku Permanen)
                      Text(
                        info.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E3A8A),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      // 5. Kotak Username (NISN / NIS)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE), width: 0.9),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 10,
                                  color: Color(0xFF3B82F6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'USERNAME ($identifierLabel)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF3B82F6),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              identifierValue,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E3A8A),
                                letterSpacing: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 6. Barcode Code-128
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          children: [
                            Semantics(
                              label: 'Barcode presensi Code 128 dengan kode ${info.barcodeCode}',
                              child: BarcodeWidget(
                                barcode: Barcode.code128(),
                                data: info.barcodeCode,
                                height: 38,
                                width: double.infinity,
                                drawText: false,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              info.barcodeCode,
                              style: GoogleFonts.robotoMono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 7. Footer Tagline / Alamat Sekolah
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          info.schoolAddress.isNotEmpty && info.schoolAddress != '-'
                              ? info.schoolAddress
                              : 'SMP Negeri 3 Kedungreja',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // 8. Strip Bawah (Dual Color: Amber 1/3 + Biru Tua 2/3)
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(height: 4, color: const Color(0xFFF59E0B)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(height: 4, color: const Color(0xFF1E3A8A)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Sisi Belakang Kartu Pelajar (Ketentuan & Tanda Tangan Kepsek)
  Widget _buildCardBack(SiswaKartuDigitalInfo info, {Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Slate Dark
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Sisi Belakang
            Row(
              children: [
                const Icon(
                  Icons.policy_rounded,
                  color: Color(0xFFFCD34D),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'KETENTUAN KARTU PELAJAR',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFCD34D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 12),

            // Butir Peraturan
            _buildRuleItem('1', 'Kartu ini merupakan tanda pengenal sah peserta didik ${info.schoolName}.'),
            _buildRuleItem('2', 'Wajib dibawa setiap hari aktif sekolah untuk keperluan presensi barcode gerbang & transaksi perpustakaan.'),
            _buildRuleItem('3', 'Dilarang meminjamkan, merusak, mencoret, atau menggandakan kartu tanpa persetujuan sekolah.'),
            _buildRuleItem('4', 'Jika kartu fisik rusak/hilang, siswa dapat menunjukkan kartu digital ini atau mengunduh ulang berkas PDF resminya.'),

            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
            const SizedBox(height: 12),

            // Pengesahan Kepala Sekolah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masa Berlaku:',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Selama Menjadi Siswa Aktif',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Kepala Sekolah,',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      info.principalName,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    if (info.principalNip.isNotEmpty && info.principalNip != '-')
                      Text(
                        'NIP. ${info.principalNip}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// Fallback Avatar Inisial
  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Panel Tombol Aksi (Scan Fullscreen, Unduh PDF Kartu, Unduh Biodata, Salin Barcode)
  Widget _buildActionPanel(SiswaKartuDigitalInfo info) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Aksi & Unduhan Resmi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),

          // Tombol 1: Mode Scan Layar Penuh
          ElevatedButton.icon(
            onPressed: () => _showFullscreenBarcode(info),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            label: Text(
              'Buka Mode Scan Layar Penuh',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol 2 & 3: Unduh PDF Kartu & Unduh Biodata
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final url = _service.getDownloadPdfUrl(identifier: widget.identifier);
                    _openPdf(url, 'Kartu Siswa (PDF)');
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: Text(
                    'Unduh PDF Kartu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669), // Emerald
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final url = _service.getBiodataPdfUrl(identifier: widget.identifier);
                    _openPdf(url, 'Biodata Siswa (PDF)');
                  },
                  icon: const Icon(Icons.description_rounded, size: 18),
                  label: Text(
                    'Unduh Biodata',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tombol 4: Salin Barcode
          OutlinedButton.icon(
            onPressed: () => _copyBarcode(info.barcodeCode),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(
              'Salin Kode Barcode (${info.barcodeCode})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu Informasi & Panduan Penggunaan
  Widget _buildPanduanCard(SiswaKartuDigitalInfo info) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF4338CA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tips Pemindaian Barcode',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF312E81),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTipRow(
            Icons.brightness_high_rounded,
            'Pastikan kecerahan layar HP cukup terang saat dihadapkan ke alat scanner gerbang.',
          ),
          _buildTipRow(
            Icons.straighten_rounded,
            'Jaga jarak layar HP sekitar 10-15 cm tegak lurus dengan moncong pemindai barcode.',
          ),
          _buildTipRow(
            Icons.print_outlined,
            'Berkas PDF kartu pelajar siap dicetak pada kertas foto tebal atau kartu PVC standar ID-1.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF3730A3),
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
