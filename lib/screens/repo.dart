import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymnus/models/song.dart';
import 'package:hymnus/screens/song.dart';

class RepoScreen extends StatefulWidget {
  const RepoScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<RepoScreen> createState() => _RepoScreenState();
}

class _RepoScreenState extends State<RepoScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Song>>(
        future: readJson(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(
                    '${getDescription(snapshot.data![index].lyrics)}...',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongScreen(
                        title: snapshot.data![index].title,
                        lyrics: snapshot.data![index].lyrics,
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<List<Song>> readJson() async {
    final String response = await rootBundle.loadString('assets/db/songs.json');
    final info = await json.decode(response);
    var list = info['songs'] as List<dynamic>;
    return list.map((s) => Song.fromJson(s)).toList();
  }

  String getDescription(String lyrics) {
    return lyrics.replaceAll('\n', ', ').replaceAll(',,', ',').substring(0, 34);
  }
}
