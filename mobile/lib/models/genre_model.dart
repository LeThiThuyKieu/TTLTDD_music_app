class GenreModel {
  final int? genreId;
  final String name;
  final DateTime? createdAt;

  GenreModel({
    this.genreId,
    required this.name,
    this.createdAt,
  });

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      genreId: _toInt(json['genre_id'] ?? json['genreId']),
      name: (json['name'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
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
