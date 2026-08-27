import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildPlatformNetworkImage({
  required String imageUrl,
  required BoxFit fit,
  required Widget placeholder,
  ColorFilter? colorFilter,
  double? width,
  double? height,
}) {
  final isSvg = imageUrl.toLowerCase().contains('.svg') ||
      imageUrl.toLowerCase().split('?').first.endsWith('.svg');

  if (isSvg) {
    return SvgPicture.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      colorFilter: colorFilter,
      placeholderBuilder: (context) => placeholder,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  } else {
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      color: colorFilter != null ? Colors.transparent : null, // standard image doesn't support colorFilter directly the same way, but can use color + colorBlendMode if needed
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
