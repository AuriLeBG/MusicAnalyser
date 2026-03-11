class Song {
  final int id;
  final String title;
  final int? year;
  final String? language;
  final String? artistName;

  Song({
    required this.id,
    required this.title,
    this.year,
    this.language,
    this.artistName,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>?;
    return Song(
      id: json['id'] as int,
      title: json['title'] as String,
      year: json['year'] as int?,
      language: json['language'] as String?,
      artistName: artist?['name'] as String?,
    );
  }
}
