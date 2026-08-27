import 'package:flutter/material.dart';

/// A utility layout widget that serves as a centralized source of truth
/// for breakpoints and screen-size configurations.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// Breakpoints matching modern web/mobile design standards.
  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;

  /// Helper to check if screen is mobile size.
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileMax;
  }

  /// Helper to check if screen is tablet size.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileMax && width <= tabletMax;
  }

  /// Helper to check if screen is desktop/web size.
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width > tabletMax;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > tabletMax) {
          return desktop;
        } else if (constraints.maxWidth >= mobileMax) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
