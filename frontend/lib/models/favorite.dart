class Favorite {
  final int userId;
  final int songId;
  final String? title;
  final int? year;
  final String? language;
  final String? artistName;

  Favorite({
    required this.userId,
    required this.songId,
    this.title,
    this.year,
    this.language,
    this.artistName,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      userId: json['userId'] as int,
      songId: (json['songId'] as num).toInt(),
      title: json['title'] as String?,
      year: json['year'] as int?,
      language: json['language'] as String?,
      artistName: json['artistName'] as String?,
    );
  }
}
