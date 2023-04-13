import 'package:flutter/material.dart';
import 'package:pdfviewer01/models/document_model.dart';
import 'package:pdfviewer01/models/epub_model.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'dart:convert';

import '../models/book.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class EpubReaderScreen extends StatefulWidget {
  EpubReaderScreen(this.doc, {super.key});
  dynamic doc;

  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {

  @override
  void initState() {
    showepub();
    super.initState();
  }

  void showepub ()  async {
    int bookId = widget.doc.book_id; 
    dynamic? book  = await SessionManager().get("$bookId");  
    
    VocsyEpub.setConfig(
      //themeColor: Theme.of(context).primaryColor,
      identifier: "iosBook",
      scrollDirection: EpubScrollDirection.VERTICAL,
      allowSharing: true,
      enableTts: true,
      nightMode: false,
    );

    VocsyEpub.locatorStream.listen((locator) {
      //print('LOCATOR111-------------------------------------------------------: ${EpubLocator.fromJson(jsonDecode(locator))}');
      Map<String, dynamic> metabook = jsonDecode(locator);
      book = EpubBook(bookId: metabook['bookId'], href: metabook['href'], created: metabook['created'], clf: metabook['locations']['cfi']);
      SessionManager().set("${widget.doc.book_id}", book);      
    });

    if(book != null)
    {
      VocsyEpub.openAsset(
        widget.doc.doc_url,
        lastLocation: EpubLocator.fromJson(
          {
            "bookId": book['bookId'], 
            "href": book['href'],
            "created": book['created'],
            "locations": {"cfi": book['clf']}
          },
        ),
      );
    }
    else
    {
      VocsyEpub.openAsset(
        widget.doc.doc_url,
        lastLocation: EpubLocator.fromJson(
          {
            "bookId": "", 
            "href": "",
            "created": 1212,
            "locations": {"cfi": ""}
          },
        ),
      );
    }

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
