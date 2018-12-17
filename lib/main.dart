import 'package:flutter/material.dart';
import 'package:flutter_boring_app/src/news_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          canvasColor: Colors.black,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
              subhead: TextStyle(fontFamily: 'PatuaOne'),
              caption: TextStyle(color: Colors.white54))),
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
  int _currentIndex = 0;

  @override
  void dispose() {
    widget.bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(widget.title),
        leading: LoadingInfo(widget.bloc.isLoading),
      ),
      body: StreamBuilder<UnmodifiableListView<Article>>(
        stream: widget.bloc.articles,
        initialData: UnmodifiableListView<Article>([]),
        builder: (context, snapshot) => ListView(
              children: snapshot.data.map(_buildItem).toList(),
            ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
                title: Text('Top Stories'), icon: Icon(Icons.arrow_drop_up)),
            BottomNavigationBarItem(
                title: Text('New Stories'), icon: Icon(Icons.new_releases)),
          ],
          onTap: (index) {
            if (index == 0) {
              widget.bloc.storiesType.add(StoriesType.topStories);
            } else {
              widget.bloc.storiesType.add(StoriesType.newStories);
            }
            setState(() {
              _currentIndex = index;
            });
          }),
    );
  }

  Widget _buildItem(Article article) {
    return Padding(
      key: Key(article.id.toString()),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      child: ExpansionTile(
        title: Text(
          article.title ?? "no title",
          style: TextStyle(fontSize: 24.0),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('${article.descendants} comments'),
                SizedBox(
                  width: 16.0,
                ),
                IconButton(
                  icon: Icon(Icons.launch),
                  color: Colors.red,
                  onPressed: () async {
                    await _launchURL(article.url);
                  },
                )
              ],
            ),
          )
        ],
      ),
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

class LoadingInfo extends StatefulWidget {
  final Stream<bool> _isLoading;

  LoadingInfo(this._isLoading);

  @override
  State<StatefulWidget> createState() => LoadingInfoState();
}

class LoadingInfoState extends State<LoadingInfo>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget._isLoading,
        builder: (BuildContext context, AsyncSnapshot<bool> loading) {
          if (loading.hasData && loading.data) {
            _controller.forward();
          } else {
            _controller.reverse();
          }

          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeIn,
              ),
            ),
            child: Icon(
              FontAwesomeIcons.hackerNews,
              color: Colors.white,
            ),
          );
        });
  }
}
