import 'package:flutter/material.dart';
import 'package:flutter_boring_app/src/json_parsing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'src/article.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Article> _articles = []; //articles;

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

  Future<Article> _getArticle(int id) async {
    final url = 'https://hacker-news.firebaseio.com/v0/item/$id.json';
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return parseArticle(res.body);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            if (_articles.isNotEmpty) _articles.removeAt(0);
          });
          return;
        },
        child: ListView(
          children: _ids
              .map(
                (id) => FutureBuilder<Article>(
                      future: _getArticle(id),
                      builder: (BuildContext context,
                          AsyncSnapshot<Article> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            return _buildItem(snapshot.data);
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildItem(Article article) {
    return ExpansionTile(
      key: Key(article.id.toString()),
      title: Text(article.title ?? "no title"),
      children: <Widget>[
        Wrap(
          runAlignment: WrapAlignment.spaceAround,
          alignment: WrapAlignment.spaceAround,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(article.text ?? "no text"),
            IconButton(
              icon: Icon(Icons.launch),
              color: Colors.red,
              onPressed: () async {
                await _launchURL(article.url);
              },
            )
          ],
        )
      ],
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Can`t launch');
      //throw 'Could not launch $url';
    }
  }
}
