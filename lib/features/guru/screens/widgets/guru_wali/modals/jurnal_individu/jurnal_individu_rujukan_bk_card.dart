import 'package:flutter/material.dart';

class JurnalIndividuRujukanBkCard extends StatelessWidget {
  final bool rujukBk;
  final ValueChanged<bool> onToggleRujukBk;
  final String urgensiBk;
  final ValueChanged<String> onSelectUrgensi;
  final TextEditingController alasanBkController;

  const JurnalIndividuRujukanBkCard({
    super.key,
    required this.rujukBk,
    required this.onToggleRujukBk,
    required this.urgensiBk,
    required this.onSelectUrgensi,
    required this.alasanBkController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: rujukBk
            ? const Color(0xFFFEE2E2).withValues(alpha: 0.5)
            : const Color(0xFFF8FAFC),
        border: Border.all(
          color: rujukBk ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                color: rujukBk ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Eskalasi ke Guru BK (Kasus Khusus)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: rujukBk ? const Color(0xFF991B1B) : const Color(0xFF334155),
                  ),
                ),
              ),
              Switch(
                value: rujukBk,
                activeThumbColor: const Color(0xFFDC2626),
                onChanged: onToggleRujukBk,
              ),
            ],
          ),
          if (rujukBk) ...[
            const SizedBox(height: 10),
            const Text(
              'Tingkat Urgensi:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Rendah', style: TextStyle(fontSize: 11)),
                  selected: urgensiBk == 'rendah',
                  onSelected: (_) => onSelectUrgensi('rendah'),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Sedang', style: TextStyle(fontSize: 11)),
                  selected: urgensiBk == 'sedang',
                  onSelected: (_) => onSelectUrgensi('sedang'),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Darurat', style: TextStyle(fontSize: 11, color: Colors.white)),
                  selected: urgensiBk == 'darurat',
                  selectedColor: const Color(0xFFDC2626),
                  onSelected: (_) => onSelectUrgensi('darurat'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: alasanBkController,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Alasan dan latar belakang rujukan ke BK...',
                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
