import 'package:flutter/material.dart';
import '../../../../../core/utils/image_compress_util.dart';

/// Komponen upload foto bukti kasus perundungan dengan batasan maks 5 foto
class SpikapEvidencePhotoUploader extends StatelessWidget {
  final List<CompressedImageResult> fotoAttachments;
  final VoidCallback onAddPhoto;
  final ValueChanged<int> onRemovePhoto;

  const SpikapEvidencePhotoUploader({
    super.key,
    required this.fotoAttachments,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tombol Lampirkan Foto Bukti (Full Width)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF2563EB)),
            ),
            onPressed: onAddPhoto,
            icon: const Icon(
              Icons.add_a_photo_rounded,
              size: 20,
              color: Color(0xFF2563EB),
            ),
            label: Text(
              '+ Tambah Foto Bukti (${fotoAttachments.length}/5)',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Daftar Foto Terlampir
        if (fotoAttachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...List.generate(fotoAttachments.length, (index) {
            final item = fotoAttachments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      item.bytes,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Foto Bukti #${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          item.note,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFE11D48),
                      size: 20,
                    ),
                    tooltip: 'Hapus Foto #${index + 1}',
                    onPressed: () => onRemovePhoto(index),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

