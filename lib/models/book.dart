class Book {
  final int? bookId;
  final int? page;

  Book({this.bookId, this.page});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> book = Map<String, dynamic>();
    book["bookId"] = bookId;
    book["page"] = page;
    return book;
  }
}

class EpubBook {
  String? bookId;
  String? href;
  int? created;
  String? clf;

  EpubBook({this.bookId, this.href, this.created, this.clf});  

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> book = Map<String, dynamic>();
    book["bookId"] = bookId;
    book["href"] = href;
    book["created"] = created;
    book["clf"] = clf;
    return book;
  }
}
