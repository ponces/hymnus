import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as html2pdf;
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _exportPdf(context),
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
              child: Text(
                widget.lyrics,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    var tmpDir = (await getTemporaryDirectory()).path;
    var filename = getFilename(widget.title);
    var html = '''<!DOCTYPE html>
    <html>
      <head>
        <title>${widget.title}</title>
      </head>
      <body>
        <center>
            <h1>${widget.title}</h1>
        </center>
        <br/>
        <br/>
        <font size="5">''';
    html += widget.lyrics.replaceAll('\n', '<br/>');
    html += '''</font>
      </body>
    </html>''';
    var pdfFile = kIsWeb ? File(filename) : File('$tmpDir/$filename');
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
}
