/// Model dan parser untuk konten bimbingan klasikal terstruktur
class StructuredKlasikalContent {
  final String? topik;
  final String? permasalahan;
  final String? tanggapan;
  final String? ulasan;
  final String rawText;
  final bool isStructured;

  const StructuredKlasikalContent({
    this.topik,
    this.permasalahan,
    this.tanggapan,
    this.ulasan,
    required this.rawText,
    required this.isStructured,
  });

  factory StructuredKlasikalContent.parse(String text) {
    final trimmed = text.trim();
    final hasKeys = trimmed.contains('Topik:') ||
        trimmed.contains('Permasalahan Siswa:') ||
        trimmed.contains('Tanggapan Guru:') ||
        trimmed.contains('Ulasan & Refleksi Siswa:');

    if (!hasKeys) {
      return StructuredKlasikalContent(rawText: trimmed, isStructured: false);
    }

    String? topik;
    String? permasalahan;
    String? tanggapan;
    String? ulasan;

    final topikMatch = RegExp(
      r'Topik:\s*(.*?)(?=\n\s*(?:Permasalahan Siswa:|Tanggapan Guru:|Ulasan & Refleksi Siswa:|$))',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (topikMatch != null) {
      topik = topikMatch.group(1)?.trim();
      if (topik != null &&
          topik.startsWith('"') &&
          topik.endsWith('"') &&
          topik.length > 2) {
        topik = topik.substring(1, topik.length - 1).trim();
      }
    }

    final permasalahanMatch = RegExp(
      r'Permasalahan Siswa:\s*(.*?)(?=\n\s*(?:Tanggapan Guru:|Ulasan & Refleksi Siswa:|$))',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (permasalahanMatch != null) {
      permasalahan = permasalahanMatch.group(1)?.trim();
      if (permasalahan != null &&
          ((permasalahan.startsWith("'") && permasalahan.endsWith("'")) ||
              (permasalahan.startsWith('"') && permasalahan.endsWith('"'))) &&
          permasalahan.length > 2) {
        permasalahan =
            permasalahan.substring(1, permasalahan.length - 1).trim();
      }
    }

    final tanggapanMatch = RegExp(
      r'Tanggapan Guru:\s*(.*?)(?=\n\s*(?:Ulasan & Refleksi Siswa:|$))',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (tanggapanMatch != null) {
      tanggapan = tanggapanMatch.group(1)?.trim();
    }

    final ulasanMatch = RegExp(
      r'Ulasan & Refleksi Siswa:\s*(.*)',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (ulasanMatch != null) {
      ulasan = ulasanMatch.group(1)?.trim();
    }

    return StructuredKlasikalContent(
      topik: topik,
      permasalahan: permasalahan,
      tanggapan: tanggapan,
      ulasan: ulasan,
      rawText: trimmed,
      isStructured: true,
    );
  }
}

