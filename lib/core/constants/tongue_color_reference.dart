// Nilai referensi rata-rata warna lidah dari analisis dataset
class TongueColorReference {
  // ============================================
  // DIABETES - Rata-rata dari 1050 foto (training set)
  // ============================================
  static const double diabetesAvgR = 143.44;
  static const double diabetesAvgG = 110.25;
  static const double diabetesAvgB = 105.78;
  static const double diabetesAvgBrightness = 119.67;
  static const double diabetesAvgRedness = 0.6610;

  // ============================================
  // NON-DIABETES - Rata-rata dari 1050 foto (training set)
  // ============================================
  static const double nonDiabetesAvgR = 149.01;
  static const double nonDiabetesAvgG = 112.24;
  static const double nonDiabetesAvgB = 117.06;
  static const double nonDiabetesAvgBrightness = 123.78;
  static const double nonDiabetesAvgRedness = 0.6470;

  // ============================================
  // THRESHOLD - Untuk perbandingan
  // ============================================
  static const double thresholdR = 20.0;
  static const double thresholdBrightness = 16.0;
  static const double thresholdRedness = 0.15;
  static const double thresholdSaturation = 20.0;
}
