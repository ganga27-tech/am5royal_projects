import '../../sections/navbar/navbar_section.dart';
import 'seo_metadata.dart';
import 'seo_routes.dart';
import 'seo_updater_stub.dart'
    if (dart.library.html) 'seo_updater_web.dart';

class SeoService {
  SeoService._();

  static void applySection(NavbarSectionId section) {
    final SeoMetadata metadata = SeoRoutes.metadataForSection(section);
    applySeoMetadata(metadata);
    updateBrowserPath(metadata.path);
  }

  static void applyMetadata(SeoMetadata metadata) {
    applySeoMetadata(metadata);
    updateBrowserPath(metadata.path);
  }

  static NavbarSectionId sectionFromCurrentPath() {
    return SeoRoutes.sectionFromPath(currentBrowserPath());
  }

  static void listenToNavigation(void Function(NavbarSectionId section) onSection) {
    listenToBrowserNavigation((String path) {
      onSection(SeoRoutes.sectionFromPath(path));
    });
  }
}
