import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_guru_wali_model.dart';

class KonsultasiChatThread extends StatelessWidget {
  final List<SiswaPesanItem> messages;
  final String mode;
  final ScrollController scrollController;

  const KonsultasiChatThread({
    super.key,
    required this.messages,
    required this.mode,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          mode == 'Pesan Portal'
              ? 'Belum ada pesan obrolan.\nTulis pesan di bawah untuk memulai.'
              : 'Konsultasi ini menggunakan mode Tatap Muka.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return Align(
          alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: msg.isMe
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(msg.isMe ? 14 : 2),
                bottomRight: Radius.circular(msg.isMe ? 2 : 14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.pesan,
                  style: TextStyle(
                    fontSize: 13,
                    color: msg.isMe ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.formattedTime,
                  style: TextStyle(
                    fontSize: 9,
                    color: msg.isMe ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
