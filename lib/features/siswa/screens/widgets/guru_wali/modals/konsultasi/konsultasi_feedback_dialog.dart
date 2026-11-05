import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class KonsultasiFeedbackDialog {
  static void show(
    BuildContext context, {
    required Future<void> Function({
      required int rating,
      required String emoji,
      required String note,
    }) onSubmit,
  }) {
    int rating = 5;
    String emoji = 'Lega';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Ulasan Sesi Bimbingan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bagaimana perasaan Anda setelah sesi ini?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Lega', 'Biasa', 'Masih Bingung'].map((e) {
                      final isSel = emoji == e;
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setDialogState(() => emoji = e),
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 48,
                            minWidth: 48,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            e,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.w500,
                              color:
                                  isSel ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Rating Bintang:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 28,
                        ),
                        tooltip: 'Beri ${index + 1} bintang',
                        onPressed: () =>
                            setDialogState(() => rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Pesan / catatan kesan (opsional)',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await onSubmit(
                    rating: rating,
                    emoji: emoji,
                    note: noteController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Kirim Ulasan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
