import 'package:flutter/material.dart';

class JurnalIndividuBadgeCard extends StatelessWidget {
  final bool giveBadge;
  final ValueChanged<bool> onToggleBadge;
  final String selectedBadge;
  final List<String> badgeOptions;
  final ValueChanged<String> onSelectBadge;
  final TextEditingController catatanApresiasiController;

  const JurnalIndividuBadgeCard({
    super.key,
    required this.giveBadge,
    required this.onToggleBadge,
    required this.selectedBadge,
    required this.badgeOptions,
    required this.onSelectBadge,
    required this.catatanApresiasiController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withValues(alpha: 0.35),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Apresiasi Digital Badge Karakter',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
              Switch(
                value: giveBadge,
                activeThumbColor: const Color(0xFFD97706),
                onChanged: onToggleBadge,
              ),
            ],
          ),
          if (giveBadge) ...[
            const SizedBox(height: 12),
            const Text(
              'Pilih Karakter Terpuji:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: badgeOptions.map((b) {
                final isSelected = selectedBadge == b;
                return ChoiceChip(
                  label: Text(
                    b,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : const Color(0xFF78350F),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFD97706),
                  backgroundColor: Colors.white,
                  onSelected: (_) => onSelectBadge(b),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: catatanApresiasiController,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Pesan apresiasi penyemangat siswa...',
                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFFDE68A)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
