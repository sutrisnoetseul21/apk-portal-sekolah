import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/konsultasi_guru_wali_model.dart';

class ChatInputBar extends StatelessWidget {
  final KonsultasiGuruWaliItem item;
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback? onTapInput;

  const ChatInputBar({
    super.key,
    required this.item,
    required this.controller,
    required this.isSending,
    required this.onSend,
    this.onTapInput,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = item.statusPengajuan == 'Ditolak' || item.statusPengajuan == 'Selesai';

    if (isClosed) {
      return Container(
        padding: const EdgeInsets.all(14),
        color: const Color(0xFFF1F5F9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              'Sesi cerita ini telah ditutup (${item.statusPengajuan}).',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 1,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Ketik pesan balasan untuk murid...',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onTap: onTapInput,
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFF2563EB),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isSending ? null : onSend,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: isSending
                      ? const SpinKitRing(color: Colors.white, size: 18, lineWidth: 2)
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
