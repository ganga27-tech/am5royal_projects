import '../constants/app_assets.dart';

/// Maps service/category names to bundled local images when API icons fail.
abstract final class ServiceAssetMapper {
  ServiceAssetMapper._();

  static String? forName(String name) {
    final String key = name.toLowerCase();

    if (key.contains('pet care')) return AppAssets.petCare;
    if (key.contains('ac repair')) return AppAssets.acRepair;
    if (key.contains('plumbing')) return AppAssets.plumbing;
    if (key.contains('cooking')) return AppAssets.cooking;
    if (key.contains('cleaning')) return AppAssets.cleaning;
    if (key.contains('driver')) return AppAssets.driver;
    if (key.contains('immediate')) return AppAssets.immediate;
    if (key.contains('pest control')) return AppAssets.pestControl;
    if (key.contains('lab test') || key.contains('lab')) return AppAssets.labTest;
    if (key.contains('painting')) return AppAssets.painting;
    if (key.contains('physiotherapy')) return AppAssets.physiotherapy;
    if (key.contains('water proof') || key.contains('waterproof')) {
      return AppAssets.waterproofing;
    }
    if (key.contains('beauty') || key.contains('wellness')) {
      return AppAssets.beautyWellness;
    }
    if (key.contains('home') && key.contains('class')) {
      return AppAssets.homeOnlineClasses;
    }
    if (key.contains('caretaker') || key.contains('care taker')) {
      return AppAssets.caretaker;
    }
    if (key.contains('wheeler') || key.contains('2 and 4')) {
      return AppAssets.twoFourWheeler;
    }
    if (key.contains('modular') || key.contains('interior') ||
        key.contains('carpentry')) {
      return AppAssets.modularInterior;
    }
    if (key.contains('electrical')) return AppAssets.acRepair;
    if (key.contains('appliance')) return AppAssets.acRepair;
    if (key.contains('nursing')) return AppAssets.healthcareMedical;
    if (key.contains('home service')) return AppAssets.cleaning;
    if (key.contains('event') || key.contains('wedding')) {
      return AppAssets.eventManagement;
    }
    if (key.contains('packers') || key.contains('mover')) {
      return AppAssets.packersMovers;
    }
    if (key.contains('healthcare') || key.contains('medical') ||
        key.contains('hospital')) {
      return AppAssets.healthcareMedical;
    }
    if (key.contains('travel') || key.contains('tourism')) {
      return AppAssets.travelTourism;
    }
    if (key.contains('food') || key.contains('beverage')) {
      return AppAssets.foodBeverage;
    }
    if (key.contains('wholesale') || key.contains('distribution') ||
        key.contains('finance')) {
      return AppAssets.wholesaleDistribution;
    }
    if (key.contains('security') || key.contains('safety')) {
      return AppAssets.immediate;
    }
    if (key.contains('religious') || key.contains('spiritual')) {
      return AppAssets.healthcareHospital;
    }
    if (key.contains('rental') || key.contains('hire')) {
      return AppAssets.packersMovers;
    }

    return null;
  }
}
