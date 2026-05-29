class WikipediaPage {
  final int id;
  final String title;
  final String text;
  final String? thumb;
  final List<String> categories;
  final List<int> links;
  final Set<String> allCategories;

  WikipediaPage({
    required this.id,
    required this.title,
    required this.text,
    this.thumb,
    required this.categories,
    required this.links,
    required this.allCategories,
  });

  factory WikipediaPage.fromJsonList(List<dynamic> json, Set<String> computedAllCategories) {
    return WikipediaPage(
      title: json[0] as String,
      id: json[1] as int,
      text: json[2] as String,
      thumb: json[3] as String?,
      categories: List<String>.from(json[4] as List),
      links: List<int>.from(json[5] as List),
      allCategories: computedAllCategories,
    );
  }

  factory WikipediaPage.fromSqlMap(Map<String, dynamic> map, Set<String> computedAllCategories) {
    String content = map['text'] as String;
    // Truncate for feed preview to save memory; full text is loaded in WebView if needed
    if (content.length > 1000) {
      content = '${content.substring(0, 1000)}...';
    }

    return WikipediaPage(
      id: map['id'] as int,
      title: map['title'] as String,
      text: content,
      thumb: map['thumb'] as String?,
      categories: (map['categories'] as String).split(','),
      links: (map['links'] as String).split(',').where((e) => e.isNotEmpty).map(int.parse).toList(),
      allCategories: computedAllCategories,
    );
  }

  Map<String, dynamic> toSqlMap(String serializedAllCategories) {
    return {
      'id': id,
      'title': title,
      'text': text,
      'thumb': thumb,
      'categories': categories.join(','),
      'links': links.join(','),
      'all_categories': serializedAllCategories,
    };
  }
}
