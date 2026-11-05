import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog konfirmasi penghapusan foto profil siswa
class DialogKonfirmasiHapusFotoSiswa extends StatelessWidget {
  const DialogKonfirmasiHapusFotoSiswa({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => const DialogKonfirmasiHapusFotoSiswa(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Hapus Foto Profil?',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
      ),
      content: Text(
        'Apakah Anda yakin ingin menghapus foto profil dan kembali menggunakan inisial nama?',
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Hapus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
