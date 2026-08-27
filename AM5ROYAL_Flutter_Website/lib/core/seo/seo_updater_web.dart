import 'dart:html' as html;

import 'seo_metadata.dart';

void _setMeta(String key, String content, {required bool isProperty}) {
  final String attribute = isProperty ? 'property' : 'name';
  html.Element? element =
      html.document.querySelector('meta[$attribute="$key"]');

  if (element == null) {
    element = html.MetaElement()..setAttribute(attribute, key);
    html.document.head?.append(element);
  }

  element.setAttribute('content', content);
}

void _setCanonical(String href) {
  html.LinkElement? link =
      html.document.querySelector('link[rel="canonical"]') as html.LinkElement?;

  if (link == null) {
    link = html.LinkElement()..rel = 'canonical';
    html.document.head?.append(link);
  }

  link.href = href;
}

void applySeoMetadata(SeoMetadata metadata) {
  html.document.title = metadata.title;

  _setMeta('description', metadata.description, isProperty: false);
  if (metadata.keywords != null && metadata.keywords!.isNotEmpty) {
    _setMeta('keywords', metadata.keywords!, isProperty: false);
  }

  _setCanonical(metadata.canonicalUrl);

  _setMeta('og:type', 'website', isProperty: true);
  _setMeta('og:site_name', SeoMetadata.siteName, isProperty: true);
  _setMeta('og:url', metadata.canonicalUrl, isProperty: true);
  _setMeta('og:title', metadata.title, isProperty: true);
  _setMeta('og:description', metadata.description, isProperty: true);
  _setMeta('og:locale', SeoMetadata.locale, isProperty: true);
  _setMeta('og:image', metadata.imageUrl, isProperty: true);
  _setMeta('og:image:alt', metadata.imageAlt, isProperty: true);

  _setMeta('twitter:card', 'summary_large_image', isProperty: false);
  _setMeta('twitter:title', metadata.title, isProperty: false);
  _setMeta('twitter:description', metadata.description, isProperty: false);
  _setMeta('twitter:image', metadata.imageUrl, isProperty: false);
}

void updateBrowserPath(String path) {
  final String target = path.startsWith('/') ? path : '/$path';
  if (html.window.location.pathname != target) {
    html.window.history.pushState(null, '', target);
  }
}

String? currentBrowserPath() => html.window.location.pathname;

void listenToBrowserNavigation(void Function(String path) onPathChanged) {
  html.window.onPopState.listen((_) {
    onPathChanged(html.window.location.pathname ?? '/');
  });
}
