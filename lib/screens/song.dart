import 'package:flutter/material.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({
    super.key,
    required this.title,
    required this.lyrics,
  });

  final String title;
  final String lyrics;

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(widget.lyrics),
      ),
    );
  }
}
