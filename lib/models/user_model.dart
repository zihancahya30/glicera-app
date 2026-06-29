class UserModel {
  final String uid;
  final String nama;
  final String email;
  final int? usia;
  final double? beratBadan;
  final double? tinggiBadan;
  final String? jenisKelamin;
  final String? riwayatKeluarga;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    this.usia,
    this.beratBadan,
    this.tinggiBadan,
    this.jenisKelamin,
    this.riwayatKeluarga,
    required this.createdAt,
    this.updatedAt,
  });

  // Hitung BMI
  double? get bmi {
    if (beratBadan != null && tinggiBadan != null && tinggiBadan! > 0) {
      double tinggiMeter = tinggiBadan! / 100;
      return beratBadan! / (tinggiMeter * tinggiMeter);
    }
    return null;
  }

  // Kategori BMI untuk Asia
  String get kategoriBmi {
    final bmiValue = bmi;
    if (bmiValue == null) return 'Tidak diketahui';
    if (bmiValue < 18.5) return 'Kurus';
    if (bmiValue < 23) return 'Normal';
    if (bmiValue < 25) return 'Kelebihan Berat';
    if (bmiValue < 30) return 'Obesitas I';
    return 'Obesitas II';
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is DateTime) {
        return value;
      } else if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return UserModel(
      uid: map['uid'] ?? map['id'] ?? '',
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      usia: parseInt(map['usia']),
      beratBadan: parseDouble(map['berat_badan'] ?? map['beratBadan']),
      tinggiBadan: parseDouble(map['tinggi_badan'] ?? map['tinggiBadan']),
      jenisKelamin: map['jenis_kelamin'] ?? map['jenisKelamin'],
      riwayatKeluarga: map['riwayat_keluarga'] ?? map['riwayatKeluarga'],
      createdAt: parseDateTime(map['created_at'] ?? map['createdAt']) ??
          DateTime.now(),
      updatedAt: parseDateTime(map['updated_at'] ?? map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'nama': nama,
      'email': email,
      'usia': usia,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'jenis_kelamin': jenisKelamin,
      'riwayat_keluarga': riwayatKeluarga,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? nama,
    String? email,
    int? usia,
    double? beratBadan,
    double? tinggiBadan,
    String? jenisKelamin,
    String? riwayatKeluarga,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      usia: usia ?? this.usia,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      riwayatKeluarga: riwayatKeluarga ?? this.riwayatKeluarga,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
