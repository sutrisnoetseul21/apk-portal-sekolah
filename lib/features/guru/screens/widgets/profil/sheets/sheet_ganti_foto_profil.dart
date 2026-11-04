import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/guru_profil_model.dart';

/// Modal BottomSheet Pilihan Aksi Foto Profil (Kamera, Galeri, Hapus)
class SheetGantiFotoProfil {
  static void show(
    BuildContext context, {
    required GuruProfilData data,
    required void Function(ImageSource source) onPickPhoto,
    required VoidCallback onRemovePhoto,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pill Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Foto Profil Pendidik',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih foto resmi untuk memperbarui identitas akun Anda:',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),

            // Pilihan 1: Kamera
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: const Color(0xFFF8FAFC),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              title: Text(
                'Ambil Foto dari Kamera',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              subtitle: const Text(
                'Potret langsung menggunakan kamera ponsel',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onPickPhoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),

            // Pilihan 2: Galeri
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: const Color(0xFFF8FAFC),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
              title: Text(
                'Pilih dari Galeri Foto',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              subtitle: const Text(
                'Pilih berkas gambar resmi dari album ponsel',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onPickPhoto(ImageSource.gallery);
              },
            ),

            // Pilihan 3: Hapus Foto (hanya jika ada foto)
            if (data.teacher.hasPhoto) ...[
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: const Color(0xFFFFF1F2),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE11D48),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Hapus Foto Profil',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9F1239),
                  ),
                ),
                subtitle: const Text(
                  'Kembalikan avatar ke inisial nama pendidik',
                  style: TextStyle(fontSize: 11, color: Color(0xFFBE123C)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onRemovePhoto();
                },
              ),
            ],

            const SizedBox(height: 12),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

