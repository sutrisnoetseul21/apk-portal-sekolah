import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/spikap_models.dart';
import '../services/spikap_service.dart';
import 'widgets/spikap_analitik/sections/spikap_analitik_periode_selector.dart';
import 'widgets/spikap_analitik/sections/spikap_analitik_metrik_cards.dart';
import 'widgets/spikap_analitik/sections/spikap_analitik_penyelesaian_card.dart';
import 'widgets/spikap_analitik/sections/spikap_analitik_kategori_card.dart';
import 'widgets/spikap_analitik/sections/spikap_analitik_tren_bulanan_card.dart';

/// Halaman Dasbor Analitik Kasus SPIKAP
/// Khusus diperuntukkan bagi Kepala Sekolah dan Guru BK
class SpikapAnalitikScreen extends StatefulWidget {
  final String teacherName;
  final String? token;
  final String? identifier;
  final String schoolName;
  final String roleLabel;

  const SpikapAnalitikScreen({
    super.key,
    required this.teacherName,
    this.token,
    this.identifier,
    required this.schoolName,
    required this.roleLabel,
  });

  @override
  State<SpikapAnalitikScreen> createState() => _SpikapAnalitikScreenState();
}

class _SpikapAnalitikScreenState extends State<SpikapAnalitikScreen> {
  late final SpikapService _spikapService;

  bool _isLoading = true;
  String? _errorMessage;
  SpikapAnalitikData? _analitikData;
  String _selectedPeriode = '1_tahun';

  final List<Map<String, String>> _periodeOptions = [
    {'key': '30_hari', 'label': '30 Hari'},
    {'key': '3_bulan', 'label': '3 Bulan'},
    {'key': '6_bulan', 'label': '6 Bulan'},
    {'key': '1_tahun', 'label': '1 Tahun'},
  ];

  @override
  void initState() {
    super.initState();
    _spikapService = SpikapService.create(
      token: widget.token,
      identifier: widget.identifier,
    );
    _loadAnalitik();
  }

  Future<void> _loadAnalitik() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _spikapService.getAnalitik(periode: _selectedPeriode);
      if (mounted) {
        setState(() {
          _analitikData = data;
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal Memuat Analitik',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadAnalitik,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _analitikData!;

    return RefreshIndicator(
      onRefresh: _loadAnalitik,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Periode Selector
          SpikapAnalitikPeriodeSelector(
            selectedPeriode: _selectedPeriode,
            periodeOptions: _periodeOptions,
            onPeriodeChanged: (key) {
              setState(() => _selectedPeriode = key);
              _loadAnalitik();
            },
          ),
          const SizedBox(height: 16),

          // Metrik Ringkasan Utama
          SpikapAnalitikMetrikCards(data: data),
          const SizedBox(height: 16),

          // Progress Penyelesaian Kasus
          SpikapAnalitikPenyelesaianCard(data: data),
          const SizedBox(height: 16),

          // Sebaran Kategori Perundungan
          SpikapAnalitikKategoriCard(data: data),
          const SizedBox(height: 16),

          // Tren Kasus 6 Bulan Terakhir
          SpikapAnalitikTrenBulananCard(data: data),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dasbor Analitik SPIKAP',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.schoolName} • ${widget.roleLabel}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: _loadAnalitik,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
