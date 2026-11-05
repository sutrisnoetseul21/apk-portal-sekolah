import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';
import 'package:apk_portal_smpn1_sampang/core/widgets/keyboard_aware_sheet.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/models/siswa_guru_wali_model.dart';
import 'package:apk_portal_smpn1_sampang/features/siswa/services/siswa_guru_wali_service.dart';
import 'konsultasi/konsultasi_info_card.dart';
import 'konsultasi/konsultasi_chat_thread.dart';
import 'konsultasi/konsultasi_chat_input_bar.dart';
import 'konsultasi/konsultasi_feedback_dialog.dart';

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
          'Apakah Anda yakin ingin membatalkan permohonan konsultasi ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await widget.service.cancelKonsultasi(
          id: _item.id,
          identifier: widget.identifier,
        );
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
    KonsultasiFeedbackDialog.show(
      context,
      onSubmit: ({
        required int rating,
        required String emoji,
        required String note,
      }) async {
        await widget.service.submitFeedback(
          id: _item.id,
          rating: rating,
          emoji: emoji,
          note: note,
          identifier: widget.identifier,
        );
        if (mounted) {
          _fetchDetail();
          widget.onChanged();
        }
      },
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
                      color: AppColors.textPrimary,
                    ),
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
                      KonsultasiInfoCard(item: _item),
                      Expanded(
                        child: KonsultasiChatThread(
                          messages: _messages,
                          mode: _item.mode,
                          scrollController: _scrollController,
                        ),
                      ),
                      if (_item.canChat) ...[
                        KonsultasiChatInputBar(
                          controller: _pesanController,
                          isSending: _isSending,
                          onSend: _sendMessage,
                          onTapField: () {
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                if (mounted) _scrollToBottom();
                              },
                            );
                          },
                        ),
                      ],
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
                                      color: Color(0xFFDC2626),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: _cancelKonsultasi,
                                  child: const Text(
                                    'Batalkan Konsultasi Ini',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(Icons.star_outline_rounded),
                                  label: Text(
                                    _item.feedbackRating != null
                                        ? 'Ubah Ulasan Sesi'
                                        : 'Beri Ulasan Bimbingan',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
