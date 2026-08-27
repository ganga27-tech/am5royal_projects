class MediaItemModel {
  final String mediaUrl;
  final String mediaType;

  const MediaItemModel({
    required this.mediaUrl,
    required this.mediaType,
  });

  Map<String, dynamic> toJson() {
    return {
      'media_url': mediaUrl,
      'media_type': mediaType,
    };
  }
}

class AddServiceRequestModel {
  final int serviceId;
  final double amount;
  final bool isNegotiable;
  final List<MediaItemModel> media;

  const AddServiceRequestModel({
    required this.serviceId,
    required this.amount,
    required this.isNegotiable,
    this.media = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'amount': amount,
      'is_negotiable': isNegotiable,
      'media': media.map((m) => m.toJson()).toList(),
    };
  }
}
