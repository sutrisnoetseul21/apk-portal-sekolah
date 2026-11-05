import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:apk_portal_smpn1_sampang/core/constants/app_colors.dart';

/// Header logo & identitas sekolah pada halaman login
class LoginHeaderSection extends StatelessWidget {
  final String schoolName;
  final Uint8List? logoBytes;
  final String? logoUrl;

  const LoginHeaderSection({
    super.key,
    required this.schoolName,
    this.logoBytes,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Container Logo Aplikasi
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildLogoWidget(),
          ),
          const SizedBox(height: 16),

          // Baris 1: Portal Digital
          const Text(
            'Portal Digital',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          // Baris 2: Nama Sekolahan Dinamis dari Database
          Text(
            schoolName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoWidget() {
    if (logoBytes != null) {
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.memory(
          logoBytes!,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _buildFallbackIcon(),
        ),
      );
    }

    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.network(
          logoUrl!,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _buildFallbackIcon(),
        ),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Image.asset(
        'assets/images/logo_sekolah.png',
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(
              Icons.school_rounded,
              size: 44,
              color: Colors.white,
              semanticLabel: 'Logo Sekolah',
            ),
          ),
        ),
      ),
    );
  }
}
