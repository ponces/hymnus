import 'package:flutter/material.dart';
import 'package:hymnus/models/song.dart';
import 'package:hymnus/screens/song.dart';

class RepoScreen extends StatefulWidget {
  const RepoScreen({
    super.key,
    required this.title,
    required this.songs,
  });

  final String title;

  final List<Song> songs;

  @override
  State<RepoScreen> createState() => _RepoScreenState();
}

class _RepoScreenState extends State<RepoScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        itemExtent: 68.0,
        itemCount: widget.songs.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              maxLines: 1,
              widget.songs[index].title,
            ),
            subtitle: Text(
              maxLines: 1,
              '${getDescription(widget.songs[index].lyrics)}...',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongScreen(
                  title: widget.songs[index].title,
                  lyrics: widget.songs[index].lyrics,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String getDescription(String lyrics) {
    return lyrics.replaceAll('\n', ', ').replaceAll(',,', ',');
  }
}
