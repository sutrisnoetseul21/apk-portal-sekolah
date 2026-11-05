import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class IjinLeaveDetailsCard extends StatelessWidget {
  final Map<String, dynamic> leave;

  const IjinLeaveDetailsCard({super.key, required this.leave});

  @override
  Widget build(BuildContext context) {
    final isSakit = leave['type']?.toString() == 'sakit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: Text(
            'Rincian Izin / Sakit',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow(
                'Jenis Permohonan',
                isSakit ? 'Sakit' : 'Izin',
                valueColor: isSakit ? const Color(0xFFE11D48) : const Color(0xFF16A34A),
              ),
              _buildRow(
                'Tanggal Mulai',
                leave['start_date_formatted']?.toString() ?? '-',
              ),
              _buildRow(
                'Tanggal Selesai',
                leave['end_date_formatted']?.toString() ?? '-',
              ),
              _buildRow(
                'Durasi Hari',
                leave['duration_label']?.toString() ?? '-',
              ),
              _buildRow(
                'Status Saat Ini',
                leave['status_label']?.toString() ?? '-',
              ),
              const SizedBox(height: 8),
              const Text(
                'Alasan / Keterangan:',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  leave['reason']?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
