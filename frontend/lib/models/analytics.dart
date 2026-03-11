class ViewsByYear {
  final int year;
  final int totalViews;

  ViewsByYear({required this.year, required this.totalViews});

  factory ViewsByYear.fromJson(Map<String, dynamic> json) {
    return ViewsByYear(
      year: json['year'] as int,
      totalViews: json['totalViews'] as int,
    );
  }
}

class TopArtist {
  final String artist;
  final int totalViews;

  TopArtist({required this.artist, required this.totalViews});

  factory TopArtist.fromJson(Map<String, dynamic> json) {
    return TopArtist(
      artist: json['artist'] as String,
      totalViews: json['totalViews'] as int,
    );
  }
}

class TopGenre {
  final String genre;
  final int totalViews;

  TopGenre({required this.genre, required this.totalViews});

  factory TopGenre.fromJson(Map<String, dynamic> json) {
    return TopGenre(
      genre: json['genre'] as String,
      totalViews: json['totalViews'] as int,
    );
  }
}
