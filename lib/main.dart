import 'package:flutter/material.dart';
import 'package:flutter_boring_app/src/news_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';

import 'package:flutter_boring_app/src/article.dart';

void main() {
  final bloc = NewsBloc();
  runApp(MyApp(
    bloc: bloc,
  ));
}

class MyApp extends StatelessWidget {
  final NewsBloc bloc;

  MyApp({Key key, this.bloc}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Boring News App',
        bloc: this.bloc,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final NewsBloc bloc;

  MyHomePage({Key key, this.title, this.bloc}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<UnmodifiableListView<Article>>(
        stream: widget.bloc.articles,
        initialData: UnmodifiableListView<Article>([]),
        builder: (context, snapshot) => ListView(
              children: snapshot.data.map(_buildItem).toList(),
            ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                title: Text('Top Stories'), icon: Icon(Icons.arrow_drop_up)),
            BottomNavigationBarItem(
                title: Text('New Stories'), icon: Icon(Icons.new_releases)),
          ],
          onTap: (index) {
            if (index == 0) {
              print('Top clicked');
            } else {
              print('New clocked');
            }
          }),
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
