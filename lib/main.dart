import 'package:flutter/material.dart';
import 'package:pdfviewer01/main2.dart';
import 'package:pdfviewer01/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScrenn(),
      //home: DownloadAssetsDemo(),
      //home: DownloadAssetsDemo2(),
    );
  }
}
