import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';

/// Widget Reusable Logo Sekolah yang mendukung Base64, Network Image, Asset Lokal,
/// dan Fallback Ikon Elegan.
class SchoolLogoWidget extends StatelessWidget {
  final double size;
  final String? logoUrl;
  final String? logoBase64;
  final Uint8List? logoBytes;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color backgroundColor;

  const SchoolLogoWidget({
    super.key,
    this.size = 36.0,
    this.logoUrl,
    this.logoBase64,
    this.logoBytes,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.0,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List? resolvedBytes = logoBytes;
    if (resolvedBytes == null && logoBase64 != null && logoBase64!.isNotEmpty) {
      try {
        final clean = logoBase64!.contains(',')
            ? logoBase64!.split(',').last
            : logoBase64!;
        resolvedBytes = base64Decode(clean);
      } catch (_) {}
    }

    Widget content;
    if (resolvedBytes != null) {
      content = Image.memory(
        resolvedBytes,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    } else if (logoUrl != null && logoUrl!.isNotEmpty) {
      content = CachedNetworkImage(
        imageUrl: logoUrl!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (_, __) => Center(
          child: SizedBox(
            width: size * 0.4,
            height: size * 0.4,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    } else {
      content = _buildFallback();
    }

    final isCircle = shape == BoxShape.circle;
    final decoration = BoxDecoration(
      color: backgroundColor,
      shape: shape,
      borderRadius: isCircle ? null : (borderRadius ?? BorderRadius.circular(8)),
      border: borderColor != null
          ? Border.all(color: borderColor!, width: borderWidth)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      child: isCircle
          ? ClipOval(child: Padding(padding: EdgeInsets.all(size * 0.08), child: content))
          : ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              child: Padding(padding: EdgeInsets.all(size * 0.08), child: content),
            ),
    );
  }

  Widget _buildFallback() {
    return Image.asset(
      'assets/images/logo_sekolah.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.school_rounded,
        size: size * 0.6,
        color: AppColors.primary,
      ),
    );
  }
}

