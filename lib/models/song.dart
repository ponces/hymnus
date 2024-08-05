// ignore_for_file: constant_identifier_names

import 'package:hymnus/models/setlist.dart';

enum HymnalType {
  Unknown,
  CC,
  HCC,
  Other,
}

class Song implements ISetlistItem {
  final int id;
  final String title;
  final HymnalType type;
  final List<Group> lyrics;

  Song({
    required this.id,
    required this.title,
    required this.type,
    required this.lyrics,
  });

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as int,
        title: json['title'] as String,
        type: json['type'] == 'CC'
            ? HymnalType.CC
            : json['type'] == 'HCC'
                ? HymnalType.HCC
                : HymnalType.Other,
        lyrics: (json['lyrics'] as List<dynamic>)
            .map((l) => Group.fromJson(l))
            .toList(),
      );
}

class Group {
  final String name;
  final String data;

  Group({
    required this.name,
    required this.data,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        name: json['name'] as String,
        data: json['data'] as String,
      );
}
