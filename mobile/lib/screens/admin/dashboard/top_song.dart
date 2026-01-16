class TopSong {
  final String title;
  final String artist;
  final int plays;
  final String image;

  TopSong({
    required this.title,
    required this.artist,
    required this.plays,
    required this.image,
  });

  factory TopSong.fromJson(Map<String, dynamic> json) {
    return TopSong(
      title: json['title'],
      artist: json['artist'],
      plays: json['plays'],
      image: json['image'],
    );
  }
}
