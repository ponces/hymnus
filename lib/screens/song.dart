import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as html2pdf;
import 'package:hymnus/models/song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({
    super.key,
    required this.song,
  });

  final Song song;

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showBottomSheet(),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getLyricsWidgets(widget.song.lyrics),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBottomSheet() async {
    return showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Copy lyrics'),
              onTap: () => _copyToClipboard(true),
            ),
            kIsWeb
                ? Container()
                : ListTile(
                    leading: const Icon(Icons.save),
                    title: const Text('Export PDF'),
                    onTap: () => _exportPdf(),
                  ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(bool closeBottomSheet) {
    Navigator.of(context).pop();
    Clipboard.setData(ClipboardData(
      text: getPlainLyrics(widget.song.lyrics),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
      ),
    );
  }

  Future<void> _exportPdf() async {
    var tmpDir = (await getTemporaryDirectory()).path;
    var filename = getFilename(widget.song.title);
    var html = '''
        <h1>${widget.song.title}</h1>
        <hr/>
        ${getHtmlLyrics(widget.song.lyrics)}
    ''';
    var pdfFile = File('$tmpDir/$filename');
    final pdfDoc = html2pdf.Document();
    var widgets = await html2pdf.HTMLToPdf().convert(html);
    pdfDoc.addPage(html2pdf.MultiPage(
        maxPages: 10,
        orientation: html2pdf.PageOrientation.portrait,
        pageFormat: html2pdf.PdfPageFormat.a4,
        build: (context) {
          return widgets;
        }));
    await pdfFile.writeAsBytes(await pdfDoc.save());
    ShareExtend.share(pdfFile.path, 'file');
  }

  String getFilename(String songTitle) {
    String filename = '';
    if ((songTitle.startsWith('CC') || songTitle.startsWith('HCC')) &&
        songTitle.contains(' ')) {
      filename = songTitle.split(' ')[0];
    } else {
      filename = removeDiacritics(
        songTitle.replaceAll(RegExp('[-_,:;+!? ]'), ''),
      );
    }
    return '$filename.pdf';
  }

  List<Widget> getLyricsWidgets(List<Group> lyrics) {
    List<Widget> widgets = [];
    for (var group in lyrics) {
      if (group.name == 'Refrão') {
        widgets.add(
          Text(
            group.data,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        widgets.add(
          Text(
            group.data,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        );
      }
      widgets.add(const SizedBox(height: 16.0));
    }
    return widgets;
  }

  String getPlainLyrics(List<Group> lyrics) {
    String text = '';
    for (var group in lyrics) {
      text += '${group.data}\n\n';
    }
    return text;
  }

  String getHtmlLyrics(List<Group> lyrics) {
    String text = '';
    for (var group in lyrics) {
      if (group.name == 'Refrão') {
        text += '<p><b>${group.data}</b></p>';
      } else {
        text += '<p>${group.data}</p>';
      }
      text += '<br/>';
    }
    return text;
  }
}
