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

  Stream<bool> get isLoading => _isLoadingSubject.stream;
  final _isLoadingSubject = BehaviorSubject<bool>(seedValue: false);

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

  void close() {
    _storiesTypeController.close();
  }

  _getArticlesAndUpdate(ids) async {
    _isLoadingSubject.add(true);
    await _updateArticles(ids);
    await Future.delayed(const Duration(milliseconds: 500));

    _articleSubject.add(UnmodifiableListView(_articles));
    _isLoadingSubject.add(false);
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
    throw ApiError('Article $id could`t be fetched.');
  }
}

class ApiError extends Error {
  final String message;

  ApiError(this.message);
}
