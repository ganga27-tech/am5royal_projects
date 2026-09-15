import '../../sections/navbar/navbar_section.dart';
import 'seo_metadata.dart';

class SeoRoutes {
  SeoRoutes._();

  static SeoMetadata metadataForSection(
    NavbarSectionId section,
  ) {
    switch (section) {
      case NavbarSectionId.home:
        return SeoMetadata.home;

      case NavbarSectionId.services:
        return SeoMetadata.services;

      case NavbarSectionId.vendor:
        return SeoMetadata.vendor;

      case NavbarSectionId.customer:
        return SeoMetadata.customer;

      case NavbarSectionId.freelancer:
        return SeoMetadata.freelancer;

      case NavbarSectionId.careers:
        return SeoMetadata.careers;

      case NavbarSectionId.contact:
        return SeoMetadata.contact;

      case NavbarSectionId.howItWorks:
        return SeoMetadata.howItWorks;

      case NavbarSectionId.faqs:
        return SeoMetadata.faqs;

      case NavbarSectionId.privacyPolicy:
        return SeoMetadata.privacyPolicy;

      case NavbarSectionId.termsConditions:
        return SeoMetadata.termsConditions;
    }
  }

  static NavbarSectionId sectionFromPath(
    String? rawPath,
  ) {
    final String path = _normalizePath(rawPath);

    switch (path) {
      case '/':
        return NavbarSectionId.home;

      case '/services':
        return NavbarSectionId.services;

      case '/vendor':
        return NavbarSectionId.vendor;

      case '/customer':
        return NavbarSectionId.customer;

      case '/freelancer':
        return NavbarSectionId.freelancer;

      case '/careers':
        return NavbarSectionId.careers;

      case '/contact':
        return NavbarSectionId.contact;

      case '/how-it-works':
        return NavbarSectionId.howItWorks;

      case '/faqs':
        return NavbarSectionId.faqs;

      case '/privacy-policy':
        return NavbarSectionId.privacyPolicy;

      case '/terms-conditions':
      case '/terms-and-conditions':
        return NavbarSectionId.termsConditions;

      default:
        return NavbarSectionId.home;
    }
  }

  /// Browser navigation paths.
  ///
  /// IMPORTANT:
  /// These paths are intentionally independent from SeoMetadata.
  /// This prevents a metadata change from breaking navigation.
  static String pathForSection(
    NavbarSectionId section,
  ) {
    switch (section) {
      case NavbarSectionId.home:
        return '/';

      case NavbarSectionId.services:
        return '/services';

      case NavbarSectionId.vendor:
        return '/vendor';

      case NavbarSectionId.customer:
        return '/customer';

      case NavbarSectionId.freelancer:
        return '/freelancer';

      case NavbarSectionId.careers:
        return '/careers';

      case NavbarSectionId.contact:
        return '/contact';

      case NavbarSectionId.howItWorks:
        return '/how-it-works';

      case NavbarSectionId.faqs:
        return '/faqs';

      case NavbarSectionId.privacyPolicy:
        return '/privacy-policy';

      case NavbarSectionId.termsConditions:
        return '/terms-conditions';
    }
  }

  static bool shouldScrollToServices(
    NavbarSectionId section,
    String? rawPath,
  ) {
    return section == NavbarSectionId.services ||
        _normalizePath(rawPath) == '/services';
  }

  static String _normalizePath(
    String? rawPath,
  ) {
    if (rawPath == null || rawPath.trim().isEmpty) {
      return '/';
    }

    String path = rawPath.trim();

    if (path.startsWith('#')) {
      path = path.substring(1);
    }

    if (!path.startsWith('/')) {
      path = '/$path';
    }

    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }
}
