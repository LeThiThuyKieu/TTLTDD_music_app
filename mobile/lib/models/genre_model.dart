class GenreModel {
  final int? genreId;
  final String name;
  final DateTime? createdAt;

  GenreModel({
    this.genreId,
    required this.name,
    this.createdAt,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      genreId: json['genre_id'] as int?,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genre_id': genreId,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}


