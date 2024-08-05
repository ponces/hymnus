// ignore_for_file: constant_identifier_names

import 'package:hymnus/models/setlist.dart';

class CustomText implements ISetlistItem {
  final int id;
  final String content;

  CustomText({
    required this.id,
    required this.content,
  });

  factory CustomText.fromJson(Map<String, dynamic> json) => CustomText(
        id: json['id'] as int,
        content: json['content'] as String,
      );
}
