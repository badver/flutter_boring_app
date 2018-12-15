class Article {
  final String title;
  final String text;
  final String url;
  final String by;
  final String type;
  final int time;
  final int id;
  final int score;
  final int commentsCount;

  const Article({this.id, this.title, this.text,
    this.url,
    this.by,
    this.time,
    this.score,
    this.type,
    this.commentsCount});
}

final articles = [
  Article(
      by: "dhouston",
      score: 111,
      time: 1175714200,
      title: "My YC app: Dropbox - Throw away your USB drive",
      type: "story",
      url: "http://www.getdropbox.com/u/2/screencast.html"),
  Article(
      by: "norvig",
      id: 2921983,
      text: """
      Aw shucks, guys ... you make me blush with your compliments.<p>Tell you what, Ill make a deal: I'll keep writing if you keep reading. K?
      """
      time : 1314211127,
      type: "comment"
  )
];
