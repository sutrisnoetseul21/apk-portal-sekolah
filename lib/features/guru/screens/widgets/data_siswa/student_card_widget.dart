import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apk_portal_smpn1_sampang/core/utils/pdf_print_util.dart';
import '../../../models/student_model.dart';
import '../../../services/data_siswa_service.dart';
import 'dialog_ganti_password.dart';
import 'dialog_kartu_digital.dart';
import 'modal_edit_biodata.dart';
import 'modal_edit_no_hp.dart';

/// Card Siswa Interaktif untuk Direktori Siswa Mobile (Menu 6)
class StudentCardWidget extends StatelessWidget {
  final StudentModel student;
  final String schoolName;
  final String className;
  final DataSiswaService service;
  final Function(StudentModel updated) onStudentUpdated;

  const StudentCardWidget({
    super.key,
    required this.student,
    required this.schoolName,
    required this.className,
    required this.service,
    required this.onStudentUpdated,
  });

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka tautan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openWhatsApp(BuildContext context) {
    // Prioritas hubungi no HP orang tua, fallback ke no HP siswa
    final targetWa = (student.waHpOrtu != null && student.waHpOrtu!.isNotEmpty)
        ? student.waHpOrtu
        : student.waHpSiswa;

    if (targetWa == null || targetWa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor WhatsApp belum terdaftar untuk siswa ini.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    final greeting = Uri.encodeComponent(
      'Halo Bapak/Ibu wali dari ${student.nama} (Kelas $className), kami dari pihak sekolah...',
    );
    _launchUrl(context, 'https://wa.me/$targetWa?text=$greeting');
  }

  void _openPhoneCall(BuildContext context) {
    final rawNumber = (student.noHpOrangTua != null &&
            student.noHpOrangTua!.isNotEmpty)
        ? student.noHpOrangTua
        : student.noHp;

    if (rawNumber == null || rawNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor telepon belum diatur.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    final sanitized = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    _launchUrl(context, 'tel:$sanitized');
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        student.nama.isNotEmpty ? student.nama[0] : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        student.nama,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 1. Edit Biodata Lengkap
              ListTile(
                leading: const Icon(Icons.edit_note_rounded,
                    color: Color(0xFF2563EB)),
                title: Text(
                  'Edit Biodata Lengkap',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: const Text('Identitas, Asal Sekolah, Data Ortu, Foto'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ModalEditBiodataSheet.show(
                    context: context,
                    student: student,
                    service: service,
                    onSuccess: onStudentUpdated,
                  );
                },
              ),

              // 2. Edit Kontak Cepat
              ListTile(
                leading: const Icon(Icons.phone_iphone_rounded,
                    color: Color(0xFF10B981)),
                title: Text(
                  'Edit Cepat No. HP',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: const Text('Perbarui No. HP Siswa & Orang Tua'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ModalEditNoHpSheet.show(
                    context: context,
                    student: student,
                    service: service,
                    onSuccess: (noHp, noHpOrtu) {
                      onStudentUpdated(
                        student.copyWith(
                          noHp: noHp,
                          noHpOrangTua: noHpOrtu,
                          waHpSiswa: (noHp != null && noHp.startsWith('08'))
                              ? '628${noHp.substring(2)}'
                              : noHp,
                          waHpOrtu: (noHpOrtu != null && noHpOrtu.startsWith('08'))
                              ? '628${noHpOrtu.substring(2)}'
                              : noHpOrtu,
                        ),
                      );
                    },
                  );
                },
              ),

              // 3. Reset / Ganti Password
              ListTile(
                leading:
                    const Icon(Icons.lock_reset_rounded, color: Color(0xFFD97706)),
                title: Text(
                  'Ganti Password Akun Siswa',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: const Text('Bantu siswa yang lupa kata sandi login'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  DialogGantiPasswordSiswa.show(
                    context: context,
                    student: student,
                    service: service,
                  );
                },
              ),

              // 4. Unduh Berkas PDF Biodata Resmi
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded,
                    color: Color(0xFFDC2626)),
                title: Text(
                  'Unduh Berkas Biodata Resmi (PDF)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                subtitle: const Text('Format cetak dokumen resmi sekolah'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  final url = service.getCetakBiodataUrl(student.id);
                  PdfPrintUtil.printOrSavePdf(
                    context: context,
                    url: url,
                    title: 'Biodata Siswa - ${student.nama}',
                    identifier: service.identifier,
                  );
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBarcode = student.barcodeActive && (student.barcodeCode != null);
    final hasPhone = (student.noHpOrangTua != null &&
            student.noHpOrangTua!.isNotEmpty) ||
        (student.noHp != null && student.noHp!.isNotEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ATAS: FOTO & INFORMASI UTAMA
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Lingkaran dengan Status Ring Barcode
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade50,
                        border: Border.all(
                          color: hasBarcode
                              ? const Color(0xFF10B981) // Hijau = barcode aktif
                              : const Color(0xFFCBD5E1), // Abu = belum
                          width: 2.2,
                        ),
                      ),
                      child: ClipOval(
                        child: (student.fotoUrl != null &&
                                student.fotoUrl!.isNotEmpty)
                            ? Image.network(
                                student.fotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackAvatar(),
                              )
                            : _buildFallbackAvatar(),
                      ),
                    ),
                    // Badge Indikator Barcode
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasBarcode
                            ? const Color(0xFF10B981)
                            : const Color(0xFF94A3B8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Nama & Identitas Siswa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.nama,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Badge Gender
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: student.gender.toUpperCase() == 'L'
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFFDF2F8),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: student.gender.toUpperCase() == 'L'
                                    ? const Color(0xFFBFDBFE)
                                    : const Color(0xFFFBCFE8),
                              ),
                            ),
                            child: Text(
                              student.gender.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: student.gender.toUpperCase() == 'L'
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFFBE185D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NISN: ${student.nisn} • NIS: ${student.nis}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Barcode Code & Status Bar
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 14,
                            color: hasBarcode
                                ? const Color(0xFF059669)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hasBarcode
                                  ? 'Barcode: ${student.barcodeCode}'
                                  : 'Belum ada barcode',
                              style: GoogleFonts.robotoMono(
                                fontSize: 11,
                                fontWeight: hasBarcode
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: hasBarcode
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF94A3B8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TENGAH: INFO KONTAK ORTU / SISWA
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_pin_circle_outlined,
                  size: 15,
                  color: hasPhone ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (student.namaAyah != null && student.namaAyah!.isNotEmpty)
                        ? 'Ortu: ${student.namaAyah} (${student.noHpOrangTua ?? "Belum ada HP"})'
                        : (student.noHpOrangTua != null &&
                                student.noHpOrangTua!.isNotEmpty)
                            ? 'Ortu: ${student.noHpOrangTua}'
                            : (student.noHp != null && student.noHp!.isNotEmpty)
                                ? 'HP Siswa: ${student.noHp}'
                                : 'Kontak ortu/siswa belum diisi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: hasPhone
                          ? const Color(0xFF334155)
                          : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // BAWAH: ACTION BAR 1-KLIK (WhatsApp, Telepon, Kartu, Opsi)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // 1. WhatsApp Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _openWhatsApp(context),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                    label: Text(
                      'WA Ortu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF059669),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

                // 2. Telepon Suara
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _openPhoneCall(context),
                    icon: const Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Color(0xFF3B82F6),
                    ),
                    label: Text(
                      'Telepon',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

                // 3. Pratinjau Kartu Siswa
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      DialogKartuDigitalSiswa.show(
                        context: context,
                        student: student,
                        schoolName: schoolName,
                        className: className,
                        service: service,
                      );
                    },
                    icon: const Icon(
                      Icons.badge_outlined,
                      size: 16,
                      color: Color(0xFF6366F1),
                    ),
                    label: Text(
                      'Kartu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

                // 4. Menu Lainnya (Edit Biodata, No HP, Password, dsb.)
                IconButton(
                  onPressed: () => _showActionMenu(context),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  tooltip: 'Menu Opsi Siswa',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Center(
      child: Text(
        student.nama.isNotEmpty ? student.nama[0].toUpperCase() : '?',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }
}
