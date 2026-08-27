// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildPlatformNetworkImage({
  required String imageUrl,
  required BoxFit fit,
  required Widget placeholder,
  ColorFilter? colorFilter,
  double? width,
  double? height,
}) {
  // Use a unique view type for each URL to avoid ID collisions and state reuse issues.
  final String viewType = 'app-img-${imageUrl.hashCode}';

  try {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final img = html.ImageElement()
        ..src = imageUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.pointerEvents = 'none'; // Allows clicks/gestures to pass through to Flutter

      if (fit == BoxFit.cover) {
        img.style.objectFit = 'cover';
      } else if (fit == BoxFit.contain) {
        img.style.objectFit = 'contain';
      } else if (fit == BoxFit.fill) {
        img.style.objectFit = 'fill';
      } else {
        img.style.objectFit = 'cover';
      }

      return img;
    });
  } catch (_) {
    // Already registered for this URL, safe to ignore
  }

  return SizedBox(
    width: width ?? double.infinity,
    height: height ?? double.infinity,
    child: HtmlElementView(viewType: viewType),
  );
}
