class Song {
  final int id;
  final String title;
  final String type;
  final String lyrics;

  Song({
    required this.id,
    required this.title,
    required this.type,
    required this.lyrics,
  });

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as int,
        title: json['title'] as String,
        type: json['type'] as String,
        lyrics: json['lyrics'] as String,
      );
}
