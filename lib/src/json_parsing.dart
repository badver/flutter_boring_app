import 'dart:convert' as json;

import 'package:flutter_boring_app/src/article.dart';

import 'serializers.dart';

List<int> parseTopStories(String jsonStr) {
  final parsed = json.jsonDecode(jsonStr);
  return List<int>.from(parsed);
}

Article parseArticle(String jsonStr) {
  final parsed = json.jsonDecode(jsonStr);
  Article article = serializers.deserializeWith(Article.serializer, parsed);
  return article; // Article.fromJson(parsed);
}
