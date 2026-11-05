import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog konfirmasi penghapusan foto profil guru
class DialogKonfirmasiHapusFoto extends StatelessWidget {
  const DialogKonfirmasiHapusFoto({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => const DialogKonfirmasiHapusFoto(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Hapus Foto Profil?',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ),
      content: const Text(
        'Apakah Anda yakin ingin menghapus foto profil dan kembali menggunakan avatar inisial nama?',
        style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Ya, Hapus'),
        ),
      ],
    );
  }
}
