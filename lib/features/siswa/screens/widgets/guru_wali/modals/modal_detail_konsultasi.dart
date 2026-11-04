import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/core/widgets/keyboard_aware_sheet.dart';
import '../../../models/siswa_guru_wali_model.dart';
import '../../../services/siswa_guru_wali_service.dart';

/// Modal Bottom Sheet Detail Konsultasi & Percakapan Pesan Inline
class ModalDetailKonsultasi extends StatefulWidget {
  final SiswaGuruWaliService service;
  final String identifier;
  final SiswaKonsultasiItem initialItem;
  final VoidCallback onChanged;

  const ModalDetailKonsultasi({
    super.key,
    required this.service,
    required this.identifier,
    required this.initialItem,
    required this.onChanged,
  });

  static void show(
    BuildContext context, {
    required SiswaGuruWaliService service,
    required String identifier,
    required SiswaKonsultasiItem initialItem,
    required VoidCallback onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ModalDetailKonsultasi(
        service: service,
        identifier: identifier,
        initialItem: initialItem,
        onChanged: onChanged,
      ),
    );
  }

  @override
  State<ModalDetailKonsultasi> createState() => _ModalDetailKonsultasiState();
}

class _ModalDetailKonsultasiState extends State<ModalDetailKonsultasi> {
  late SiswaKonsultasiItem _item;
  List<SiswaPesanItem> _messages = [];
  bool _isLoading = true;
  final TextEditingController _pesanController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _item = widget.initialItem;
    _fetchDetail();
  }

  @override
  void dispose() {
    _pesanController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _fetchDetail() async {
    try {
      final res = await widget.service.getKonsultasiDetail(
        id: _item.id,
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _item = res.item;
          _messages = res.messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _pesanController.text.trim();
    if (text.length < 2) return;

    setState(() => _isSending = true);

    try {
      final newMsg = await widget.service.sendPesan(
        id: _item.id,
        pesan: text,
        identifier: widget.identifier,
      );

      _pesanController.clear();

      if (mounted) {
        setState(() {
          _messages.add(newMsg);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _cancelKonsultasi() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Konsultasi?'),
        content: const Text(
            'Apakah Anda yakin ingin membatalkan permohonan konsultasi ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Kembali')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await widget.service
            .cancelKonsultasi(id: _item.id, identifier: widget.identifier);
        if (mounted) {
          Navigator.pop(context);
          widget.onChanged();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }

  void _showFeedbackDialog() {
    int rating = 5;
    String emoji = 'Lega';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Ulasan Sesi Bimbingan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bagaimana perasaan Anda setelah sesi ini?',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
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
                              minHeight: 48, minWidth: 48),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
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
                  const Text('Rating Bintang:',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
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
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white),
                onPressed: () async {
                  await widget.service.submitFeedback(
                    id: _item.id,
                    rating: rating,
                    emoji: emoji,
                    note: noteController.text.trim(),
                    identifier: widget.identifier,
                  );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    _fetchDetail();
                    widget.onChanged();
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

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareSheet(
      backgroundColor: Colors.white,
      maxHeightFactor: 0.90,
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _item.topik,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Status & Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFFF8FAFC),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Guru Wali: ${_item.guruName}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.textPrimary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _item.statusLabel,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Color(0xFF2563EB)),
                                  ),
                                ),
                              ],
                            ),
                            if (_item.formattedJadwalPasti != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.event_available_rounded,
                                      size: 16, color: Color(0xFF059669)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Jadwal: ${_item.formattedJadwalPasti}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF065F46)),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              _item.detail,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),

                      // Thread Percakapan Pesan
                      Expanded(
                        child: _messages.isEmpty
                            ? Center(
                                child: Text(
                                  _item.mode == 'Pesan Portal'
                                      ? 'Belum ada pesan obrolan.\nTulis pesan di bawah untuk memulai.'
                                      : 'Konsultasi ini menggunakan mode Tatap Muka.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final msg = _messages[index];
                                  return Align(
                                    alignment: msg.isMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75),
                                      decoration: BoxDecoration(
                                        color: msg.isMe
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(14),
                                          topRight: const Radius.circular(14),
                                          bottomLeft: Radius.circular(
                                              msg.isMe ? 14 : 2),
                                          bottomRight: Radius.circular(
                                              msg.isMe ? 2 : 14),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg.pesan,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: msg.isMe
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            msg.formattedTime,
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: msg.isMe
                                                  ? Colors.white70
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Baris Input Pesan atau Tombol Aksi
                      if (_item.canChat) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                top: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _pesanController,
                                  onTap: () {
                                    Future.delayed(
                                      const Duration(milliseconds: 300),
                                      () {
                                        if (mounted) _scrollToBottom();
                                      },
                                    );
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Tulis pesan balasan...',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: _isSending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Icon(Icons.send_rounded,
                                        color: Color(0xFF2563EB)),
                                tooltip: 'Kirim pesan balasan',
                                onPressed: _isSending ? null : _sendMessage,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Tombol Feedback atau Batalkan
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            if (_item.isCancellable) ...[
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFDC2626),
                                    side: const BorderSide(
                                        color: Color(0xFFDC2626)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  onPressed: _cancelKonsultasi,
                                  child: const Text('Batalkan Konsultasi Ini',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                            if (_item.canFeedback) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF059669),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  icon: const Icon(Icons.star_outline_rounded),
                                  label: Text(
                                    _item.feedbackRating != null
                                        ? 'Ubah Ulasan Sesi'
                                        : 'Beri Ulasan Bimbingan',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: _showFeedbackDialog,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

