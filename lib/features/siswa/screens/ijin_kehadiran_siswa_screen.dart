import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_ijin_model.dart';
import '../services/siswa_ijin_service.dart';
import 'form_ijin_siswa_screen.dart';

/// Layar Menu 2: Pengajuan Ijin Kehadiran Siswa
/// Menampilkan daftar riwayat pengajuan izin (pending, disetujui, ditolak),
/// filter status & kategori, detail bottom sheet dengan pratinjau lampiran foto,
/// pembatalan izin mandiri jika masih berstatus pending, serta tombol pengajuan izin baru.
class IjinKehadiranSiswaScreen extends StatefulWidget {
  final String identifier;
  final String studentName;
  final String schoolName;
  final String? token;
  final String? schoolLogoUrl;
  final String? schoolLogoBase64;

  final SiswaIjinListResponse? initialData;

  const IjinKehadiranSiswaScreen({
    super.key,
    required this.identifier,
    required this.studentName,
    this.schoolName = 'SMP Negeri 3 Kedungreja',
    this.token,
    this.schoolLogoUrl,
    this.schoolLogoBase64,
    this.initialData,
  });

  @override
  State<IjinKehadiranSiswaScreen> createState() => _IjinKehadiranSiswaScreenState();
}

class _IjinKehadiranSiswaScreenState extends State<IjinKehadiranSiswaScreen> {
  late SiswaIjinService _service;
  bool _isLoading = true;
  String? _errorMessage;
  SiswaIjinListResponse? _data;

  String _selectedStatus = 'all'; // all, pending, approved, rejected
  String _selectedType = 'all'; // all, ijin, sakit

  @override
  void initState() {
    super.initState();
    _service = SiswaIjinService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    if (widget.initialData != null) {
      _data = widget.initialData;
      _isLoading = false;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _service.getIjinList(
        status: _selectedStatus,
        type: _selectedType,
        identifier: widget.identifier,
      );

      if (mounted) {
        setState(() {
          _data = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCancel(SiswaIjinItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Batalkan Permohonan?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan permohonan ${item.typeLabel.toLowerCase()} pada rentang tanggal ${item.formattedRange}?',
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Tampilkan loading overlay
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sedang membatalkan permohonan...'),
          duration: Duration(seconds: 1),
        ),
      );

      try {
        await _service.cancelLeaveRequest(
          id: item.id,
          identifier: widget.identifier,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permohonan izin berhasil dibatalkan.'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    }
  }

  void _showDetailBottomSheet(SiswaIjinItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Permohonan ${item.typeLabel}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                      tooltip: 'Tutup',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Tipe Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: item.type == 'sakit' ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.type == 'sakit' ? Icons.medical_services_rounded : Icons.mail_rounded,
                                color: item.type == 'sakit' ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.typeLabel,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.durationDays} Hari (${item.formattedRange})',
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(item.status, item.statusLabel),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Info Rentang Tanggal
                      _buildInfoSection(
                        title: 'Jadwal & Waktu',
                        children: [
                          _buildDetailRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Tanggal Mulai',
                            value: item.formattedStartDate,
                          ),
                          const Divider(height: 16),
                          _buildDetailRow(
                            icon: Icons.event_available_rounded,
                            label: 'Tanggal Selesai',
                            value: item.formattedEndDate,
                          ),
                          const Divider(height: 16),
                          _buildDetailRow(
                            icon: Icons.timelapse_rounded,
                            label: 'Durasi Total',
                            value: '${item.durationDays} Hari',
                          ),
                          const Divider(height: 16),
                          _buildDetailRow(
                            icon: Icons.access_time_rounded,
                            label: 'Diajukan Pada',
                            value: item.formattedCreatedAt,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Alasan Izin
                      _buildInfoSection(
                        title: 'Alasan / Keterangan',
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              item.reason.isNotEmpty ? item.reason : 'Tidak ada keterangan tertulis.',
                              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Catatan Verifikasi Wali Kelas
                      if (item.status != 'pending') ...[
                        _buildInfoSection(
                          title: 'Verifikasi Wali Kelas / Guru',
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: item.status == 'approved' ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: item.status == 'approved' ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        item.status == 'approved' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                        size: 18,
                                        color: item.status == 'approved' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.status == 'approved' ? 'Disetujui' : 'Ditolak',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: item.status == 'approved' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                        ),
                                      ),
                                      if (item.approvedAt != null) ...[
                                        const Spacer(),
                                        Text(
                                          item.approvedAt!,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (item.verificationNote != null && item.verificationNote!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      item.verificationNote!,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                    ),
                                  ],
                                  if (item.approverName != null && item.approverName!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Petugas: ${item.approverName}',
                                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Pratinjau Lampiran Foto / Surat
                      _buildInfoSection(
                        title: 'Lampiran Berkas / Surat (${item.attachmentsCount})',
                        children: [
                          if (item.attachments.isEmpty)
                            const Text(
                              'Tidak ada lampiran berkas yang diunggah.',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                            )
                          else
                            ...item.attachments.map((att) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          att.isImage ? Icons.image_rounded : Icons.description_rounded,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            att.fileName.isNotEmpty ? att.fileName : 'Berkas Lampiran #${att.index + 1}',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (att.isImage && att.url.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: att.url,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                          placeholder: (context, url) => Container(
                                            height: 200,
                                            color: Colors.grey.shade100,
                                            child: const Center(child: CircularProgressIndicator()),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            height: 120,
                                            color: Colors.grey.shade100,
                                            child: const Center(
                                              child: Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Tombol Batalkan jika Cancellable
                      if (item.isCancellable) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFDC2626)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Batalkan Permohonan Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _handleCancel(item);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Tombol Tutup
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return MergeSemantics(
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color bg;
    Color fg;
    Color dotColor;
    IconData icon;

    switch (status) {
      case 'approved':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        dotColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFB91C1C);
        dotColor = const Color(0xFFEF4444);
        icon = Icons.cancel_rounded;
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFB45309);
        dotColor = const Color(0xFFF59E0B);
        icon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: dotColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengajuan Ijin Kehadiran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Row(
              children: [
                const Icon(Icons.school_rounded, size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  widget.schoolName,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Segarkan',
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'Ajukan Ijin',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.2),
          ),
          tooltip: 'Ajukan Permohonan Izin / Sakit Baru',
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (ctx) => FormIjinSiswaScreen(
                  identifier: widget.identifier,
                  studentName: widget.studentName,
                  schoolName: widget.schoolName,
                  token: widget.token,
                ),
              ),
            );

            if (result == true) {
              _loadData();
            }
          },
        ),
      ),
      body: _isLoading && _data == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _data == null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: Column(
                    children: [
                      // 1. Ringkasan Metrik 6 Kotak (Interactive Filter)
                      _buildSummaryMetrics(),

                      const SizedBox(height: 8),

                      // 2. Konten List Riwayat
                      Expanded(
                        child: _data!.items.isEmpty
                            ? _buildEmptyView()
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWideScreen = constraints.maxWidth >= 600;

                                  if (isWideScreen) {
                                    return GridView.builder(
                                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        childAspectRatio: 1.35,
                                      ),
                                      itemCount: _data!.items.length,
                                      itemBuilder: (context, index) {
                                        return _buildIjinCard(_data!.items[index]);
                                      },
                                    );
                                  }

                                  return ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: _data!.items.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                                    itemBuilder: (context, index) {
                                      return _buildIjinCard(_data!.items[index]);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryMetrics() {
    final counts = _data?.counts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          // Baris 1: Status Utama (3 kotak: Total, Menunggu, Disetujui)
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Total Izin',
                  count: counts?.total ?? 0,
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFF2563EB),
                  bg: const Color(0xFFEFF6FF),
                  isSelected: _selectedStatus == 'all' && _selectedType == 'all',
                  onTap: () {
                    if (_selectedStatus != 'all' || _selectedType != 'all') {
                      setState(() {
                        _selectedStatus = 'all';
                        _selectedType = 'all';
                      });
                      _loadData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Menunggu',
                  count: counts?.pending ?? 0,
                  icon: Icons.hourglass_top_rounded,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFFFBEB),
                  isSelected: _selectedStatus == 'pending' && _selectedType == 'all',
                  onTap: () {
                    if (_selectedStatus != 'pending' || _selectedType != 'all') {
                      setState(() {
                        _selectedStatus = 'pending';
                        _selectedType = 'all';
                      });
                      _loadData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Disetujui',
                  count: counts?.approved ?? 0,
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFECFDF5),
                  isSelected: _selectedStatus == 'approved' && _selectedType == 'all',
                  onTap: () {
                    if (_selectedStatus != 'approved' || _selectedType != 'all') {
                      setState(() {
                        _selectedStatus = 'approved';
                        _selectedType = 'all';
                      });
                      _loadData();
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Baris 2: Ditolak & Kategori (3 kotak: Ditolak, Sakit, Izin)
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Ditolak',
                  count: counts?.rejected ?? 0,
                  icon: Icons.cancel_outlined,
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFEF2F2),
                  isSelected: _selectedStatus == 'rejected' && _selectedType == 'all',
                  onTap: () {
                    if (_selectedStatus != 'rejected' || _selectedType != 'all') {
                      setState(() {
                        _selectedStatus = 'rejected';
                        _selectedType = 'all';
                      });
                      _loadData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Sakit',
                  count: counts?.sakit ?? 0,
                  icon: Icons.medical_services_outlined,
                  color: const Color(0xFF0284C7),
                  bg: const Color(0xFFF0F9FF),
                  isSelected: _selectedType == 'sakit',
                  onTap: () {
                    if (_selectedType != 'sakit') {
                      setState(() {
                        _selectedStatus = 'all';
                        _selectedType = 'sakit';
                      });
                      _loadData();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricItem(
                  title: 'Izin',
                  count: counts?.ijin ?? 0,
                  icon: Icons.mail_outline_rounded,
                  color: const Color(0xFF7C3AED),
                  bg: const Color(0xFFF5F3FF),
                  isSelected: _selectedType == 'ijin',
                  onTap: () {
                    if (_selectedType != 'ijin') {
                      setState(() {
                        _selectedStatus = 'all';
                        _selectedType = 'ijin';
                      });
                      _loadData();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? bg.withValues(alpha: 0.5) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? bg.withValues(alpha: 0.4) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? color.withValues(alpha: 0.14) : const Color(0xFF1E293B).withValues(alpha: 0.03),
                blurRadius: isSelected ? 6 : 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIjinCard(SiswaIjinItem item) {
    final isSakit = item.type == 'sakit';
    final accentColor = isSakit ? const Color(0xFF2563EB) : const Color(0xFF7C3AED);
    final accentBg = isSakit ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetailBottomSheet(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top: Kategori Icon + Title + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: accentBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accentColor.withValues(alpha: 0.15)),
                            ),
                            child: Icon(
                              isSakit ? Icons.medical_services_rounded : Icons.mail_rounded,
                              size: 18,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.typeLabel,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Diajukan ${item.formattedCreatedAt}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(item.status, item.statusLabel),
                  ],
                ),

                const SizedBox(height: 14),

                // Tanggal & Durasi Capsule Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.formattedRange,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timelapse_rounded, size: 12, color: Color(0xFF1D4ED8)),
                            const SizedBox(width: 4),
                            Text(
                              '${item.durationDays} Hari',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Alasan dalam quote box halus
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote_rounded, size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.reason.isNotEmpty ? item.reason : 'Tidak ada alasan tertulis',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                const SizedBox(height: 12),

                // Footer: Lampiran info & Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.hasAttachments)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.attach_file_rounded, size: 14, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Text(
                              '${item.attachmentsCount} Lampiran',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            ),
                          ],
                        ),
                      )
                    else
                      const Row(
                        children: [
                          Icon(Icons.attachment_outlined, size: 14, color: Color(0xFF94A3B8)),
                          SizedBox(width: 4),
                          Text(
                            'Tanpa lampiran',
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),

                    Row(
                      children: [
                        if (item.isCancellable) ...[
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFEF2F2),
                              foregroundColor: const Color(0xFFDC2626),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 14),
                            label: const Text('Batalkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () => _handleCancel(item),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                size: 60,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Pengajuan Izin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anda belum memiliki riwayat pengajuan izin atau sakit untuk kategori ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Buat Pengajuan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => FormIjinSiswaScreen(
                      identifier: widget.identifier,
                      studentName: widget.studentName,
                      schoolName: widget.schoolName,
                      token: widget.token,
                    ),
                  ),
                );

                if (result == true) {
                  _loadData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: Color(0xFFDC2626)),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Riwayat Izin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan sistem.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              onPressed: _loadData,
            ),
          ],
        ),
      ),
    );
  }
}
