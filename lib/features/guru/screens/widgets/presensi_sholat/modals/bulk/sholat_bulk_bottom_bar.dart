import 'package:flutter/material.dart';

class SholatBulkBottomBar extends StatelessWidget {
  final bool isSavingModal;
  final bool isHoliday;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  static const Color _emeraldPrimary = Color(0xFF059669);

  const SholatBulkBottomBar({
    super.key,
    required this.isSavingModal,
    required this.isHoliday,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSavingModal ? null : onCancel,
              child: const Text('Batal'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _emeraldPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: (isHoliday || isSavingModal) ? null : onSave,
              icon: const Icon(Icons.save_outlined, size: 17),
              label: Text(
                isSavingModal ? 'Menyimpan...' : 'Simpan Presensi Kelas',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
