import '../../sections/navbar/navbar_section.dart';

import 'seo_metadata.dart';
import 'seo_routes.dart';

import 'seo_updater_stub.dart' if (dart.library.html) 'seo_updater_web.dart'
    as platform;

class SeoService {
  SeoService._();

  // ===========================================================================
  // APPLY SECTION
  // ===========================================================================

  static void applySection(
    NavbarSectionId section,
  ) {
    final SeoMetadata metadata = SeoRoutes.metadataForSection(section);

    platform.applySeoMetadata(metadata);

    platform.updateBrowserPath(
      SeoRoutes.pathForSection(section),
    );
  }

  // ===========================================================================
  // APPLY SEO ONLY
  // ===========================================================================

  static void applyMetadata(
    SeoMetadata metadata,
  ) {
    platform.applySeoMetadata(metadata);
  }

  // ===========================================================================
  // UPDATE BROWSER URL
  // ===========================================================================

  static void updateBrowserPath(
    String path,
  ) {
    platform.updateBrowserPath(path);
  }

  // ===========================================================================
  // READ CURRENT BROWSER SECTION
  // ===========================================================================

  static NavbarSectionId sectionFromCurrentPath() {
    final String path = platform.currentBrowserPath() ?? '/';

    return SeoRoutes.sectionFromPath(path);
  }

  // ===========================================================================
  // LISTEN TO BROWSER NAVIGATION
  // ===========================================================================

  static void listenToNavigation(
    void Function(
      NavbarSectionId section,
    ) onSection,
  ) {
    platform.listenToBrowserNavigation(
      (String path) {
        final NavbarSectionId section = SeoRoutes.sectionFromPath(path);

        onSection(section);
      },
    );
  }
}
