import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/scan_result_model.dart';

class DetailScanScreen extends StatelessWidget {
  final ScanResultModel result;
  final List<ScanResultModel> allResults;

  const DetailScanScreen({
    super.key,
    required this.result,
    required this.allResults,
  });

  // Helper: Dapatkan color berdasarkan risk
  Color _getRiskColor() {
    final risk = result.risikoDiabetesPersen;
    if (risk >= 80) return AppColors.error;
    if (risk >= 60) return const Color(0xFFFF9800);
    if (risk >= 40) return const Color(0xFFFFC107);
    if (risk >= 20) return AppColors.success;
    return const Color(0xFF1B5E20);
  }

  // Helper: Dapatkan label risk
  String _getRiskLabel() {
    final risk = result.risikoDiabetesPersen;
    if (risk >= 80) return 'Risiko Tinggi';
    if (risk >= 60) return 'Risiko Sedang';
    if (risk >= 40) return 'Perlu Perhatian';
    if (risk >= 20) return 'Aman';
    return 'Sangat Aman';
  }

  // Helper: Dapatkan rekomendasi
  List<String> _getRecommendations() {
    final risk = result.risikoDiabetesPersen;
    if (result.isDiabetes) {
      if (risk >= 80) {
        return [
          '🏥 Konsultasi dengan dokter spesialis diabetes segera',
          '🥗 Kurangi makanan tinggi gula dan karbohidrat sederhana',
          '🚴 Olahraga teratur minimal 30 menit per hari',
          '💧 Minum air putih 8-10 gelas per hari',
          '📋 Periksa gula darah secara berkala',
        ];
      } else if (risk >= 60) {
        return [
          '⚠️ Konsultasi dengan dokter untuk follow-up',
          '🥗 Mulai ubah pola makan lebih sehat',
          '🚴 Tingkatkan aktivitas fisik',
          '⏰ Periksa gula darah 1x seminggu',
          '😴 Pastikan tidur 7-8 jam per malam',
        ];
      } else {
        return [
          '✅ Hasil bagus, jaga kondisi saat ini',
          '🥗 Lanjutkan pola makan sehat',
          '🚴 Terus olahraga secara rutin',
          '🔄 Periksa ulang dalam 3 bulan',
        ];
      }
    } else {
      if (risk <= 20) {
        return [
          '🎉 Kesehatan lidah sangat baik!',
          '✅ Terus jaga kesehatan mulut dengan baik',
          '🪥 Sikat gigi 2x sehari dengan pasta berguna',
          '💪 Lanjutkan gaya hidup sehat saat ini',
          '🔄 Periksa ulang dalam 6 bulan',
        ];
      } else if (risk <= 40) {
        return [
          '✅ Kesehatan lidah cukup baik',
          '🥗 Tingkatkan konsumsi sayur dan buah',
          '🚴 Olahraga 3-4x per minggu',
          '⏰ Periksa gula darah 1x per bulan',
          '🔄 Follow-up skrining dalam 2-3 bulan',
        ];
      } else {
        return [
          '⚠️ Mulai perhatikan kesehatan lebih serius',
          '🏥 Konsultasi dengan dokter umum',
          '🥗 Mulai program diet sehat',
          '🚴 Olahraga 4-5x per minggu',
          '🔄 Periksa ulang dalam 1 bulan',
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Hasil Skrining',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== SECTION 1: Hasil Scan ==========
            _buildHasilScan(),

            const SizedBox(height: 32),

            // ========== SECTION 2: Rekomendasi ==========
            _buildRekomendasi(),

            const SizedBox(height: 32),

            // ========== SECTION 3: Tren Perubahan ==========
            _buildTrenPerubahan(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHasilScan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto Scan
          if (result.fotoUrl != null && result.fotoUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                result.fotoUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 60,
                      color: AppColors.grey,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.science_outlined,
                size: 80,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
            ),

          const SizedBox(height: 24),

          // Hasil & Probabilitas
          const Text(
            'Hasil Penilaian',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.isDiabetes ? 'Diabetes' : 'Non-Diabetes',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getRiskColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRiskColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRiskLabel(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getRiskColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Circular Progress
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: result.probabilitasPersen / 100,
                      strokeWidth: 8,
                      backgroundColor: _getRiskColor().withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_getRiskColor()),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${result.probabilitasPersen.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Probabilitas',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Waktu scan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Waktu Skrining',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(result.tanggal),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRekomendasi() {
    final recommendations = _getRecommendations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rekomendasi & Saran',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...recommendations.map((rec) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                rec,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrenPerubahan() {
    // Hanya tampilkan jika ada minimal 2 scans
    if (allResults.length < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Perubahan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Butuh minimal 2 skrining untuk melihat tren',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Ambil maksimal 6 scan sampai scan yang sedang dibuka.
    final sortedAllResults = List<ScanResultModel>.from(allResults);
    sortedAllResults.sort((a, b) => a.tanggal.compareTo(b.tanggal));

    var currentIndex = sortedAllResults.indexWhere((r) => r.id == result.id);
    if (currentIndex == -1) {
      currentIndex = sortedAllResults.indexWhere((r) => r.tanggal == result.tanggal);
    }

    final chartEndIndex =
        currentIndex == -1 ? sortedAllResults.length : currentIndex + 1;
    final chartStartIndex = chartEndIndex > 6 ? chartEndIndex - 6 : 0;
    final recentResults =
        sortedAllResults.sublist(chartStartIndex, chartEndIndex);

    // Cari posisi current result dalam list
    var currentChartIndex = recentResults.indexWhere((r) => r.id == result.id);
    if (currentChartIndex == -1) {
      currentChartIndex =
          recentResults.indexWhere((r) => r.tanggal == result.tanggal);
    }
    final previousResult =
        currentChartIndex > 0 ? recentResults[currentChartIndex - 1] : null;

    // Hitung perubahan
    final riskChange = previousResult != null
        ? result.risikoDiabetesPersen - previousResult.risikoDiabetesPersen
        : 0.0;

    final isImproving = riskChange < 0;
    final isUnchanged = riskChange == 0;
    final changeText = isUnchanged
        ? 'Tidak berubah'
        : (isImproving
            ? '${riskChange.abs().toStringAsFixed(1)}% lebih baik'
            : '+${riskChange.toStringAsFixed(1)}% lebih tinggi');
    final trendColor = isUnchanged
        ? AppColors.textSecondary
        : (isImproving ? AppColors.success : AppColors.error);
    final trendIcon = isUnchanged
        ? Icons.trending_flat
        : (isImproving ? Icons.trending_down : Icons.trending_up);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tren Perubahan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Perubahan Summary
        if (previousResult != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isImproving
                  ? AppColors.success.withValues(alpha: 0.1)
                  : trendColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: trendColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  trendIcon,
                  color: trendColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perubahan dari skrining terakhir',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      changeText,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Chart Tren
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grafik Risiko Diabetes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < recentResults.length) {
                              final date = recentResults[value.toInt()].tanggal;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat('dd/MM').format(date),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: recentResults
                            .asMap()
                            .entries
                            .map((entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.risikoDiabetesPersen,
                                ))
                            .toList(),
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final isCurrentScan = index == currentChartIndex;
                            return FlDotCirclePainter(
                              radius: isCurrentScan ? 6 : 4,
                              color: isCurrentScan ? AppColors.primary : AppColors.primary,
                              strokeWidth: isCurrentScan ? 3 : 2,
                              strokeColor: AppColors.white,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Titik yang lebih besar = skrining saat ini',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Saran Aksi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Saran Aksi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isImproving
                    ? '✅ Kesehatan Anda menunjukkan perbaikan! Terus jaga momentum dengan mengikuti rekomendasi di atas.'
                    : '⚠️ Ada peningkatan risiko. Pertimbangkan untuk memperkuat rutinitas kesehatan dan berkonsultasi dengan dokter.',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
