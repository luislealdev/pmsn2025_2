class SeriesDao {
  int seriesId;
  String url;
  String name;
  String title;
  String summary;
  String body;
  String kicker;
  String thumbUrl;
  String heroUrl;
  String titleUrl;
  String teaser;
  bool isMass;
  List<dynamic> shows;
  List<dynamic> tags;
  String platformPlayerId;
  bool hiddenFromApps;
  int relatedTagId;

  SeriesDao({
    required this.seriesId,
    required this.url,
    required this.name,
    required this.title,
    required this.summary,
    required this.body,
    required this.kicker,
    required this.thumbUrl,
    required this.heroUrl,
    required this.titleUrl,
    required this.teaser,
    required this.isMass,
    required this.shows,
    required this.tags,
    required this.platformPlayerId,
    required this.hiddenFromApps,
    required this.relatedTagId,
  });
  factory SeriesDao.fromMap(Map<String, dynamic> map) {
    return SeriesDao(
      seriesId: map['seriesId'] ?? '',
      url: map['url'] ?? '',
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      body: map['body'] ?? '',
      kicker: map['kicker'] ?? '',
      thumbUrl: map['thumbUrl'] ?? '',
      heroUrl: map['heroUrl'] ?? '',
      titleUrl: map['titleUrl'] ?? '',
      teaser: map['teaser'] ?? '',
      isMass: map['isMass'] ?? '',
      shows: map['shows'] ?? '',
      tags: map['tags'] ?? '',
      platformPlayerId: map['platformPlayerId'] ?? '',
      hiddenFromApps: map['hiddenFromApps'] ?? '',
      relatedTagId: map['relatedTagId'] ?? '',
    );
  }
}
