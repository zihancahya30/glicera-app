class EdukasiSectionModel {
  final String title;
  final String summary;      // singkat — tampil di kartu poin
  final String detail;       // panjang — tampil di penjelasan bawah
  final String image;

  EdukasiSectionModel({
    required this.title,
    required this.summary,
    required this.detail,
    required this.image,
  });
}

class EdukasiModel {
  final String id;
  final String title;
  final String color;
  final String image;
  final String description;
  final List<EdukasiSectionModel> sections;

  EdukasiModel({
    required this.id,
    required this.title,
    required this.color,
    required this.image,
    required this.description,
    required this.sections,
  });
}