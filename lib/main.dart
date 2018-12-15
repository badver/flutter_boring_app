import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<Article> _articles = articles;

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
        child: ListView.builder(
            itemCount: _articles.length,
            itemBuilder: (context, index) => _buildItem(_articles[index])),
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
