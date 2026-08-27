class AddServiceResponseModel {
  final int id;
  final String? message;
  final String? name;
  final double? price;

  const AddServiceResponseModel({
    required this.id,
    this.message,
    this.name,
    this.price,
  });

  factory AddServiceResponseModel.fromJson(Map<String, dynamic> json) {
    // Safely parse number that might be double, int, or String
    double? parsedPrice;
    if (json['price'] != null) {
      parsedPrice = (json['price'] as num).toDouble();
    } else if (json['amount'] != null) {
      parsedPrice = (json['amount'] as num).toDouble();
    }

    return AddServiceResponseModel(
      id: json['id'] as int,
      message: json['message'] as String?,
      name: json['name'] as String?,
      price: parsedPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (message != null) 'message': message,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
    };
  }
}
