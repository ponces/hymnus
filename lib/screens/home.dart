import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:hymnus/models/song.dart';
import 'package:hymnus/screens/repo.dart';
import 'package:hymnus/screens/settings.dart';
import 'package:hymnus/screens/song.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.title,
    required this.songs,
  });

  final String title;

  final List<Song> songs;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentScreenIndex = 0;

  @override
  void initState() {
    super.initState();
    _applyAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hymnus'),
        actions: currentScreenIndex == 0
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => showSearch(
                    context: context,
                    delegate: SongSearch(songs: widget.songs),
                  ),
                )
              ]
            : <Widget>[],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentScreenIndex = index;
          });
        },
        selectedIndex: currentScreenIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
      body: <Widget>[
        RepoScreen(
          title: 'Repo',
          songs: widget.songs,
        ),
        const SettingsScreen(title: 'Settings'),
      ][currentScreenIndex],
    );
  }

  Future<void> _applyAppSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool keepDisplayOn = prefs.getBool('keepDisplayOn') ?? false;
    WakelockPlus.toggle(enable: keepDisplayOn);
  }
}

class SongSearch extends SearchDelegate {
  final List<Song> songs;

  SongSearch({required this.songs});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var queryy = removeDiacritics(query).toLowerCase();
    return getSearchResults(queryy);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var queryy = removeDiacritics(query).toLowerCase();
    return getSearchResults(queryy);
  }

  Widget getSearchResults(String query) {
    List<Song> results = filterSongs(query);
    return ListView.builder(
      itemExtent: 48.0,
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            results[index].title,
            maxLines: 1,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongScreen(
                title: results[index].title,
                lyrics: results[index].lyrics,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Song> filterSongs(String query) {
    List<Song> results = [];
    for (var song in songs) {
      if (query.isEmpty) {
        results.add(song);
      } else {
        var title = removeDiacritics(song.title.toLowerCase());
        if (title.contains(query)) {
          results.add(song);
        } else {
          var lyrics = removeDiacritics(song.lyrics.toLowerCase());
          if (lyrics.contains(query)) {
            results.add(song);
          }
        }
      }
    }
    return results;
  }
}
