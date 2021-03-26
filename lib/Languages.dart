class Language {
  String ext;
  dynamic chars;

  Language({required this.ext, required this.chars});

  Map<String, dynamic> toJSONEncodable() {
    var m = <String, dynamic>{};

    m['ext'] = ext;
    m['chars'] = chars;
    return m;
  }
}

class Languages {
  List<Language> items = [];

  List toJSONEncodable() {
    return items.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}