import 'package:flutter/material.dart';

class JurnalIndividuParameterForm extends StatelessWidget {
  final String kategori;
  final List<String> kategoriList;
  final ValueChanged<String?> onKategoriChanged;
  final String statusSesi;
  final ValueChanged<String?> onStatusSesiChanged;
  final String sentimen;
  final ValueChanged<String?> onSentimenChanged;
  final TextEditingController uraianController;
  final TextEditingController rtlController;

  const JurnalIndividuParameterForm({
    super.key,
    required this.kategori,
    required this.kategoriList,
    required this.onKategoriChanged,
    required this.statusSesi,
    required this.onStatusSesiChanged,
    required this.sentimen,
    required this.onSentimenChanged,
    required this.uraianController,
    required this.rtlController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori Pendampingan (4 Pilar)
        const Text(
          'Pilar Bimbingan (Permendikdasmen 11/2025)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: kategori,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
          ),
          items: kategoriList.map((kat) {
            return DropdownMenuItem<String>(
              value: kat,
              child: Text(kat, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onKategoriChanged,
        ),

        const SizedBox(height: 18),

        // Status Sesi & Rujukan Kolaborasi
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Sesi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: statusSesi,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Tuntas / Selesai', child: Text('Tuntas', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Dalam Pemantauan', child: Text('Pemantauan', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Bimbingan Lanjutan', child: Text('Lanjutan', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: onStatusSesiChanged,
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
                    'Sentimen Emosional',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: sentimen,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Positif', child: Text('🟢 Positif', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Netral', child: Text('⚪ Netral', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'Negatif', child: Text('🔴 Cemas/Negatif', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: onSentimenChanged,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Uraian Masalah / Pembahasan
        const Text(
          'Uraian Pembahasan & Masalah *',
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
            hintText: 'Tuliskan topik, dinamika perkembangan, atau hal yang dibahas...',
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

        // Rencana Tindak Lanjut
        const Text(
          'Rencana Tindak Lanjut (RTL)',
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
            hintText: 'Langkah nyata yang disepakati untuk bimbingan berikutnya...',
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
