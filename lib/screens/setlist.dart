import 'package:flutter/material.dart';
import 'package:hymnus/models/setlist.dart';

class SetlistScreen extends StatefulWidget {
  const SetlistScreen({
    super.key,
    required this.setlist,
  });

  final Setlist setlist;

  @override
  State<SetlistScreen> createState() => _SetlistScreenState();
}

class _SetlistScreenState extends State<SetlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
