import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hymnus/models/setlist.dart';
import 'package:hymnus/screens/setlist.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetlistsScreen extends StatefulWidget {
  const SetlistsScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<SetlistsScreen> createState() => _SetlistsScreenState();
}

class _SetlistsScreenState extends State<SetlistsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Setlist>>(
        future: fetchSetlists(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemExtent: 68.0,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    maxLines: 1,
                    snapshot.data![index].name,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetlistScreen(
                        setlist: snapshot.data![index],
                      ),
                    ),
                  ),
                );
              },
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

  Future<List<Setlist>> fetchSetlists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lists = prefs.getString('setlists') ?? '[]';
    return json.decode(lists).map((l) => Setlist.fromJson(l)).toList();
  }
}
