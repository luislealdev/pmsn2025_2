class ApiMovieDao {
  // bool adult;
  String backdropPath;
  // List<int> genreIds;
  int id;
  String originalLanguage;
  String originalTitle;
  String overview;
  double popularity;
  String posterPath;
  DateTime releaseDate;
  String title;
  // bool video;
  double voteAverage;
  int voteCount;

  ApiMovieDao({
    // required this.adult,
    required this.backdropPath,
    // required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    // required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory ApiMovieDao.fromJson(Map<String, dynamic> json) {
    return ApiMovieDao(
      // adult: json['adult'],
      backdropPath: json['backdrop_path'] ?? '',
      // genreIds: List<int>.from(json['genre_ids'] ?? []),
      id: json['id'],
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      posterPath: json['poster_path'] ?? '',
      releaseDate:
          DateTime.tryParse(json['release_date'] ?? '') ?? DateTime(1900, 1, 1),
      title: json['title'] ?? '',
      // video: json['video'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
    );
  }
}
