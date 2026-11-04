import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:apk_portal_smpn1_sampang/features/guru/models/konsultasi_guru_wali_model.dart';
import '../cards/konsultasi_cerita_card.dart';

/// Tab 3 Guru Wali: Ruang Aman Cerita (Daftar Konsultasi Siswa)
class TabRuangAmanCerita extends StatelessWidget {
  final bool isLoading;
  final List<KonsultasiGuruWaliItem> konsultasis;
  final String statusFilter;
  final ValueChanged<String> onStatusFilterChanged;
  final ValueChanged<String> onOpenChat;

  const TabRuangAmanCerita({
    super.key,
    required this.isLoading,
    required this.konsultasis,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: SpinKitThreeBounce(color: Color(0xFF2563EB), size: 28),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildKonsultasiFilterChip('semua', 'Semua Status'),
              _buildKonsultasiFilterChip('menunggu', 'Menunggu Respon'),
              _buildKonsultasiFilterChip('dijadwalkan', 'Dijadwalkan'),
              _buildKonsultasiFilterChip('selesai', 'Selesai'),
              _buildKonsultasiFilterChip('ditolak', 'Ditolak'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (konsultasis.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'Belum ada permohonan bimbingan/cerita dari siswa.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: konsultasis.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = konsultasis[index];
              return KonsultasiCeritaCard(
                item: item,
                onOpenChat: () => onOpenChat(item.id),
              );
            },
          ),
      ],
    );
  }

  Widget _buildKonsultasiFilterChip(String key, String label) {
    final isSelected = statusFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 10.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF2563EB),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF2563EB)
              : const Color(0xFFCBD5E1),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (val) => onStatusFilterChanged(key),
      ),
    );
  }
}

