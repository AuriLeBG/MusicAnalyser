class Favorite {
  final int id;
  final int userId;
  final int songId;

  Favorite({
    required this.id,
    required this.userId,
    required this.songId,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as int,
      userId: json['userId'] as int,
      songId: json['songId'] as int,
    );
  }
}
