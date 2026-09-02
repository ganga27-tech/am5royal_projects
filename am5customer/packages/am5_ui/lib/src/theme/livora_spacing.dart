abstract final class LivoraSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double hero = 64;

  static const BorderRadii radii = BorderRadii();
}

final class BorderRadii {
  const BorderRadii();
  double get sm => 8;
  double get md => 12;
  double get lg => 16;
  double get xl => 24;
  double get full => 999;
}
