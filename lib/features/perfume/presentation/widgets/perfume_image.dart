import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class PerfumeImage extends StatelessWidget {
  /// either a `data:image/...;base64,xxx…` URI or a normal http(s) URL
  final String? imageData;
  final double height;
  final BoxFit fit;
  final String placeholderAsset;

  const PerfumeImage({
    Key? key,
    required this.imageData,
    this.height = 120,
    this.fit = BoxFit.cover,
    this.placeholderAsset = 'assets/placeholder.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. No image at all? show local placeholder
    if (imageData == null || imageData!.isEmpty) {
      return Image.asset(
        placeholderAsset,
        height: height,
        fit: fit,
      );
    }

    // 2. Base64 data‑URI?
    if (imageData!.startsWith('data:image')) {
      // strip off “data:image/...;base64,”
      final base64Str = imageData!.split(',').last;
      Uint8List bytes;
      try {
        bytes = base64Decode(base64Str);
      } catch (_) {
        // on decode error, fall back
        return Image.asset(
          placeholderAsset,
          height: height,
          fit: fit,
        );
      }
      return Image.memory(
        bytes,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset(
          placeholderAsset,
          height: height,
          fit: fit,
        ),
      );
    }

    // 3. Otherwise treat it as a network URL
    return Image.network(
      imageData!,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Image.asset(
        placeholderAsset,
        height: height,
        fit: fit,
      ),
    );
  }
}
