import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

class IjinDetailBottomActionBar extends StatelessWidget {
  final bool isActionProcessing;
  final bool isPending;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onReset;

  const IjinDetailBottomActionBar({
    super.key,
    required this.isActionProcessing,
    required this.isPending,
    required this.onApprove,
    required this.onReject,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        Container(
          padding: const EdgeInsets.all(14),
          color: Colors.white,
          child: isActionProcessing
              ? const Center(
                  child: SpinKitThreeBounce(color: AppColors.primary, size: 24),
                )
              : Row(
                  children: [
                    if (isPending) ...[
                      // Tombol Tolak
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: onReject,
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text(
                            'Tolak',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Tombol Setujui
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: onApprove,
                          icon: const Icon(Icons.check_circle_rounded, size: 16),
                          label: const Text(
                            'Setujui Permohonan',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Status sudah approved / rejected -> Tampilkan opsi Reset ke Pending
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF475569),
                            side: const BorderSide(color: Color(0xFF94A3B8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: onReset,
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: const Text(
                            'Kembalikan ke Status Menunggu (Reset)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
