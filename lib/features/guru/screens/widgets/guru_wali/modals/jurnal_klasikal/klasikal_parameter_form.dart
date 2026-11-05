import 'package:flutter/material.dart';

/// Form input parameter dan uraian materi bimbingan klasikal
class KlasikalParameterForm extends StatelessWidget {
  final String jenis;
  final String kategori;
  final List<String> kategoriList;
  final ValueChanged<String?> onJenisChanged;
  final ValueChanged<String?> onKategoriChanged;
  final TextEditingController uraianController;
  final TextEditingController rtlController;

  const KlasikalParameterForm({
    super.key,
    required this.jenis,
    required this.kategori,
    required this.kategoriList,
    required this.onJenisChanged,
    required this.onKategoriChanged,
    required this.uraianController,
    required this.rtlController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jenis & Pilar Bimbingan
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bentuk Sesi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: jenis,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Klasikal',
                        child: Text('Klasikal', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'Kelompok Kecil',
                        child: Text('Kelompok Kecil', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    onChanged: onJenisChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilar Bimbingan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: kategori,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                    items: kategoriList.map((kat) {
                      return DropdownMenuItem<String>(
                        value: kat,
                        child: Text(
                          kat,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onKategoriChanged,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Uraian Pembahasan & Respon Kelompok
        const Text(
          'Materi & Respon Kelompok *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: uraianController,
          maxLines: 4,
          scrollPadding: const EdgeInsets.only(bottom: 120),
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Tuliskan topik bimbingan klasikal, materi sosialisasi, atau dinamika kelompok...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().length < 5) {
              return 'Uraian bimbingan minimal 5 karakter.';
            }
            return null;
          },
        ),

        const SizedBox(height: 18),

        // Rencana Tindak Lanjut Kelompok
        const Text(
          'Rencana Tindak Lanjut Kelompok',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: rtlController,
          maxLines: 2,
          scrollPadding: const EdgeInsets.only(bottom: 120),
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Langkah monitoring atau tugas kelompok bersama...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
        ),
      ],
    );
  }
}
