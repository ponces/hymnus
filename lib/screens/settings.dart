import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.title});

  final String title;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          bool keepDisplayOn = false;
          if (snapshot.hasData) {
            keepDisplayOn = snapshot.data!.getBool('keepDisplayOn') ?? false;
          }
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Keep display on',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Switch(
                          value: keepDisplayOn,
                          onChanged: (value) => _updateKeepDisplayOn(
                            snapshot.data,
                            value,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      return ListTile(
                        title: const Text('About'),
                        subtitle: Text(
                          snapshot.hasData
                              ? 'Hymnus ${snapshot.data!.version}'
                              : 'Hymnus',
                        ),
                        onTap: () => _showAboutDialog(snapshot.data!),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateKeepDisplayOn(
      SharedPreferences? prefs, bool value) async {
    await prefs!.setBool('keepDisplayOn', value);
    setState(() {});
    WakelockPlus.toggle(enable: value);
  }

  Future<void> _showAboutDialog(PackageInfo packageInfo) async {
    return showAboutDialog(
      // ignore: use_build_context_synchronously
      context: context,
      // ignore: sized_box_for_whitespace
      applicationIcon: Container(
        height: 65,
        width: 65,
        child: const Image(
          image: AssetImage(
            'assets/images/icon-192x192.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      applicationName: 'Hymnus',
      applicationVersion: packageInfo.version,
      applicationLegalese:
          '\u{00a9} ${DateFormat('yyyy').format(DateTime.now())} ponces',
      children: <Widget>[
        const SizedBox(height: 20),
        const Text(
          'This app was designed to ease the access to a huge lyrics and chords repository of Christian hymns and songs.\n\nProvided to you by',
          textAlign: TextAlign.center,
        ),
        GestureDetector(
          child: const Text(
            'Alberto Ponces',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
            textAlign: TextAlign.center,
          ),
          onTap: () => launchUrl(Uri.parse('https://github.com/ponces')),
        ),
        GestureDetector(
          child: const Text(
            'ponces26@gmail.com',
            style: TextStyle(
              decoration: TextDecoration.underline,
            ),
            textAlign: TextAlign.center,
          ),
          onTap: () => launchUrl(Uri.parse('mailto:ponces26@gmail.com')),
        ),
      ],
    );
  }
}
