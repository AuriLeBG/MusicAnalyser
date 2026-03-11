class Artist {
  final int id;
  final String name;
  final String? genre;
  final int? birthYear;

  Artist({
    required this.id,
    required this.name,
    this.genre,
    this.birthYear,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as int,
      name: json['name'] as String,
      genre: json['genre'] as String?,
      birthYear: json['birthYear'] as int?,
    );
  }
}
