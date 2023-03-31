import 'package:flutter/material.dart';
import 'package:pdfviewer01/models/document_model.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

import '../models/book.dart';

class ReaderScreen extends StatefulWidget {
  ReaderScreen(this.doc, {super.key});
  dynamic doc;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  String? url;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    getSession();
    url = widget.doc['doc_url'];
    super.initState();
  }

  void setSession() async {
    var page = _pdfViewerController.pageNumber;
    int bookId = widget.doc['book_id']!;
    Book book = Book(bookId: bookId, page: page);
    await SessionManager().set("$bookId", book);
  }

  void getSession() async {
    int bookId = widget.doc['book_id']!;
    dynamic book = await SessionManager().get("$bookId");
    //User u = User.fromJson(await SessionManager().get("user"));
    if (book != null) {
      _pdfViewerController.jumpToPage(book['page']);

      // int page = book['page'];
      // print("key bor $book page raqami esa $page");
    } else {
      // print("key yo'q bu kitobda");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(widget.doc['doc_title']!),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.article_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.zoom_in,
              color: Colors.white,
            ),
            onPressed: () {
              _pdfViewerController.zoomLevel = 1.2;
              getSession();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
            onPressed: () {
              _pdfViewerController.previousPage();
              setSession();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onPressed: () {
              _pdfViewerController.nextPage();
              setSession();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.bookmark,
              color: Colors.white,
            ),
            onPressed: () {
              setSession();
            },
          ),
        ],
      ),
      body: Container(
        child: SfPdfViewer.asset(
          key: _pdfViewerKey,
          url!,
          pageLayoutMode: PdfPageLayoutMode.single,
          //enableDoubleTapZooming: false,
          //initialScrollOffset: Offset(100, 10),
          //initialZoomLevel: 1.2,
          pageSpacing: 0,
          controller: _pdfViewerController,
        ),
      ),
    );
  }
}
