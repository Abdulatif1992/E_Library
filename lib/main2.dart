import 'package:flutter/material.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

class DownloadAssetsDemo2 extends StatefulWidget {
  DownloadAssetsDemo2() : super();

  final String title = "Download & Extract ZIP Demo";

  @override
  DownloadAssetsDemo2State createState() => DownloadAssetsDemo2State();
}

class DownloadAssetsDemo2State extends State<DownloadAssetsDemo2> {
  String? _dir;

  @override
  void initState() {
    super.initState();
    _initDir();
  }

  _initDir() async {
    if (null == _dir) {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }
  }

  Future<File> downloadFile(String url, String filename) async {
    var request = await http.get(Uri.parse(url));
    var bytes = request.bodyBytes;
    var dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  void _downloadZip() async {
    File file = await downloadFile(
        'http://192.168.10.12:8080/api/images.zip', 'archive.zip');
    print('Fayl yuklandi: ${file.path}');
    //await unarchiveAndSave(file);
  }

  unarchiveAndSave(var zippedFile) async {
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var fileName = '$_dir/${file.name}';
      if (file.isFile) {
        var outFile = File(fileName);
        print('File::' + outFile.path);
        //_tempImages.add(outFile.path);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          //_downloading! ? progress() : Container(),
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {
              _downloadZip();
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            //buildList(),
          ],
        ),
      ),
    );
  }
}
