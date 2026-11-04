import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/spikap_models.dart';

/// Card tren laporan kasus perundungan 6 bulan terakhir
class SpikapAnalitikTrenBulananCard extends StatelessWidget {
  final SpikapAnalitikData data;

  const SpikapAnalitikTrenBulananCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
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
                  final barRatio = maxMonthly > 0
                      ? (m.total / maxMonthly).clamp(0.05, 1.0)
                      : 0.0;
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
                                      child: Container(
                                        color: const Color(0xFFDC2626),
                                      ),
                                    ),
                                  if (m.biasa > 0)
                                    Flexible(
                                      flex: (biasaRatio * 100).toInt(),
                                      child: Container(
                                        color: const Color(0xFF3B82F6),
                                      ),
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

