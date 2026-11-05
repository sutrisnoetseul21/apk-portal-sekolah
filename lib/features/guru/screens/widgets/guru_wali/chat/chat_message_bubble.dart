import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final bool isMe;
  final String senderLabel;
  final String pesan;
  final String timestamp;

  const ChatMessageBubble({
    super.key,
    required this.isMe,
    required this.senderLabel,
    required this.pesan,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFFE2E8F0),
              child: Text(
                senderLabel.isNotEmpty ? senderLabel[0].toUpperCase() : 'S',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF2563EB) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isMe ? 14 : 2),
                  bottomRight: Radius.circular(isMe ? 2 : 14),
                ),
                border: Border.all(
                  color: isMe ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    pesan,
                    style: TextStyle(
                      fontSize: 13,
                      color: isMe ? Colors.white : const Color(0xFF1E293B),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    timestamp,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: isMe ? Colors.white70 : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
