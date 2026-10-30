import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../models/pemantauan_bulanan_model.dart';
import '../../../services/guru_wali_service.dart';

/// Modal Bottomsheet untuk menampilkan Matriks Pemantauan 12 Bulan & 4 Pilar
/// Berdasarkan Kepatuhan Pendampingan Permendikdasmen No. 11/2025
class ModalPemantauanSheet extends StatefulWidget {
  final GuruWaliService service;

  const ModalPemantauanSheet({
    super.key,
    required this.service,
  });

  @override
  State<ModalPemantauanSheet> createState() => _ModalPemantauanSheetState();
}

class _ModalPemantauanSheetState extends State<ModalPemantauanSheet> {
  bool _isLoading = true;
  String? _errorMessage;
  PemantauanBulananResponse? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await widget.service.getPemantauan();
      if (mounted) {
        setState(() {
          _data = res;
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Color(0xFF0D9488), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matriks Pemantauan Progres',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Evaluasi 12 Bulan & 4 Pilar (Permen 11/2025)',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: SpinKitFadingCircle(color: Color(0xFF0D9488), size: 36),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 40),
                              const SizedBox(height: 10),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626)),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildContent(_data!),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PemantauanBulananResponse data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Ringkasan Total Sesi
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Seluruh Bimbingan',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.totalSeluruhSesi} Sesi Tercatat',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${data.matriksSiswa.length} Siswa Binaan',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Distribusi 4 Pilar Bimbingan
          const Text(
            'Distribusi 4 Pilar Bimbingan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          _buildPilarDistributionCard(data.distribusiPilar, data.totalSeluruhSesi),

          const SizedBox(height: 24),

          // Header Matriks Siswa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Matriks Pendampingan 12 Bulan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Juli – Juni',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Daftar Siswa Matriks
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.matriksSiswa.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final s = data.matriksSiswa[idx];
              return _buildMatriksSiswaCard(s, data.bulanHeaders);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPilarDistributionCard(Map<String, int> distribusi, int total) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: distribusi.entries.map((entry) {
          final pilarName = entry.key;
          final count = entry.value;
          final pct = total > 0 ? (count / total * 100).toInt() : 0;

          Color barColor = const Color(0xFF2563EB);
          if (pilarName.contains('Karakter')) barColor = const Color(0xFF10B981);
          if (pilarName.contains('Sosial')) barColor = const Color(0xFF8B5CF6);
          if (pilarName.contains('Minat')) barColor = const Color(0xFFF59E0B);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pilarName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                    Text(
                      '$count sesi ($pct%)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: barColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? (count / total) : 0,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMatriksSiswaCard(MatriksSiswaModel siswa, List<BulanHeaderItem> bulanHeaders) {
    final kepatuhanColor = siswa.kepatuhanPersen >= 80
        ? const Color(0xFF16A34A)
        : (siswa.kepatuhanPersen >= 50 ? const Color(0xFFD97706) : const Color(0xFFDC2626));

    return Container(
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
          // Nama & Persentase Kepatuhan
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siswa.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${siswa.kelasName} • NISN: ${siswa.nisn}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kepatuhanColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${siswa.kepatuhanPersen}% Kepatuhan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: kepatuhanColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Horizontal Bar Bulan (Juli–Juni)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: siswa.monthlyStatus.map((m) {
                final hasSession = m.hasBimbingan;
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasSession ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hasSession ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        m.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: hasSession ? const Color(0xFF166534) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        hasSession ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 12,
                        color: hasSession ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
