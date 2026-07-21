import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../core/constants/tongue_color_reference.dart';

class MLService {
  Interpreter? _interpreter; 
  bool _isInitialized = false; 
  String? _lastError; 

  static const int inputSize = 224; 
  static const int numChannels = 3;

  Future<void> initialize() async { 
    if (_isInitialized) return;

    const List<String> paths = [
      'assets/models/model_resnet50.tflite',  
      'models/model_resnet50.tflite',          
    ];

    String? lastError;
    
    for (final path in paths) { 
      try { 
        _interpreter = await Interpreter.fromAsset(path); 
        
        _isInitialized = true; 
        _lastError = null; 

        return; 
      } catch (e) { 

        lastError = e.toString(); 
        
        continue; 
      }
    }

    _isInitialized = false;
    _lastError = lastError;
    throw Exception('Gagal memuat model TFLite. $lastError');
  }

  Future<Map<String, dynamic>> predict(File imageFile) async { 
    if (!_isInitialized || _interpreter == null) { 
      try {
        await initialize();
      } catch (e) {
        return {
          'success': false,
          'error': 'Model tidak dapat diinisialisasi. Error: $_lastError',
        };
      }

      if (!_isInitialized) {
        return {
          'success': false,
          'error': 'Model tidak dapat diinisialisasi. Error: $_lastError',
        };
      }
    }

    try {
      final preprocessed = await _preprocessImage(imageFile);
      if (preprocessed == null) {
        return {'success': false, 'error': 'Gagal memproses gambar'};
      }

      final colorFeatures = await _extractColorFeatures(imageFile);

      final output = List.filled(1, 0.0).reshape([1, 1]);
      
      _interpreter!.run(preprocessed, output);

      final rawOutput = output[0][0] as double;

      final isDiabetes = rawOutput >= 0.5;
      
      final kategori = isDiabetes ? 'diabetes' : 'non-diabetes';
      
      final probDiabetes = rawOutput;          
      final probNonDiabetes = 1 - rawOutput;   

      final analisis = _generateAnalisis(
        isDiabetes,
        isDiabetes ? probDiabetes : probNonDiabetes,
        isDiabetes ? probNonDiabetes : probDiabetes,
        colorFeatures,
      );

      final rekomendasi = _generateRekomendasi(isDiabetes, probDiabetes);

      return {
        'success': true,
        'kategori': kategori,                                           
        'probabilitas': isDiabetes ? probDiabetes : probNonDiabetes,    
        'probDiabetes': probDiabetes,                                  
        'probNonDiabetes': probNonDiabetes,                             
        'analisis': analisis,                                           
        'rekomendasi': rekomendasi,                                     
      };
    } catch (e) {
      return {'success': false, 'error': 'Gagal melakukan analisis: $e'};
    }
  }

  Future<List<List<List<List<double>>>>?> _preprocessImage(
      File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;  

      final resized = img.copyResize(
        image,
        width: inputSize,       
        height: inputSize,       
        interpolation: img.Interpolation.linear,
      );

      final input = List.generate(
        1,  
        (b) => List.generate(
          inputSize,  
          (y) => List.generate(
            inputSize,  
            (x) {
              final pixel = resized.getPixel(x, y);
              
              return [
                pixel.b.toDouble() - 103.939,  
                pixel.g.toDouble() - 116.779,  
                pixel.r.toDouble() - 123.68,  
              ];
            },
          ),
        ),
      );

      return input;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, double>> _extractColorFeatures(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return {};

      final resized = img.copyResize(image, width: 64, height: 64);

      int startX = resized.width ~/ 4;      
      int endX = resized.width * 3 ~/ 4;
      int startY = resized.height ~/ 4;
      int endY = resized.height * 3 ~/ 4;

      double totalR = 0, totalG = 0, totalB = 0;
      int pixelCount = 0;  

      for (int y = startY; y < endY; y++) {
        for (int x = startX; x < endX; x++) {
          final pixel = resized.getPixel(x, y);
          
          totalR += pixel.r;
          totalG += pixel.g;
          totalB += pixel.b;
          
          pixelCount++;
        }
      }

      if (pixelCount == 0) return {};

      final avgR = totalR / pixelCount;
      final avgG = totalG / pixelCount;
      final avgB = totalB / pixelCount;
      
      final brightness = (avgR * 0.299 + avgG * 0.587 + avgB * 0.114);

      final redness = avgR / (avgG + avgB + 1);

      return {
        'avgR': avgR,          
        'avgG': avgG,          
        'avgB': avgB,          
        'brightness': brightness,  
        'redness': redness,        
      };
    } catch (e) {
      return {};
    }
  }

  List<String> _generateAnalisis(
    bool isDiabetes,
    double probabilitasKategori, 
    double probabilitasKebalikan, 
    Map<String, double> colorFeatures,
  ) {
    List<String> analisis = [];
    final persenKategori = (probabilitasKategori * 100).toStringAsFixed(1); 
    final persenKebalikan = (probabilitasKebalikan * 100).toStringAsFixed(1); 
    final kategoriUtama = isDiabetes ? 'Diabetes' : 'Non-Diabetes';
    final kategoriAlternatif = isDiabetes ? 'Non-Diabetes' : 'Diabetes';

    analisis.add(
      'Hasil analisis lebih mengarah ke kategori $kategoriUtama '
      'dengan probabilitas $persenKategori%.',
    );

    analisis.add(
      'Kemungkinan ke arah $kategoriAlternatif pada citra ini lebih rendah, yaitu $persenKebalikan%.',
    );

    if (colorFeatures.isNotEmpty) {
      final userR = colorFeatures['avgR'] ?? 0;
      final userBrightness = colorFeatures['brightness'] ?? 0;
      final userRedness = colorFeatures['redness'] ?? 0;

      final refR = isDiabetes
          ? TongueColorReference.diabetesAvgR
          : TongueColorReference.nonDiabetesAvgR;
      final refBrightness = isDiabetes
          ? TongueColorReference.diabetesAvgBrightness
          : TongueColorReference.nonDiabetesAvgBrightness;

      final rDiff = (userR - refR).abs();
      if (rDiff <= TongueColorReference.thresholdR) {
        if (isDiabetes && userR < TongueColorReference.nonDiabetesAvgR) {
          analisis.add(
            'Intensitas warna merah pada lidah (${userR.toStringAsFixed(0)}) '
            'cenderung lebih rendah dibanding rata-rata Non-Diabetes '
            '(${TongueColorReference.nonDiabetesAvgR.toStringAsFixed(0)}), '
            'mendekati profil Diabetes (${TongueColorReference.diabetesAvgR.toStringAsFixed(0)})',
          );
        } else if (!isDiabetes) {
          analisis.add(
            'Intensitas warna lidah (${userR.toStringAsFixed(0)}) '
            'mendekati profil rata-rata Non-Diabetes '
            '(${TongueColorReference.nonDiabetesAvgR.toStringAsFixed(0)})',
          );
        }
      }

      final brightDiff = (userBrightness - refBrightness).abs();
      if (brightDiff <= TongueColorReference.thresholdBrightness) {
        analisis.add(
          'Kecerahan gambar lidah (${userBrightness.toStringAsFixed(0)}) '
          'konsisten dengan profil ${isDiabetes ? "Diabetes" : "Non-Diabetes"} '
          '(rata-rata: ${refBrightness.toStringAsFixed(0)})',
        );
      } else if (userBrightness < 80) {
        analisis.add(
          'Kecerahan gambar rendah (${userBrightness.toStringAsFixed(0)}), '
          'disarankan foto ulang dengan pencahayaan lebih baik',
        );
      }

      final refRedness = isDiabetes
          ? TongueColorReference.diabetesAvgRedness
          : TongueColorReference.nonDiabetesAvgRedness;
      final rednessDiff = (userRedness - refRedness).abs();
      if (rednessDiff <= TongueColorReference.thresholdRedness) {
        analisis.add(
          'Rasio warna merah (${userRedness.toStringAsFixed(2)}) '
          'sesuai profil ${isDiabetes ? "Diabetes" : "Non-Diabetes"} '
          '(rata-rata: ${refRedness.toStringAsFixed(2)})',
        );
      }
    }

    analisis.add(
      'Analisis berbasis perbandingan dengan dataset citra lidah. '
      'BUKAN pemeriksaan klinis. Wajib konfirmasi ke dokter.',
    );

    return analisis;
  }

  List<String> _generateRekomendasi(bool isDiabetes, double probabilitas) {
    if (isDiabetes) {
      return [
        'SEGERA konsultasikan dengan dokter atau tenaga medis',
        'Lakukan pemeriksaan gula darah (GDP, GDS, atau HbA1c)',
        'Kunjungi puskesmas atau rumah sakit terdekat',
        'Mulai terapkan pola makan rendah gula dan karbohidrat',
        'Tingkatkan aktivitas fisik minimal 30 menit per hari',
        'Jangan mengonsumsi obat tanpa resep dokter',
        'Catat gejala yang dirasakan untuk dilaporkan ke dokter',
        'Hasil ini BUKAN diagnosis medis, wajib konfirmasi ke dokter',
      ];
    } else {
      return [
        'Pertahankan gaya hidup sehat yang sudah baik',
        'Lanjutkan pola makan seimbang dan bergizi',
        'Tetap aktif berolahraga minimal 30 menit per hari',
        'Minum air putih minimal 8 gelas per hari',
        'Lakukan skrining ulang secara berkala (3-6 bulan)',
        'Konsultasi rutin ke dokter minimal 1 tahun sekali',
        'Monitor berat badan dan tekanan darah secara rutin',
        'Hasil ini BUKAN diagnosis medis, tetap konsultasi dokter',
      ];
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}