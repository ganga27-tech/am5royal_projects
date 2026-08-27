import 'package:flutter/material.dart';

/// Centralized responsive utilities for the AM5ROYAL Flutter Web.
///
/// Breakpoints are intentionally kept in one place so the entire website
/// follows the same responsive rules.
abstract final class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1200;
}

abstract final class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return width >= ResponsiveBreakpoints.mobile &&
        width < ResponsiveBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.tablet;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.desktop;
  }

  static double horizontalPadding(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    if (width < ResponsiveBreakpoints.mobile) {
      return 20;
    }

    if (width < ResponsiveBreakpoints.tablet) {
      return 32;
    }

    if (width < ResponsiveBreakpoints.desktop) {
      return 55;
    }

    return 80;
  }

  static double contentMaxWidth(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    if (width >= 1600) {
      return 1400;
    }

    if (width >= ResponsiveBreakpoints.desktop) {
      return 1200;
    }

    return width;
  }
}