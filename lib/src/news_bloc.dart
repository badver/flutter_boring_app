import 'package:flutter_boring_app/src/article.dart';
import 'package:flutter_boring_app/src/json_parsing.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:collection';
import 'package:http/http.dart' as http;

class NewsBloc {
  Stream<UnmodifiableListView<Article>> get articles => _articleSubject.stream;

  final _articleSubject = BehaviorSubject<UnmodifiableListView<Article>>();
  var _articles = <Article>[];

  NewsBloc() {
    _getArticles().then((_) {
      _articleSubject.add(UnmodifiableListView(_articles));
    });
  }

  List<int> _ids = [
    18672951,
    18682580,
    18678314,
    18684666,
    18674188,
    18665048,
    18681772,
    18667747,
    18681447,
    18674885,
    18667750,
    18685296
  ];

  Future<Null> _getArticles() async {
    final futureArticles = _ids.map((id) => _getArticle(id));
    _articles = await Future.wait(futureArticles);
  }

  Future<Article> _getArticle(int id) async {
    final url = 'https://hacker-news.firebaseio.com/v0/item/$id.json';
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return parseArticle(res.body);
    }
    return null;
  }
}
