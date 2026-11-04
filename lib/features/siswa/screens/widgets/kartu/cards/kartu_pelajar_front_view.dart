import 'package:barcode_widget/barcode_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/config/app_config.dart';
import '../../../models/siswa_kartu_model.dart';
import '../painters/kartu_stripes_painter.dart';

/// Sisi Depan Kartu Pelajar Digital (Logo Sekolah, Foto, Nama, Username/NISN & Barcode Code 128)
class KartuPelajarFrontView extends StatelessWidget {
  final SiswaKartuDigitalInfo info;
  final GlobalKey? cardBoundaryKey;

  const KartuPelajarFrontView({
    super.key,
    required this.info,
    this.cardBoundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    final identifierLabel = info.scanMode == 'nis' ? 'NIS' : 'NISN';
    final identifierValue = info.scanMode == 'nis' ? info.nis : info.nisn;

    // Mendapatkan hostname/domain dari baseUrl
    String domainName = 'localhost';
    try {
      final uri = Uri.parse(AppConfig.baseUrl);
      domainName = uri.host.isNotEmpty ? uri.host : 'localhost';
    } catch (_) {}

    return Center(
      child: Container(
        key: cardBoundaryKey,
        width: 280,
        height: 445,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          gradient: const LinearGradient(
            begin: Alignment(-0.8, -1.0),
            end: Alignment(0.8, 1.0),
            colors: [
              Color(0xFFF0F7FF), // Biru sangat muda (top-left)
              Colors.white, // Putih bersih (center)
              Color(0xFFFFF8ED), // Amber hangat sangat muda (bottom-right)
            ],
            stops: [0.0, 0.6, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.16),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 1. Pola Garis Diagonal Halus
            const Positioned.fill(
              child: CustomPaint(
                painter: CardStripesPainter(),
              ),
            ),

            // 2. Dekorasi Background Arc (Lingkaran Kanan Atas & Kiri Bawah)
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      const Color(0xFF1E3A8A).withValues(alpha: 0.04),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -25,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      const Color(0xFFD97706).withValues(alpha: 0.04),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Konten Utama Kartu dengan Flex Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Strip Atas: Gradien 3 Warna (Biru Navy -> Biru Muda -> Amber)
                Container(
                  height: 3.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF3B82F6),
                        Color(0xFFF59E0B),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Kop Logo & Nama Sekolah
                        Column(
                          children: [
                            if (info.schoolLogoUrl != null &&
                                info.schoolLogoUrl!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: info.schoolLogoUrl!,
                                  height: 36,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Icon(
                                    Icons.school_rounded,
                                    color: Color(0xFF1E3A8A),
                                    size: 32,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.school_rounded,
                                    color: Color(0xFF1E3A8A),
                                    size: 32,
                                  ),
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Icon(
                                  Icons.school_rounded,
                                  color: Color(0xFF1E3A8A),
                                  size: 34,
                                ),
                              ),

                            Text(
                              info.schoolName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1E3A8A),
                                letterSpacing: 0.5,
                                height: 1.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),

                            Text(
                              'KARTU SISWA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFD97706),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),

                        // Bingkai Foto Siswa Terpusat
                        Container(
                          width: 72,
                          height: 94,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3A8A)
                                    .withValues(alpha: 0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.15),
                                blurRadius: 1,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: (info.photoUrl != null &&
                                  info.photoUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: info.photoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      _buildAvatarFallback(info.name),
                                )
                              : _buildAvatarFallback(info.name),
                        ),

                        // Nama Siswa
                        Text(
                          info.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E3A8A),
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Kotak Username / NISN
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE)
                                  .withValues(alpha: 0.9),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 11,
                                    color: Color(0xFF3B82F6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'USERNAME ($identifierLabel)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF3B82F6),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                identifierValue,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1E3A8A),
                                  letterSpacing: 2.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Barcode Code-128
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Semantics(
                            label:
                                'Barcode presensi Code 128 dengan kode ${info.barcodeCode}',
                            child: BarcodeWidget(
                              barcode: Barcode.code128(),
                              data: info.barcodeCode,
                              height: 42,
                              width: double.infinity,
                              drawText: false,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        // Footer Domain Host
                        Text(
                          domainName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3B82F6),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Strip Bawah: Gradien 3 Warna (Amber -> Biru Muda -> Biru Navy)
                Container(
                  height: 3.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF59E0B),
                        Color(0xFF3B82F6),
                        Color(0xFF1E3A8A),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAvatarFallback(String name) {
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
}

