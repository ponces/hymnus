import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hymnus/models/song.dart';
import 'package:hymnus/screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hymnus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: MediaQuery.of(context).platformBrightness,
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<List<Song>>(
        future: _readJson(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeScreen(
              title: 'Home',
              songs: snapshot.data!,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<List<Song>> _readJson() async {
    final String response = await rootBundle.loadString('assets/db/songs.json');
    final info = await json.decode(response);
    var list = info['songs'] as List<dynamic>;
    return list.map((s) => Song.fromJson(s)).toList();
  }
}
