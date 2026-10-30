import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/spikap_models.dart';
import '../services/spikap_service.dart';

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
          _buildPeriodeSelector(),
          const SizedBox(height: 16),

          // Metrik Ringkasan Utama
          _buildMetrikCards(data),
          const SizedBox(height: 16),

          // Progress Penyelesaian Kasus
          _buildPenyelesaianCard(data),
          const SizedBox(height: 16),

          // Sebaran Kategori Perundungan
          _buildKategoriCard(data),
          const SizedBox(height: 16),

          // Tren Kasus 6 Bulan Terakhir
          _buildTrenBulananCard(data),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPeriodeSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.date_range_rounded,
            size: 18,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Text(
            'Periode: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periodeOptions.map((opt) {
                  final isSelected = opt['key'] == _selectedPeriode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(opt['label']!),
                      selected: isSelected,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFF1F5F9),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                      onSelected: (selected) {
                        if (selected && _selectedPeriode != opt['key']) {
                          setState(() {
                            _selectedPeriode = opt['key']!;
                          });
                          _loadAnalitik();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrikCards(SpikapAnalitikData data) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _buildMetricItem(
          label: 'Total Laporan',
          value: data.totalLaporan.toString(),
          icon: Icons.assignment_outlined,
          color: const Color(0xFF0284C7),
          bgColor: const Color(0xFFE0F2FE),
        ),
        _buildMetricItem(
          label: '🚨 Kasus Darurat',
          value: data.totalDarurat.toString(),
          icon: Icons.warning_rounded,
          color: const Color(0xFFDC2626),
          bgColor: const Color(0xFFFEE2E2),
        ),
        _buildMetricItem(
          label: 'Sedang Diproses',
          value: data.totalProses.toString(),
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
        ),
        _buildMetricItem(
          label: 'Selesai Ditangani',
          value: data.totalSelesai.toString(),
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF059669),
          bgColor: const Color(0xFFD1FAE5),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenyelesaianCard(SpikapAnalitikData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tingkat Penyelesaian Kasus',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                '${data.persenSelesai}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: data.totalLaporan > 0
                  ? (data.totalSelesai / data.totalLaporan).clamp(0.0, 1.0)
                  : 0.0,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.totalSelesai} dari ${data.totalLaporan} laporan telah tuntas dan ditutup.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriCard(SpikapAnalitikData data) {
    final colors = {
      'fisik': const Color(0xFFDC2626),
      'verbal': const Color(0xFFD97706),
      'sosial': const Color(0xFF2563EB),
      'digital': const Color(0xFF7C3AED),
      'lainnya': const Color(0xFF64748B),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pie_chart_outline_rounded,
                size: 16,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Text(
                'Sebaran Kategori Perundungan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (data.kategoriStats.isEmpty || data.totalLaporan == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Belum ada data kasus pada periode ini.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            ...data.kategoriStats.map((item) {
              final color = colors[item.key] ?? const Color(0xFF64748B);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${item.count} kasus (${item.percentage}%)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (item.percentage / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTrenBulananCard(SpikapAnalitikData data) {
    final maxMonthly = data.monthlyTrend.fold<int>(
      0,
      (prev, element) => element.total > prev ? element.total : prev,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                size: 16,
                color: Color(0xFF059669),
              ),
              const SizedBox(width: 8),
              Text(
                'Tren Laporan (6 Bulan Terakhir)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (data.monthlyTrend.isEmpty || maxMonthly == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Belum ada data tren bulanan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                ...data.monthlyTrend.map((m) {
                  final barRatio = maxMonthly > 0 ? (m.total / maxMonthly).clamp(0.05, 1.0) : 0.0;
                  final daruratRatio = m.total > 0 ? (m.darurat / m.total) : 0.0;
                  final biasaRatio = m.total > 0 ? (m.biasa / m.total) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              m.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            Row(
                              children: [
                                if (m.darurat > 0) ...[
                                  Text(
                                    '🚨 ${m.darurat}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  'Total: ${m.total} Kasus',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Proportional Stacked Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            height: 10,
                            width: double.infinity,
                            color: const Color(0xFFF1F5F9),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: barRatio,
                              child: Row(
                                children: [
                                  if (m.darurat > 0)
                                    Flexible(
                                      flex: (daruratRatio * 100).toInt(),
                                      child: Container(color: const Color(0xFFDC2626)),
                                    ),
                                  if (m.biasa > 0)
                                    Flexible(
                                      flex: (biasaRatio * 100).toInt(),
                                      child: Container(color: const Color(0xFF3B82F6)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Darurat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Biasa',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

