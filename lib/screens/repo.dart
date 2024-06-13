// ignore_for_file: constant_identifier_names

import 'package:choice/choice.dart';
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

enum FilterType {
  All,
  CC,
  HCC,
  Other,
}

class _RepoScreenState extends State<RepoScreen> {
  FilterType? filterTag = FilterType.All;
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    songs = widget.songs;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        itemExtent: 68.0,
        itemCount: songs.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: InlineChoice<FilterType>.single(
                value: filterTag,
                onChanged: (value) => filterSongs(value),
                itemCount: FilterType.values.length,
                itemBuilder: (state, i) => ChoiceChip(
                  selected: state.selected(FilterType.values[i]),
                  onSelected: state.onSelected(FilterType.values[i]),
                  label: Text(FilterType.values[i].name),
                ),
              ),
            );
          } else {
            return ListTile(
              title: Text(
                maxLines: 1,
                songs[index - 1].title,
              ),
              subtitle: Text(
                maxLines: 1,
                getDescription(songs[index - 1].lyrics),
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongScreen(
                    title: songs[index - 1].title,
                    lyrics: songs[index - 1].lyrics,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String getDescription(String lyrics) {
    return lyrics.replaceAll('\n', ', ').replaceAll(',,', ',');
  }

  void filterSongs(FilterType? value) {
    if (value == null || value == FilterType.All) {
      songs = widget.songs;
    } else {
      songs = widget.songs.where((song) => song.type == FilterType.values[value.index].name).toList();
    }
    setState(() => filterTag = value);
  }
}
