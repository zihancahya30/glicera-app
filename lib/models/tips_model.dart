class TipsSectionModel {
  final String title;
  final String summary;      // singkat — tampil di kartu poin
  final String detail;       // panjang — tampil di penjelasan bawah
  final String image;

  TipsSectionModel({
    required this.title,
    required this.summary,
    required this.detail,
    required this.image,
  });
}

class TipsModel {
  final String id;
  final String title;
  final String color;
  final String image;
  final String description;
  final List<TipsSectionModel> sections;

  TipsModel({
    required this.id,
    required this.title,
    required this.color,
    required this.image,
    required this.description,
    required this.sections,
  });
}