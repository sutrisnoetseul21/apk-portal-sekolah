import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/guru_wali_service.dart';

/// Dialog untuk memilih format dan periode cetak PDF resmi Laporan Guru Wali
class DialogCetakPdf extends StatefulWidget {
  final GuruWaliService service;

  const DialogCetakPdf({
    super.key,
    required this.service,
  });

  @override
  State<DialogCetakPdf> createState() => _DialogCetakPdfState();
}

class _DialogCetakPdfState extends State<DialogCetakPdf> {
  String _periode = 'tahunan';
  String _type = 'rekap';
  bool _isLaunching = false;

  Future<void> _unduhPdf() async {
    setState(() => _isLaunching = true);

    final url = widget.service.getPdfDownloadUrl(
      type: _type,
      periode: _periode,
    );

    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mengunduh: $url'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLaunching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka URL cetak: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFE11D48), size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'Cetak Laporan PDF',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Periode Laporan:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),

            // Radio options
            RadioListTile<String>(
              dense: true,
              value: 'tahunan',
              groupValue: _periode,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFFE11D48),
              title: const Text('Rekapitulasi Tahunan (1 Tahun Penuh)', style: TextStyle(fontSize: 13)),
              subtitle: const Text('Format standar rekap Permendikdasmen 11/2025', style: TextStyle(fontSize: 11)),
              onChanged: (val) => setState(() => _periode = val!),
            ),
            RadioListTile<String>(
              dense: true,
              value: 'semester_1',
              groupValue: _periode,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFFE11D48),
              title: const Text('Semester Ganjil (Juli – Desember)', style: TextStyle(fontSize: 13)),
              onChanged: (val) => setState(() => _periode = val!),
            ),
            RadioListTile<String>(
              dense: true,
              value: 'semester_2',
              groupValue: _periode,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFFE11D48),
              title: const Text('Semester Genap (Januari – Juni)', style: TextStyle(fontSize: 13)),
              onChanged: (val) => setState(() => _periode = val!),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Laporan PDF akan memuat kop resmi sekolah, data kelompok binaan, dan tanda tangan digital Guru Wali.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isLaunching ? null : _unduhPdf,
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text('Unduh PDF'),
        ),
      ],
    );
  }
}
