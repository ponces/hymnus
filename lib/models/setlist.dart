import 'package:hymnus/models/customtext.dart';
import 'package:hymnus/models/song.dart';

class Setlist {
  final int id;
  final String name;
  final List<ISetlistItem> items;

  Setlist({
    required this.id,
    required this.name,
    required this.items,
  });

  factory Setlist.fromJson(Map<String, dynamic> json) => Setlist(
        id: json['id'] as int,
        name: json['name'] as String,
        items: (json['items'] as List<dynamic>)
            .map((l) => ISetlistItem.fromJson(l))
            .toList(),
      );
}

enum SetlistItemType { song, bible, text }

abstract class ISetlistItem {
  factory ISetlistItem.fromJson(Map<String, dynamic> json) {
    if (json['type'] == SetlistItemType.song) {
      return Song.fromJson(json);
    } else {
      return CustomText.fromJson(json);
    }
  }
}
