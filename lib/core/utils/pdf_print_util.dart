import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';

/// Utilitas untuk mengunduh dan mencetak/menampilkan PDF langsung di dalam aplikasi
/// tanpa perlu membuka peramban luar (Google Chrome/browser eksternal).
class PdfPrintUtil {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 45),
      responseType: ResponseType.bytes,
    ),
  );

  /// Mengunduh raw bytes dari URL PDF dengan header autentikasi
  static Future<Uint8List> fetchPdfBytes({
    required String url,
    String? token,
    String? identifier,
  }) async {
    final headers = <String, dynamic>{
      'Accept': 'application/pdf',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (identifier != null && identifier.isNotEmpty) {
      headers['X-User-Identifier'] = identifier;
    }

    final response = await _dio.get<List<int>>(
      url,
      options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      return Uint8List.fromList(response.data!);
    } else {
      throw Exception('Gagal mengunduh dokumen PDF (HTTP ${response.statusCode})');
    }
  }

  /// Menampilkan dialog loading, mengambil PDF, lalu langsung membuka
  /// dialog pratinjau cetak / simpan sebagai PDF bawaan sistem operasi.
  static Future<void> printOrSavePdf({
    required BuildContext context,
    required String url,
    required String title,
    String? filename,
    String? token,
    String? identifier,
  }) async {
    final pdfFilename = filename ?? '${title.replaceAll(RegExp(r'[^\w\s\.-]'), '_')}.pdf';

    // Tampilkan loading dialog
    bool isDialogShowing = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menyiapkan PDF...',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final bytes = await fetchPdfBytes(
        url: url,
        token: token,
        identifier: identifier,
      );

      // Tutup dialog loading jika masih aktif
      if (context.mounted && isDialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogShowing = false;
      }

      // Buka native print / PDF spooler tanpa browser eksternal
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: pdfFilename,
      );
    } catch (e) {
      if (context.mounted && isDialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogShowing = false;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gagal memproses berkas PDF: ${e.toString().replaceAll('Exception: ', '')}',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  /// Membagikan atau menyimpan berkas PDF langsung (Download / Buka PDF Viewer / Drive / WA)
  static Future<void> sharePdf({
    required BuildContext context,
    required String url,
    required String title,
    String? filename,
    String? token,
    String? identifier,
  }) async {
    final pdfFilename = filename ?? '${title.replaceAll(RegExp(r'[^\w\s\.-]'), '_')}.pdf';

    // Tampilkan loading dialog
    bool isDialogShowing = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mengunduh PDF...',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final bytes = await fetchPdfBytes(
        url: url,
        token: token,
        identifier: identifier,
      );

      // Tutup dialog loading
      if (context.mounted && isDialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogShowing = false;
      }

      await Printing.sharePdf(
        bytes: bytes,
        filename: pdfFilename,
      );
    } catch (e) {
      if (context.mounted && isDialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
        isDialogShowing = false;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh berkas PDF: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}


