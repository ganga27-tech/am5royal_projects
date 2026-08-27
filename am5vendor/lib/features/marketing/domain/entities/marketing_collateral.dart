class MarketingCollateral {
  final int id;
  final String title;
  final String collateralType; // VIDEO, PDF, IMAGE, QR
  final String url;
  final String? description;
  final bool isActive;

  MarketingCollateral({
    required this.id,
    required this.title,
    required this.collateralType,
    required this.url,
    this.description,
    required this.isActive,
  });
}
