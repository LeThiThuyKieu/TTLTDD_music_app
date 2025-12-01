class ArtistModel {
  final int? artistId;
  final String name;
  final String? avatarUrl;
  final String? description;
  final int? isActive;

  ArtistModel({
    this.artistId,
    required this.name,
    this.avatarUrl,
    this.description,
    this.isActive,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      artistId: json['artist_id'] as int?,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artist_id': artistId,
      'name': name,
      'avatar_url': avatarUrl,
      'description': description,
      'is_active': isActive,
    };
  }
}



