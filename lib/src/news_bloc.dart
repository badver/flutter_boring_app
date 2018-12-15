import 'dart:async';
import 'dart:collection';

import 'package:flutter_boring_app/src/article.dart';
import 'package:flutter_boring_app/src/json_parsing.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

enum StoriesType { topStories, newStories }

class NewsBloc {
  Stream<UnmodifiableListView<Article>> get articles => _articleSubject.stream;

  final _articleSubject = BehaviorSubject<UnmodifiableListView<Article>>();
  var _articles = <Article>[];

  Sink<StoriesType> get storiesType => _storiesTypeController.sink;
  final _storiesTypeController = StreamController<StoriesType>();

  NewsBloc() {
    _getArticlesAndUpdate(_topIds);

    _storiesTypeController.stream.listen((storiesType) {
      if (storiesType == StoriesType.newStories) {
        _getArticlesAndUpdate(_newIds);
      } else {
        _getArticlesAndUpdate(_topIds);
      }
    });
  }

  _getArticlesAndUpdate(ids) {
    _updateArticles(ids).then((_) {
      _articleSubject.add(UnmodifiableListView(_articles));
    });
  }

  static List<int> _topIds = [
    18672951,
    18682580,
    18678314,
    18684666,
    18674188,
    18665048,
  ];
  static List<int> _newIds = [
    18681772,
    18667747,
    18681447,
    18674885,
    18667750,
    18685296
  ];

  Future<Null> _updateArticles(List<int> ids) async {
    final futureArticles = ids.map((id) => _getArticle(id));
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
