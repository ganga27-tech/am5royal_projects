/// Booking flow defaults for the customer website.
abstract final class BookingConfig {
  BookingConfig._();

  /// Main category id for "Home services" on production API.
  /// Override via: `--dart-define=HOME_SERVICES_CATEGORY_ID=37`
  static const int homeServicesCategoryId = int.fromEnvironment(
    'HOME_SERVICES_CATEGORY_ID',
    defaultValue: 37,
  );
}
