import 'package:flutter/material.dart';

/// =======================================================
/// RESPONSIVE BUILDER
/// =======================================================
///
/// Breakpoints:
///   Mobile  — width < 700
///   Tablet  — 700 ≤ width < 1100
///   Web     — width ≥ 1100
///
/// WHY BUILDER CALLBACKS?
/// ----------------------
/// Passing pre-built widgets (Widget mobile, Widget web) means Flutter
/// evaluates those subtrees eagerly in the *parent's* build call, capturing
/// MediaQuery dimensions at that moment.  When the Chrome window is resized
/// the parent does NOT always rebuild, so those widgets hold stale sizes and
/// the layout (gravity / alignment) doesn't update until a full reload.
///
/// Using WidgetBuilder callbacks ensures the correct subtree is built
/// *after* LayoutBuilder has measured the live viewport width, so every
/// resize triggers a fresh, correct build.
/// =======================================================

// ---------------------------------------------------------------------------
// Breakpoint constants — single source of truth
// ---------------------------------------------------------------------------
class Breakpoints {
  Breakpoints._();

  static const double tablet = 700;
  static const double web = 1100;
}

// ---------------------------------------------------------------------------
// ResponsiveBuilder
// ---------------------------------------------------------------------------
class ResponsiveBuilder extends StatelessWidget {
  /// Called when width < 700
  final WidgetBuilder mobileBuilder;

  /// Called when 700 ≤ width < 1100.  Falls back to [mobileBuilder] if null.
  final WidgetBuilder? tabletBuilder;

  /// Called when width ≥ 1100
  final WidgetBuilder webBuilder;

  const ResponsiveBuilder({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    required this.webBuilder,
  });

  // -------------------------------------------------------------------------
  // Static helpers — read directly from MediaQuery so they are always in sync
  // with the live viewport.  Use inside a build method that is subscribed to
  // MediaQuery changes (i.e. normal Flutter widget build).
  // -------------------------------------------------------------------------

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.tablet;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= Breakpoints.tablet && w < Breakpoints.web;
  }

  static bool isWeb(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.web;

  /// Returns the current [ScreenSize] for the given [context].
  static ScreenSize screenSize(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= Breakpoints.web) return ScreenSize.web;
    if (w >= Breakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= Breakpoints.web) {
          // WEB — build lazily so the subtree sees the correct width
          return webBuilder(context);
        } else if (width >= Breakpoints.tablet) {
          // TABLET
          return (tabletBuilder ?? mobileBuilder)(context);
        } else {
          // MOBILE
          return mobileBuilder(context);
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// ScreenSize enum — convenience for switch expressions
// ---------------------------------------------------------------------------
enum ScreenSize { mobile, tablet, web }

// ---------------------------------------------------------------------------
// ResponsiveValue<T> — pick a value based on the current breakpoint
// ---------------------------------------------------------------------------
/// Usage:
/// ```dart
/// final padding = ResponsiveValue<double>(
///   context: context,
///   mobile: 16,
///   tablet: 24,
///   web: 40,
/// ).value;
/// ```
class ResponsiveValue<T> {
  final BuildContext context;
  final T mobile;
  final T? tablet;
  final T web;

  const ResponsiveValue({
    required this.context,
    required this.mobile,
    this.tablet,
    required this.web,
  });

  T get value {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= Breakpoints.web) return web;
    if (w >= Breakpoints.tablet) return tablet ?? mobile;
    return mobile;
  }
}
