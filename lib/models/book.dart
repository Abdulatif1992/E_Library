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
