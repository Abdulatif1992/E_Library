import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfviewer01/models/epub_model.dart';
import 'package:pdfviewer01/screens/reader_screen.dart';
import 'package:pdfviewer01/screens/epubreader_screen.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//internet checker and overlay support
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';

import 'dart:convert';
import 'package:http/http.dart';

//it is for tuple function
import 'package:tuple/tuple.dart';

class HomeScrenn extends StatefulWidget {
  const HomeScrenn({super.key});

  @override
  State<HomeScrenn> createState() => _HomeScrennState();
}

class _HomeScrennState extends State<HomeScrenn> {
  var data = List<dynamic>.empty();
  var list = List<dynamic>.empty();
  bool hasInternet = false;

  void checkInternet() async {
    bool check = await InternetConnectionChecker().hasConnection;
    if (check) {
      var booksId = await getTuple();
      if (booksId.item2 == null) {
        List oldBooksId = [];
        for (var i = 0; i < list.length; i++) {
          oldBooksId.add(list[i]['book_id']);
        }
        //contains function tells us the list already has the element or not
        for (var i = 0; i < booksId.item1!.length; i++) {
          if (oldBooksId.contains(booksId.item1![i]) == false) {
            bool check = await getOneBook(booksId.item1![i]);
            print(
                'yes we have $i this id = ${booksId.item1![i]} and chck = $check');
          }
        }
      } else {
        print(booksId.item2);
      }
    } else {
      print('No Internet');
    }
  }

  Future<bool> getOneBook(int book_id) async {
    try {
      Response response = await post(
              Uri.http('192.168.10.12:8080', '/api/onebook/$book_id'),
              headers: {"Keep-Alive": "timeout=5, max=1"})
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        print(book_id);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Tuple2<List?, String?>> getTuple() async {
    try {
      Response response = await post(
              Uri.http('192.168.10.12:8080', '/api/booksid'),
              headers: {"Keep-Alive": "timeout=5, max=1"})
          .timeout(const Duration(seconds: 5));
      //print(response.statusCode);
      if (response.statusCode == 200) {
        List booksId = jsonDecode(response.body) as List;
        return Tuple2(booksId, null);
      } else {
        return Tuple2(null, 'xatolik response');
      }
    } catch (e) {
      return Tuple2(null, 'xatolik try');
    }
  }

  void getBooks() async {
    try {
      Response response =
          await post(Uri.http('192.168.10.12:8080', '/api/pdfbooks'));
      setState(() {
        data = jsonDecode(response.body) as List;
      });
      //print('mana shu $data');
    } catch (e) {
      print('caught error! $e');
      //time = 'couldn\'t get book data';
    }
  }

  Future<void> _openDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'example.db');
    print(databasesPath);

    Database db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Test (id INTEGER PRIMARY KEY, book_id INTEGER, doc_title VARCHAR(255), doc_url VARCHAR(255), base64 TEXT)');
    });

    // for (var i = 0; i < data.length; i++) {
    //   await db.transaction((txn) async {
    //     int id1 = await txn.rawInsert(
    //         'INSERT INTO Test(book_id, doc_title, doc_url, base64) VALUES(${data[i]['book_id']}, "${data[i]['doc_title']}", "${data[i]['doc_url']}", "${data[i]['base64']}")');
    //     //print('inserted1: $id1');
    //   });
    //   print(data[i]['book_id']);
    //   print(i);
    // }

    //Insert some records in a transaction
    // await db.transaction((txn) async {
    //   int id1 = await txn.rawInsert(
    //       'INSERT INTO Test(book_id, doc_title, doc_url, base64) VALUES(1245, "bu title", "bu esa url", "jfoijesiofhoihsfih/oieh")');
    //   //print('inserted1: $id1');
    // });

    //Get the records
    list = await db.rawQuery('SELECT * FROM Test');
    setState(() {
      list = list;
    });

    // Update some record
    // int count = await database.rawUpdate(
    //     'UPDATE Test SET name = ?, value = ? WHERE name = ?',
    //     ['updated name', '9876', 'some name']);
    // print('updated: $count');

    // await db.rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
    // assert(count == 1);

    // Close the database
    await db.close();
  }

  @override
  void initState() {
    //getBooks();
    _openDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      "PDF Books",
                      style: GoogleFonts.roboto(
                          fontSize: 28.0, fontWeight: FontWeight.bold),
                    ),
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Container(
                      child: Row(
                        children: list
                            .map(
                              (doc) => InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ReaderScreen(doc)));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  height: 200,
                                  width: 160,
                                  //color: Colors.grey,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(29),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(0, 10),
                                                blurRadius: 23,
                                                color: Color(0xFFD3D3D3)
                                                    .withOpacity(.84),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Image.memory(
                                        base64Decode(doc['base64']!),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 40,
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Text(
                                            doc['doc_title']!,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            //overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  //bumdan pasti boshqanarsa

                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      "EPUB Books",
                      style: GoogleFonts.roboto(
                          fontSize: 28.0, fontWeight: FontWeight.bold),
                    ),
                  ),

                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      checkInternet();
                    },
                    child: const Text('Funksiyani ishlatish'),
                  ),

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        hasInternet =
                            await InternetConnectionChecker().hasConnection;
                        final color = hasInternet ? Colors.green : Colors.red;
                        final text = hasInternet ? 'Internet' : 'No internet';

                        showSimpleNotification(
                          Text(
                            '$text',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          background: color,
                        );
                      },
                      child: Text('Check internet')),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Container(
                      child: Row(
                        children: Document2.doc_list2
                            .map(
                              (doc) => InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EpubReaderScreen(doc)));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  height: 200,
                                  width: 160,
                                  //color: Colors.grey,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(29),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(0, 10),
                                                blurRadius: 23,
                                                color: Color(0xFFD3D3D3)
                                                    .withOpacity(.84),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Image.memory(
                                        base64Decode(doc.base64!),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 40,
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Text(
                                            doc.doc_title!,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            //overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  Column(
                    children: list
                        .map(
                          (doc) => ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReaderScreen(doc)));
                            },
                            title: Text(
                              doc['doc_title'],
                              style: GoogleFonts.nunito(),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text('${doc['book_id']}'),
                            trailing: Text(
                              'doc.doc_date!',
                              style: GoogleFonts.nunito(color: Colors.grey),
                            ),
                            leading: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 32.0,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
