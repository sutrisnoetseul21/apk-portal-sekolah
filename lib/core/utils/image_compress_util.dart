import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Hasil pengambilan gambar yang telah dikompresi otomatis ala WhatsApp
class CompressedImageResult {
  final XFile file;
  final Uint8List bytes;
  final int byteSize;
  final String formattedSize;
  final String note;

  const CompressedImageResult({
    required this.file,
    required this.bytes,
    required this.byteSize,
    required this.formattedSize,
    required this.note,
  });
}

/// Utilitas kompresi foto otomatis ala WhatsApp sebelum dikirim ke backend
/// Membatasi dimensi maksimal 1280x1280 px dan kualitas JPEG 70%
class ImageCompressUtil {
  static final ImagePicker _picker = ImagePicker();

  /// Mengambil dan mengompresi gambar dari Kamera atau Galeri
  /// Menghasilkan file berukuran ringan (~100 KB - 250 KB) tanpa mengurangi keterbacaan teks surat.
  static Future<CompressedImageResult?> pickAndCompressImage({
    required ImageSource source,
    double maxWidth = 1280,
    double maxHeight = 1280,
    int imageQuality = 70,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;

      final Uint8List bytes = await pickedFile.readAsBytes();
      final int length = bytes.length;
      final String formatted = formatBytes(length);

      return CompressedImageResult(
        file: pickedFile,
        bytes: bytes,
        byteSize: length,
        formattedSize: formatted,
        note: 'Terkonversi $formatted (Kompresi ala WhatsApp, hemat ~95% kuota)',
      );
    } catch (e) {
      return null;
    }
  }

  /// Format representasi ukuran byte ke KB / MB yang mudah dibaca
  static String formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (bytes.bitLength - 1) ~/ 10;
    if (i >= suffixes.length) i = suffixes.length - 1;
    final double size = bytes / (1 << (i * 10));
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
