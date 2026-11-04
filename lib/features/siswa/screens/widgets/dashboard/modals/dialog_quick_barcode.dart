import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Modal dialog barcode cepat kartu pelajar siswa
class DialogQuickBarcode extends StatelessWidget {
  final String schoolName;
  final String studentName;
  final String nisn;
  final String className;
  final String barcodeData;
  final VoidCallback onOpenFullCard;

  const DialogQuickBarcode({
    super.key,
    required this.schoolName,
    required this.studentName,
    required this.nisn,
    required this.className,
    required this.barcodeData,
    required this.onOpenFullCard,
  });

  static Future<void> show(
    BuildContext context, {
    required String schoolName,
    required String studentName,
    required String nisn,
    required String className,
    required String barcodeData,
    required VoidCallback onOpenFullCard,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => DialogQuickBarcode(
        schoolName: schoolName,
        studentName: studentName,
        nisn: nisn,
        className: className,
        barcodeData: barcodeData,
        onOpenFullCard: onOpenFullCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              schoolName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Kartu Pelajar Barcode Digital',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: barcodeData,
                    width: 260,
                    height: 90,
                    drawText: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              studentName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'NISN: $nisn • $className',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onOpenFullCard();
                    },
                    icon: const Icon(Icons.badge_rounded, size: 16),
                    label: const Text('Buka Kartu & PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

