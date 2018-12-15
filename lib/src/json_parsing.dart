import 'package:flutter_boring_app/src/article.dart';
import 'dart:convert' as json;

List<int> parseTopStories(String jsonStr) {
  final parsed = json.jsonDecode(jsonStr);
  return List<int>.from(parsed);
}

Article parseArticle(String jsonStr) {
  final parsed = json.jsonDecode(jsonStr);
  return Article.fromJson(parsed);
}
