import 'dart:async';
import 'dart:collection';

import 'package:flutter_boring_app/src/article.dart';
import 'package:flutter_boring_app/src/json_parsing.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

enum StoriesType { topStories, newStories }

class NewsBloc {
  HashMap<int, Article> _cachedArticles;

  Stream<UnmodifiableListView<Article>> get articles => _articleSubject.stream;

  final _articleSubject = BehaviorSubject<UnmodifiableListView<Article>>();
  var _articles = <Article>[];

  Sink<StoriesType> get storiesType => _storiesTypeController.sink;
  final _storiesTypeController = StreamController<StoriesType>();

  Stream<bool> get isLoading => _isLoadingSubject.stream;
  final _isLoadingSubject = BehaviorSubject<bool>(seedValue: false);

  NewsBloc() {
    _cachedArticles = HashMap<int, Article>();
    _initializeArticles();

    _storiesTypeController.stream.listen((storiesType) async {
      _getArticlesAndUpdate(await _getIds(storiesType));
    });
  }

  Future<void> _initializeArticles() async {
    _getArticlesAndUpdate(await _getIds(StoriesType.topStories));
  }

  void close() {
    _storiesTypeController.close();
  }

  _getArticlesAndUpdate(List<int> ids) async {
    _isLoadingSubject.add(true);
    await _updateArticles(ids);
    _articleSubject.add(UnmodifiableListView(_articles));
    _isLoadingSubject.add(false);
  }

  Future<List<int>> _getIds(StoriesType type) async {
    final lastPart = type == StoriesType.topStories ? 'top' : 'new';
    final url = "$_baseUrl/${lastPart}stories.json";
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw ApiError('Stories $type not fetched');
    }
    return parseTopStories(res.body).take(20).toList();
  }

  Future<Null> _updateArticles(List<int> ids) async {
    final futureArticles = ids.map((id) => _getArticle(id));
    _articles = await Future.wait(futureArticles);
  }

  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0';

  Future<Article> _getArticle(int id) async {
    if (!_cachedArticles.containsKey(id)) {
      final url = '$_baseUrl/item/$id.json';
      final res = await http.get(url);
      if (res.statusCode == 200) {
        _cachedArticles[id] = parseArticle(res.body);
      } else {
        throw ApiError('Article $id could`t be fetched.');
      }
    }
    return _cachedArticles[id];
  }
}

class ApiError extends Error {
  final String message;

  ApiError(this.message);
}
