import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../models/konsultasi_guru_wali_model.dart';
import '../../../services/guru_wali_service.dart';

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

  // =========================================================================
  // AKSI TIKET: JADWALKAN, TOLAK, KONVERSI KE JURNAL
  // =========================================================================

  Future<void> _dialogJadwalkan() async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    final catatanController = TextEditingController(text: 'Pertemuan tatap muka di ruang Guru Wali.');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text('Jadwalkan Tatap Muka', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Waktu Pertemuan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                          child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setDialogState(() => selectedTime = picked);
                            }
                          },
                          child: Text(selectedTime.format(ctx)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Pesan / Catatan untuk Murid:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: catatanController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Misal: Temui Bapak di ruang guru pada jam istirahat pertama...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Simpan Jadwal'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final combined = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      try {
        await widget.service.jadwalkanKonsultasi(
          konsultasiId: widget.konsultasiId,
          jadwalPasti: combined,
          tanggapan: catatanController.text.trim(),
        );
        _loadDetail();
        widget.onUpdated?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jadwal pertemuan tatap muka berhasil ditetapkan.'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menetapkan jadwal: $e'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _dialogTolak() async {
    final alasanController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text('Tolak Permohonan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alasan Penolakan *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: alasanController,
                maxLines: 3,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Jelaskan alasan penolakan bimbingan ini kepada murid...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              onPressed: () {
                if (alasanController.text.trim().length >= 3) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await widget.service.tolakKonsultasi(
          konsultasiId: widget.konsultasiId,
          alasanPenolakan: alasanController.text.trim(),
        );
        _loadDetail();
        widget.onUpdated?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permohonan konsultasi telah ditolak.'),
              backgroundColor: Color(0xFFE11D48),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menolak: $e'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _dialogKonversiJurnal() async {
    String statusSesi = 'Tuntas / Selesai';
    String rujukan = 'Mandiri';
    final rtlController = TextEditingController(text: 'Pemantauan berkala karakter dan kenyamanan belajar.');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.auto_stories_rounded, color: Color(0xFF16A34A)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('1-Klik Konversi ke Jurnal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Percakapan cerita ini akan langsung disalin menjadi Catatan Jurnal Bimbingan resmi.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Status Sesi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: statusSesi,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Tuntas / Selesai', child: Text('Tuntas / Selesai', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Dalam Pemantauan', child: Text('Dalam Pemantauan', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Bimbingan Lanjutan', child: Text('Bimbingan Lanjutan', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => statusSesi = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Rujukan Kolaborasi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: rujukan,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Mandiri', child: Text('Mandiri (Guru Wali)', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Wali Kelas', child: Text('Wali Kelas', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Guru BK', child: Text('Guru BK', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'Orang Tua / Wali', child: Text('Orang Tua / Wali', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => rujukan = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Rencana Tindak Lanjut:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: rtlController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Konversi Sekarang'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      try {
        await widget.service.konversiKonsultasiKeJurnal(
          konsultasiId: widget.konsultasiId,
          statusSesi: statusSesi,
          rujukanKolaborasi: rujukan,
          rencanaTindakLanjut: rtlController.text.trim(),
        );
        _loadDetail();
        widget.onUpdated?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konsultasi berhasil dikonversi menjadi Jurnal Bimbingan resmi!'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal konversi ke jurnal: $e'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // =========================================================================
  // BUILD UTAMA
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                          _buildTopicBanner(_item!),

                          // Area Percakapan Chat
                          Expanded(child: _buildChatList(_item!)),

                          // Input Text Bar di Bawah
                          _buildInputBar(_item!),
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
                if (val == 'jadwal') _dialogJadwalkan();
                if (val == 'konversi') _dialogKonversiJurnal();
                if (val == 'tolak') _dialogTolak();
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

  Widget _buildTopicBanner(KonsultasiGuruWaliItem item) {
    Color badgeColor = const Color(0xFFB45309);
    Color badgeBg = const Color(0xFFFEF3C7);
    if (item.statusPengajuan == 'Dijadwalkan') {
      badgeColor = const Color(0xFF1D4ED8);
      badgeBg = const Color(0xFFDBEAFE);
    } else if (item.statusPengajuan == 'Selesai' || item.statusPengajuan == 'Dikonversi ke Jurnal') {
      badgeColor = const Color(0xFF047857);
      badgeBg = const Color(0xFFD1FAE5);
    } else if (item.statusPengajuan == 'Ditolak') {
      badgeColor = const Color(0xFFB91C1C);
      badgeBg = const Color(0xFFFEE2E2);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  item.statusPengajuan,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
              Text(
                item.createdAtFormatted,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.topikKonsultasi,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          if (item.jadwalPastiFormatted != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event_available_rounded, size: 14, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                Text(
                  'Jadwal Tatap Muka: ${item.jadwalPastiFormatted}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatList(KonsultasiGuruWaliItem item) {
    // Gabungkan curhat awal siswa dengan pesan-pesan lanjutan
    final allMessages = <Widget>[];

    // Bubble pertama: Curhat pembuka dari permohonan bimbingan siswa
    allMessages.add(
      _buildMessageBubble(
        isMe: false,
        senderLabel: item.studentName,
        pesan: item.detailPermasalahan,
        timestamp: item.createdAtFormatted,
      ),
    );

    // Tanggapan guru jika ada
    if (item.tanggapanGuru != null && item.tanggapanGuru!.isNotEmpty) {
      allMessages.add(
        _buildMessageBubble(
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
        _buildMessageBubble(
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

  Widget _buildMessageBubble({
    required bool isMe,
    required String senderLabel,
    required String pesan,
    required String timestamp,
  }) {
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
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
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

  Widget _buildInputBar(KonsultasiGuruWaliItem item) {
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
                  controller: _pesanController,
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
                  onSubmitted: (_) => _kirimPesan(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFF2563EB),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _isSending ? null : _kirimPesan,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _isSending
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
