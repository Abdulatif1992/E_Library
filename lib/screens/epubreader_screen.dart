import 'package:flutter/material.dart';
import 'package:pdfviewer01/models/document_model.dart';
import 'package:pdfviewer01/models/epub_model.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'dart:convert';

class EpubReaderScreen extends StatefulWidget {
  EpubReaderScreen(this.doc, {super.key});
  Document2 doc;

  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    showepub();
    super.initState();
  }

  void showepub() {
    VocsyEpub.setConfig(
      //themeColor: Theme.of(context).primaryColor,
      identifier: "iosBook",
      scrollDirection: EpubScrollDirection.HORIZONTAL,
      allowSharing: true,
      enableTts: true,
      nightMode: false,
    );

    VocsyEpub.locatorStream.listen((locator) {
      print('LOCATOR: $locator');
      //print('Salomlar senga: $locator');
    });

    // VocsyEpub.locatorStream.listen((locator) {
    //   print('LOCATOR: ${EpubLocator.fromJson(jsonDecode(locator))}');
    //   // convert locator from string to json and save to your database to be retrieved later
    // });

    VocsyEpub.openAsset(
      'assets/epub/blyton-secret-of-moon-castle.epub',
      lastLocation: EpubLocator.fromJson(
        {
          "bookId": "879709878978",
          "href": "/OEBPS/ch08.xhtml",
          "created": 1539934158390,
          "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
