import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Toggle button untuk membalik kartu antara sisi depan dan belakang.
class KartuFlipToggle extends StatelessWidget {
  final bool isBackSide;
  final VoidCallback onToggleFront;
  final VoidCallback onToggleBack;

  const KartuFlipToggle({
    super.key,
    required this.isBackSide,
    required this.onToggleFront,
    required this.onToggleBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label: 'Tampilkan sisi depan kartu pelajar',
                selected: !isBackSide,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (isBackSide) {
                      onToggleFront();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !isBackSide ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: !isBackSide
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.credit_card_rounded,
                          size: 18,
                          color: !isBackSide
                              ? const Color(0xFF4338CA)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Sisi Depan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: !isBackSide
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: !isBackSide
                                  ? const Color(0xFF4338CA)
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Tampilkan sisi belakang ketentuan kartu pelajar',
                selected: isBackSide,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!isBackSide) {
                      onToggleBack();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isBackSide ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isBackSide
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flip_to_back_rounded,
                          size: 18,
                          color: isBackSide
                              ? const Color(0xFF4338CA)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Sisi Belakang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isBackSide
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isBackSide
                                  ? const Color(0xFF4338CA)
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

