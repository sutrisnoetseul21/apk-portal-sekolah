import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/pdf_print_util.dart';
import '../models/siswa_kartu_model.dart';
import '../services/siswa_kartu_service.dart';
import 'widgets/kartu/cards/kartu_pelajar_back_view.dart';
import 'widgets/kartu/cards/kartu_pelajar_front_view.dart';
import 'widgets/kartu/modals/modal_barcode_fullscreen.dart';
import 'widgets/kartu/sections/kartu_action_panel.dart';
import 'widgets/kartu/sections/kartu_flip_toggle.dart';
import 'widgets/kartu/sections/kartu_hero_banner.dart';
import 'widgets/kartu/sections/kartu_panduan_penggunaan.dart';

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
    this.schoolName = '',
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

  final GlobalKey _cardBoundaryKey = GlobalKey();
  bool _isSavingImage = false;

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

  Future<void> _saveCardAsImage(SiswaKartuDigitalInfo info) async {
    if (_isSavingImage) return;

    // Jika sedang di sisi belakang, kembalikan ke sisi depan dulu
    if (_isBackSide) {
      setState(() => _isBackSide = false);
      await Future.delayed(const Duration(milliseconds: 380));
    }

    setState(() => _isSavingImage = true);

    try {
      final boundary = _cardBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Gagal mendeteksi tampilan kartu.');
      }

      // Render kartu dengan resolusi tinggi (pixelRatio 3.5x untuk kualitas HD tajam)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.5);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Gagal mengonversi gambar kartu.');
      }
      final Uint8List imgBytes = byteData.buffer.asUint8List();

      // Dapatkan path folder Download HP (disimpan sebagai JPG/JPEG sesuai permintaan)
      final filename =
          'Kartu_Siswa_${info.nisn}_${info.name.replaceAll(RegExp(r'[^\w]'), '_')}.jpg';
      String targetPath = '';

      Directory? downloadDir;
      if (Platform.isAndroid) {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists()) {
          downloadDir = publicDownload;
        } else {
          downloadDir = await getExternalStorageDirectory();
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir != null) {
        final file = File('${downloadDir.path}/$filename');
        await file.writeAsBytes(imgBytes);
        targetPath = file.path;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Gambar Kartu Berhasil Disimpan!',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tersimpan di: ${targetPath.isNotEmpty ? targetPath : 'Folder Download'}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal menyimpan gambar: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingImage = false);
      }
    }
  }

  Future<void> _openPdf(String urlString, String title) async {
    await PdfPrintUtil.sharePdf(
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
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showFullscreenBarcode(SiswaKartuDigitalInfo info) {
    ModalBarcodeFullscreen.show(
      context,
      info: info,
      onCopyBarcode: (code) => _copyBarcode(code),
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
          'Kartu Pelajar Digital',
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
                child: Icon(Icons.error_outline_rounded,
                    size: 48, color: Colors.red.shade600),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
        const KartuHeroBanner(),
        const SizedBox(height: 20),

        // Kartu Pelajar Interaktif
        _buildCardContainer(info),
        const SizedBox(height: 14),

        // Toggle Flip Depan / Belakang
        KartuFlipToggle(
          isBackSide: _isBackSide,
          onToggleFront: () {
            if (_isBackSide) setState(() => _isBackSide = false);
          },
          onToggleBack: () {
            if (!_isBackSide) setState(() => _isBackSide = true);
          },
        ),
        const SizedBox(height: 24),

        // Tombol Aksi Utama (Scan Fullscreen, Download PDF, Biodata)
        KartuActionPanel(
          info: info,
          isSavingImage: _isSavingImage,
          onOpenFullscreenBarcode: () => _showFullscreenBarcode(info),
          onSaveCardAsImage: () => _saveCardAsImage(info),
          onDownloadBiodata: () {
            final url =
                _service.getBiodataPdfUrl(identifier: widget.identifier);
            _openPdf(url, 'Biodata Siswa - ${info.name}');
          },
          onCopyBarcode: () => _copyBarcode(info.barcodeCode),
        ),
        const SizedBox(height: 24),

        // Informasi Ketentuan & Panduan
        const KartuPanduanPenggunaan(),
      ],
    );
  }

  /// Tampilan untuk Tablet (Grid / 2 Kolom Side-by-Side)
  Widget _buildTabletLayout(SiswaKartuDigitalInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KartuHeroBanner(),
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
                  KartuFlipToggle(
                    isBackSide: _isBackSide,
                    onToggleFront: () {
                      if (_isBackSide) setState(() => _isBackSide = false);
                    },
                    onToggleBack: () {
                      if (!_isBackSide) setState(() => _isBackSide = true);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Kolom Kanan: Panel Aksi + Panduan
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  KartuActionPanel(
                    info: info,
                    isSavingImage: _isSavingImage,
                    onOpenFullscreenBarcode: () => _showFullscreenBarcode(info),
                    onSaveCardAsImage: () => _saveCardAsImage(info),
                    onDownloadBiodata: () {
                      final url = _service.getBiodataPdfUrl(
                          identifier: widget.identifier);
                      _openPdf(url, 'Biodata Siswa - ${info.name}');
                    },
                    onCopyBarcode: () => _copyBarcode(info.barcodeCode),
                  ),
                  const SizedBox(height: 20),
                  const KartuPanduanPenggunaan(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Kontainer Kartu Pelajar dengan Animasi Transisi & RepaintBoundary untuk Export Gambar
  Widget _buildCardContainer(SiswaKartuDigitalInfo info) {
    return RepaintBoundary(
      key: _cardBoundaryKey,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _isBackSide
            ? KartuPelajarBackView(
                key: const ValueKey('card_back'),
                info: info,
              )
            : KartuPelajarFrontView(
                key: const ValueKey('card_front'),
                info: info,
              ),
      ),
    );
  }
}
