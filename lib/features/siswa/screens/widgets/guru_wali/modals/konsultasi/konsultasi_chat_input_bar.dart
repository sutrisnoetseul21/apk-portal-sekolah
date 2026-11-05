import 'package:flutter/material.dart';

class KonsultasiChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onTapField;

  const KonsultasiChatInputBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onTapField,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onTap: onTapField,
              decoration: InputDecoration(
                hintText: 'Tulis pesan balasan...',
                hintStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.send_rounded,
                    color: Color(0xFF2563EB),
                  ),
            tooltip: 'Kirim pesan balasan',
            onPressed: isSending ? null : onSend,
          ),
        ],
      ),
    );
  }
}
