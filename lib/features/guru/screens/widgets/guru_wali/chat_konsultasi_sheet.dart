import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:apk_portal_smpn1_sampang/core/widgets/keyboard_aware_sheet.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/konsultasi_guru_wali_model.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/services/guru_wali_service.dart';
import 'chat/chat_action_dialogs.dart';
import 'chat/chat_input_bar.dart';
import 'chat/chat_message_bubble.dart';
import 'chat/chat_topic_banner.dart';

/// Bottomsheet interaktif Ruang Aman Cerita (Chat dua arah Siswa & Guru Wali)
/// Dilengkapi realtime short-polling, aksi Jadwalkan Tatap Muka,
/// Tolak Permohonan, dan 1-Klik Konversi ke Jurnal Bimbingan.
class ChatKonsultasiSheet extends StatefulWidget {
  final String konsultasiId;
  final GuruWaliService service;
  final VoidCallback? onUpdated;

  const ChatKonsultasiSheet({
    super.key,
    required this.konsultasiId,
    required this.service,
    this.onUpdated,
  });

  @override
  State<ChatKonsultasiSheet> createState() => _ChatKonsultasiSheetState();
}

class _ChatKonsultasiSheetState extends State<ChatKonsultasiSheet> {
  bool _isLoading = true;
  String? _errorMessage;
  KonsultasiGuruWaliItem? _item;

  Timer? _pollTimer;
  final TextEditingController _pesanController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    // Realtime short-polling setiap 5 detik untuk cek pesan baru dari siswa
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && !_isSending) {
        _pollNewMessages();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pesanController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await widget.service.getKonsultasiDetail(widget.konsultasiId);
      if (mounted) {
        setState(() {
          _item = res;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pollNewMessages() async {
    try {
      final res = await widget.service.getKonsultasiDetail(widget.konsultasiId);
      if (mounted) {
        final currentCount = _item?.messages.length ?? 0;
        final newCount = res.messages.length;
        if (newCount > currentCount || res.statusPengajuan != _item?.statusPengajuan) {
          setState(() => _item = res);
          _scrollToBottom();
        }
      }
    } catch (_) {}
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

  Future<void> _kirimPesan() async {
    final text = _pesanController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _pesanController.clear();

    try {
      final newMsg = await widget.service.kirimPesanKonsultasi(
        konsultasiId: widget.konsultasiId,
        pesan: text,
      );

      if (mounted) {
        setState(() {
          _isSending = false;
          if (_item != null) {
            _item = KonsultasiGuruWaliItem(
              id: _item!.id,
              studentId: _item!.studentId,
              studentName: _item!.studentName,
              studentNisn: _item!.studentNisn,
              studentAvatar: _item!.studentAvatar,
              kelasName: _item!.kelasName,
              kategoriPendampingan: _item!.kategoriPendampingan,
              topikKonsultasi: _item!.topikKonsultasi,
              detailPermasalahan: _item!.detailPermasalahan,
              modeKonsultasi: _item!.modeKonsultasi,
              statusPengajuan: _item!.statusPengajuan,
              usulanTanggalWaktu: _item!.usulanTanggalWaktu,
              jadwalPasti: _item!.jadwalPasti,
              jadwalPastiFormatted: _item!.jadwalPastiFormatted,
              tanggapanGuru: _item!.tanggapanGuru,
              alasanPenolakan: _item!.alasanPenolakan,
              createdAt: _item!.createdAt,
              createdAtFormatted: _item!.createdAtFormatted,
              unreadMessagesCount: 0,
              totalMessagesCount: _item!.totalMessagesCount + 1,
              lastMessage: PesanSingkatModel(
                pesan: newMsg.pesan,
                senderType: 'guru',
                createdAtFormatted: newMsg.createdAtFormatted,
              ),
              isDikonversi: _item!.isDikonversi,
              jurnalId: _item!.jurnalId,
              messages: [..._item!.messages, newMsg],
            );
          }
        });
        _scrollToBottom();
        widget.onUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pesan: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleJadwalkan() async {
    final success = await ChatActionDialogs.showJadwalkanDialog(
      context: context,
      service: widget.service,
      konsultasiId: widget.konsultasiId,
    );
    if (success && mounted) {
      _loadDetail();
      widget.onUpdated?.call();
    }
  }

  Future<void> _handleTolak() async {
    final success = await ChatActionDialogs.showTolakDialog(
      context: context,
      service: widget.service,
      konsultasiId: widget.konsultasiId,
    );
    if (success && mounted) {
      _loadDetail();
      widget.onUpdated?.call();
    }
  }

  Future<void> _handleKonversiJurnal() async {
    final success = await ChatActionDialogs.showKonversiJurnalDialog(
      context: context,
      service: widget.service,
      konsultasiId: widget.konsultasiId,
    );
    if (success && mounted) {
      _loadDetail();
      widget.onUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardAwareSheet(
      backgroundColor: const Color(0xFFF8FAFC),
      maxHeightFactor: 0.92,
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Bar
          _buildHeader(),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(child: SpinKitFadingCircle(color: Color(0xFF2563EB), size: 36))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 36),
                              const SizedBox(height: 8),
                              Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: _loadDetail, child: const Text('Coba Lagi')),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // Kartu Rincian Topik Konsultasi (Pinned Top)
                          ChatTopicBanner(item: _item!),

                          // Area Percakapan Chat
                          Expanded(child: _buildChatList(_item!)),

                          // Input Text Bar di Bawah
                          ChatInputBar(
                            item: _item!,
                            controller: _pesanController,
                            isSending: _isSending,
                            onSend: _kirimPesan,
                            onTapInput: () {
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (mounted) _scrollToBottom();
                              });
                            },
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
            backgroundImage: _item?.studentAvatar != null ? NetworkImage(_item!.studentAvatar!) : null,
            child: _item?.studentAvatar == null
                ? Text(
                    _item != null && _item!.studentName.isNotEmpty ? _item!.studentName[0].toUpperCase() : 'S',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _item?.studentName ?? 'Ruang Aman Cerita',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _item != null
                      ? '${_item!.kelasName} • Mode: ${_item!.modeKonsultasi}'
                      : 'Memuat data percakapan...',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Menu Aksi Tiket
          if (_item != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (val) {
                if (val == 'jadwal') _handleJadwalkan();
                if (val == 'konversi') _handleKonversiJurnal();
                if (val == 'tolak') _handleTolak();
                if (val == 'refresh') _loadDetail();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'jadwal',
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text('Jadwalkan Tatap Muka', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                if (!_item!.isDikonversi)
                  const PopupMenuItem(
                    value: 'konversi',
                    child: Row(
                      children: [
                        Icon(Icons.auto_stories_rounded, size: 16, color: Color(0xFF16A34A)),
                        SizedBox(width: 8),
                        Text('1-Klik Konversi ke Jurnal', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                if (_item!.statusPengajuan == 'Menunggu Konfirmasi')
                  const PopupMenuItem(
                    value: 'tolak',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFDC2626)),
                        SizedBox(width: 8),
                        Text('Tolak Permohonan', style: TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF64748B)),
                      SizedBox(width: 8),
                      Text('Segarkan Pesan', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),

          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(KonsultasiGuruWaliItem item) {
    final allMessages = <Widget>[];

    // Bubble pertama: Curhat pembuka dari permohonan bimbingan siswa
    allMessages.add(
      ChatMessageBubble(
        isMe: false,
        senderLabel: item.studentName,
        pesan: item.detailPermasalahan,
        timestamp: item.createdAtFormatted,
      ),
    );

    // Tanggapan guru jika ada
    if (item.tanggapanGuru != null && item.tanggapanGuru!.isNotEmpty) {
      allMessages.add(
        ChatMessageBubble(
          isMe: true,
          senderLabel: 'Guru Wali',
          pesan: item.tanggapanGuru!,
          timestamp: item.jadwalPastiFormatted ?? item.createdAtFormatted,
        ),
      );
    }

    // Pesan-pesan obrolan lanjutan
    for (final m in item.messages) {
      allMessages.add(
        ChatMessageBubble(
          isMe: m.isMe,
          senderLabel: m.isMe ? 'Guru Wali' : item.studentName,
          pesan: m.pesan,
          timestamp: m.createdAtFormatted,
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      children: allMessages,
    );
  }
}
