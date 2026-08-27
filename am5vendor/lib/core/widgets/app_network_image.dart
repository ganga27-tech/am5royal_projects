import 'package:flutter/material.dart';
import 'app_network_image_stub.dart'
    if (dart.library.html) 'app_network_image_web.dart' as platform_image;

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget placeholder;
  final ColorFilter? colorFilter;
  final double? width;
  final double? height;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    required this.placeholder,
    this.colorFilter,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return platform_image.buildPlatformNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: placeholder,
      colorFilter: colorFilter,
      width: width,
      height: height,
    );
  }
}
