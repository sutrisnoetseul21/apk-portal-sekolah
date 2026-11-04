import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../models/siswa_ijin_model.dart';
import '../services/siswa_ijin_service.dart';
import 'form_ijin_siswa_screen.dart';
import 'widgets/ijin/cards/ijin_siswa_card.dart';
import 'widgets/ijin/modals/sheet_detail_ijin_siswa.dart';
import 'widgets/ijin/sections/ijin_siswa_summary_metrics.dart';

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
    this.schoolName = '',
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

  void _showDetail(SiswaIjinItem item) {
    SheetDetailIjinSiswa.show(
      context,
      item: item,
      onCancel: _handleCancel,
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
                  widget.schoolName.isNotEmpty ? widget.schoolName : AppConfig.appName,
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
                      IjinSiswaSummaryMetrics(
                        counts: _data?.counts,
                        selectedStatus: _selectedStatus,
                        selectedType: _selectedType,
                        onFilterChanged: (status, type) {
                          setState(() {
                            _selectedStatus = status;
                            _selectedType = type;
                          });
                          _loadData();
                        },
                      ),

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
                                        final item = _data!.items[index];
                                        return IjinSiswaCard(
                                          item: item,
                                          onTap: () => _showDetail(item),
                                          onCancel: () => _handleCancel(item),
                                        );
                                      },
                                    );
                                  }

                                  return ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: _data!.items.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                                    itemBuilder: (context, index) {
                                      final item = _data!.items[index];
                                      return IjinSiswaCard(
                                        item: item,
                                        onTap: () => _showDetail(item),
                                        onCancel: () => _handleCancel(item),
                                      );
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
