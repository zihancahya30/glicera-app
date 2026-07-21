class ScanResultModel {
  final String id;
  final String userId;
  final DateTime tanggal;
  final String kategori; 
  final double probabilitas; 
  final String? fotoUrl;
  final String? fotoPath; 
  final List<String> analisis;
  final List<String> rekomendasi;

  ScanResultModel({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.kategori,
    required this.probabilitas,
    this.fotoUrl,
    this.fotoPath,
    required this.analisis,
    required this.rekomendasi,
  });

  double get probabilitasPersen => probabilitas * 100;

  bool get isDiabetes => kategori == 'diabetes';

  double get risikoDiabetesPersen {
    final persen = probabilitasPersen;
    return isDiabetes ? persen : 100 - persen;
  }

  String get labelKecocokanModel {
    final persen = probabilitasPersen;
    if (persen >= 80) return 'Kecocokan sangat kuat';
    if (persen >= 60) return 'Kecocokan cukup kuat';
    return 'Kecocokan perlu ditafsirkan hati-hati';
  }

  String get labelRisikoDiabetes {
    final risk = risikoDiabetesPersen;
    if (risk >= 80) return 'Risiko tinggi';
    if (risk >= 60) return 'Risiko sedang';
    if (risk >= 40) return 'Perlu perhatian';
    if (risk >= 20) return 'Risiko rendah';
    return 'Risiko sangat rendah';
  }

  String get ringkasanKecocokanModel {
    final persen = probabilitasPersen.toStringAsFixed(0);
    final kategoriHasil = isDiabetes ? 'diabetes' : 'non-diabetes';
    final risk = risikoDiabetesPersen.toStringAsFixed(0); 

    return 'Angka $persen% menunjukkan seberapa kuat pola pada foto lidah cocok '
        'dengan kategori $kategoriHasil menurut model. Ini bukan peluang pasti '
        'Anda terkena diabetes. Untuk pemantauan, aplikasi menampilkan perkiraan '
        'risiko diabetes sebesar $risk%.';
  }

  String get labelProbabilitas {
    final persen = probabilitasPersen;
    if (isDiabetes) {
      if (persen >= 80) return 'Risiko Sangat Tinggi';
      if (persen >= 60) return 'Risiko Tinggi';
      return 'Risiko Sedang';
    } else {
      if (persen >= 80) return 'Indikasi Sangat Rendah';
      if (persen >= 60) return 'Indikasi Rendah';
      return 'Perlu Perhatian';
    }
  }

  String get penjelasanProbabilitas {
    final persen = probabilitasPersen;
    final risk = risikoDiabetesPersen;

    if (isDiabetes) {
      if (persen >= 80) {
        return 'Pola pada foto lidah sangat cocok dengan kategori diabetes menurut model. '
            'Tingkat kecocokannya ${persen.toStringAsFixed(0)}%, sehingga hasil ini perlu '
            'ditindaklanjuti dengan pemeriksaan kesehatan yang lebih akurat.';
      } else if (persen >= 60) {
        return 'Pola pada foto lidah cukup cocok dengan kategori diabetes menurut model. '
            'Tingkat kecocokannya ${persen.toStringAsFixed(0)}%, sehingga hasil ini sebaiknya '
            'dipantau dan dikonfirmasi lebih lanjut.';
      } else {
        return 'Model memilih kategori diabetes, tetapi tingkat kecocokannya '
            '${persen.toStringAsFixed(0)}%. Artinya hasil ini perlu ditafsirkan hati-hati '
            'dan tidak dapat digunakan sebagai diagnosis medis.';
      }
    } else {
      if (persen >= 80) {
        return 'Pola pada foto lidah sangat cocok dengan kategori non-diabetes menurut model. '
            'Tingkat kecocokannya ${persen.toStringAsFixed(0)}%. Perkiraan risiko diabetes '
            'yang dipakai untuk pemantauan adalah ${risk.toStringAsFixed(0)}%.';
      } else if (persen >= 60) {
        return 'Pola pada foto lidah cukup cocok dengan kategori non-diabetes menurut model. '
            'Tingkat kecocokannya ${persen.toStringAsFixed(0)}%. Tetap pantau perubahan '
            'secara berkala dan jaga pola hidup sehat.';
      } else {
        return 'Model memilih kategori non-diabetes, tetapi tingkat kecocokannya '
            '${persen.toStringAsFixed(0)}%. Hasil seperti ini perlu ditafsirkan hati-hati '
            'dan sebaiknya dipantau ulang.';
      }
    }
  }

  factory ScanResultModel.fromMap(Map<String, dynamic> map) {
    DateTime parseTanggal(dynamic value) {
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return ScanResultModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? map['userId'] ?? '',
      tanggal: parseTanggal(map['tanggal']),
      kategori: map['kategori'] ?? 'non-diabetes',
      probabilitas: (map['probabilitas'] ?? 0.0).toDouble(),
      fotoUrl: map['foto_url'] ?? map['fotoUrl'],
      fotoPath: map['foto_path'] ?? map['fotoPath'],
      analisis: List<String>.from(map['analisis'] ?? []),
      rekomendasi: List<String>.from(map['rekomendasi'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tanggal': tanggal.millisecondsSinceEpoch,
      'kategori': kategori,
      'probabilitas': probabilitas,
      'foto_url': fotoUrl,
      'foto_path': fotoPath,
      'analisis': analisis,
      'rekomendasi': rekomendasi,
    };
  }
}
