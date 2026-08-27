class TelecallerLeaderboardModel {
  final String name;
  final int points;

  TelecallerLeaderboardModel({
    required this.name,
    required this.points,
  });

  factory TelecallerLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return TelecallerLeaderboardModel(
      name: json['name'] as String,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'points': points,
    };
  }
}
