import 'dart:html' as html;

import 'seo_metadata.dart';

// =============================================================================
// APPLY SEO METADATA
// =============================================================================

void applySeoMetadata(
  SeoMetadata metadata,
) {
  html.document.title = metadata.title;

  _setMeta(
    name: 'description',
    content: metadata.description,
  );

  if (metadata.keywords != null && metadata.keywords!.trim().isNotEmpty) {
    _setMeta(
      name: 'keywords',
      content: metadata.keywords!,
    );
  }

  _setMetaProperty(
    property: 'og:title',
    content: metadata.title,
  );

  _setMetaProperty(
    property: 'og:description',
    content: metadata.description,
  );

  _setMetaProperty(
    property: 'og:url',
    content: metadata.canonicalUrl,
  );
}

// =============================================================================
// META TAG HELPERS
// =============================================================================

void _setMeta({
  required String name,
  required String content,
}) {
  html.MetaElement? element = html.document.querySelector(
    'meta[name="$name"]',
  ) as html.MetaElement?;

  if (element == null) {
    element = html.MetaElement()..name = name;

    html.document.head?.append(element);
  }

  element.content = content;
}

void _setMetaProperty({
  required String property,
  required String content,
}) {
  html.MetaElement? element = html.document.querySelector(
    'meta[property="$property"]',
  ) as html.MetaElement?;

  if (element == null) {
    element = html.MetaElement()
      ..setAttribute(
        'property',
        property,
      );

    html.document.head?.append(element);
  }

  element.content = content;
}

// =============================================================================
// BROWSER NAVIGATION
// =============================================================================
//
// IMPORTANT:
//
// We intentionally DO NOT use:
//
//   window.location.hash = route
//
// because that triggers hashchange immediately.
//
// Instead we use History API:
//
//   history.pushState()
//
// This changes the browser URL without firing hashchange.
//
// Result:
//
// Home -> Services
// Home -> Careers
// Home -> Freelancer
// Home -> Contact
//
// will stay on the selected section.
//
// Browser Back / Forward is handled separately through popstate.
// =============================================================================

void updateBrowserPath(
  String path,
) {
  final String route = _normalizePath(path);

  final String current = currentBrowserPath() ?? '/';

  if (current == route) {
    return;
  }

  // Keep the required hash URLs:
  //
  // #/
  // #/services
  // #/careers
  // #/freelancer
  // #/contact
  //
  final String browserUrl = route == '/' ? '#/' : '#$route';

  html.window.history.pushState(
    null,
    '',
    browserUrl,
  );
}

// =============================================================================
// CURRENT BROWSER PATH
// =============================================================================

String? currentBrowserPath() {
  final String hash = html.window.location.hash.trim();

  if (hash.isEmpty) {
    return '/';
  }

  String route = hash;

  if (route.startsWith('#')) {
    route = route.substring(1);
  }

  return _normalizePath(route);
}

// =============================================================================
// LISTEN TO BROWSER NAVIGATION
// =============================================================================
//
// Handles:
//
// 1. Browser Back
// 2. Browser Forward
// 3. Manual hash changes
//
// pushState itself does NOT trigger popstate.
// Therefore clicking navbar will not immediately trigger
// another section change.
//
// Back / Forward DOES trigger popstate.
// =============================================================================

void listenToBrowserNavigation(
  void Function(String path) onPathChanged,
) {
  html.window.onPopState.listen((_) {
    onPathChanged(
      currentBrowserPath() ?? '/',
    );
  });

  // Keep support for manually changing the hash.
  html.window.onHashChange.listen((_) {
    onPathChanged(
      currentBrowserPath() ?? '/',
    );
  });
}

// =============================================================================
// NORMALIZE PATH
// =============================================================================

String _normalizePath(
  String path,
) {
  String route = path.trim();

  if (route.isEmpty) {
    return '/';
  }

  // Remove hash if supplied.
  if (route.startsWith('#')) {
    route = route.substring(1);
  }

  // Make sure route starts with /.
  if (!route.startsWith('/')) {
    route = '/$route';
  }

  // Remove trailing slash except root.
  if (route.length > 1 && route.endsWith('/')) {
    route = route.substring(
      0,
      route.length - 1,
    );
  }

  return route;
}
