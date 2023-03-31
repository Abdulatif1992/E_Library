import 'package:flutter/material.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

class DownloadAssetsDemo extends StatefulWidget {
  DownloadAssetsDemo() : super();

  final String title = "Download & Extract ZIP Demo";

  @override
  DownloadAssetsDemoState createState() => DownloadAssetsDemoState();
}

class DownloadAssetsDemoState extends State<DownloadAssetsDemo> {
  bool? _downloading;
  String? _dir;
  String title2 = 'Download and extract demo';
  List<String> _images = [], _tempImages = [];
  //String _zipPath = 'http://coderzheaven.com/youtube_flutter/images.zip';
  //String _zipPath = 'http://192.168.10.12:8080/download_books';
  String _zipPath = 'http://192.168.10.12:8080/api/images.zip';
  static final Map<String, String> httpHeaders = {
    HttpHeaders.contentTypeHeader: "application/zip",
    "Connection": "Keep-Alive",
    "Keep-Alive": "timeout=5, max=1000"
  };
  String _localZipFileName = 'images.zip';

  @override
  void initState() {
    super.initState();
    // _images = List.empty();
    // _tempImages = List.empty();
    _images = [];
    _tempImages = [];
    _downloading = false;
    title2 = 'Download and extract demo';
    _initDir();
  }

  _initDir() async {
    if (null == _dir) {
      _dir = (await getApplicationDocumentsDirectory()).path;
    }
  }

  Future<Tuple2<String?, File?>> _downloadFile(
      String url, String fileName) async {
    var req = await http.Client().get(Uri.parse(url), headers: httpHeaders);
    if (req.statusCode == 200) {
      var file = File('$_dir/$fileName');
      return Tuple2(null, await file.writeAsBytes(req.bodyBytes));
    } else {
      return Tuple2("e.toString()", null);
    }

    // try {
    //   var req = await http.Client().get(Uri.parse(url), headers: httpHeaders);
    //   if (req.statusCode == 200) {
    //     var file = File('$_dir/$fileName');
    //     return Tuple2(null, await file.writeAsBytes(req.bodyBytes));
    //   }

    //   throw 'error occured!';
    // } catch (e) {
    //   return Tuple2(e.toString(), null);
    // }
  }

  Future<void> _downloadZip() async {
    setState(() {
      _downloading = true;
      title2 = 'downloading';
    });
    _images.clear();
    _tempImages.clear();

    var zippedFile = await _downloadFile(_zipPath, _localZipFileName);

    if (zippedFile.item1 != null) {
      print('xato keldi yaramas');
    } else {
      print('keldi!!!');
      await unarchiveAndSave(zippedFile.item2);
      setState(() {
        _images.addAll(_tempImages);
        _downloading = false;
        title2 = 'yuklandi!!!';
        print(_images);
      });
    }
  }

  unarchiveAndSave(var zippedFile) async {
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var fileName = '$_dir/${file.name}';
      if (file.isFile) {
        var outFile = File(fileName);
        print('File::' + outFile.path);
        _tempImages.add(outFile.path);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
  }

  buildList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _images.length,
        itemBuilder: (BuildContext context, int index) {
          return Image.file(
            File(_images[index]),
            fit: BoxFit.fitWidth,
          );
        },
      ),
    );
  }

  progress() {
    return Container(
      width: 25,
      height: 25,
      padding: EdgeInsets.fromLTRB(0.0, 20.0, 10.0, 20.0),
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title2),
        actions: <Widget>[
          _downloading! ? progress() : Container(),
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
