import 'dart:io';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    var trimmed = imageUrl.trim();
    if (trimmed.contains('|')) {
      final parts = trimmed.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty);
      trimmed = parts.isNotEmpty ? parts.first : '';
    }

    final defaultPlaceholder = placeholder ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFF7F4EF),
          alignment: Alignment.center,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: AppTheme.primaryGold,
            size: (width != null && width! < 60) ? 22 : 36,
          ),
        );

    if (trimmed.isEmpty) {
      imageWidget = defaultPlaceholder;
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      imageWidget = Image.network(
        trimmed,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => defaultPlaceholder,
      );
    } else if (trimmed.startsWith('assets/')) {
      imageWidget = Image.asset(
        trimmed,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => defaultPlaceholder,
      );
    } else {
      final file = File(trimmed);
      imageWidget = Image.file(
        file,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => defaultPlaceholder,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
