import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/scan_result_model.dart';
import '../faskes/faskes_screen.dart';
import '../rutinitas/rutinitas_harian_screen.dart';

class HasilSkriningScreen extends StatelessWidget { 
  final ScanResultModel result;
  final File? imageFile;

  const HasilSkriningScreen({ 
    super.key, 
    required this.result, 
    this.imageFile, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          ),
        ),
        title: const Text(
          'Lihat Hasil Skrining',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            _buildProbabilityCircle(),

            const SizedBox(height: 24),

            Text(
              result.isDiabetes ? 'Diabetes' : 'Non-Diabetes',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: result.isDiabetes ? AppColors.error : AppColors.teal,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              result.isDiabetes
                  ? 'Hasil analisis menunjukkan indikasi yang mengarah ke diabetes dan perlu dikonfirmasi melalui pemeriksaan lanjutan.'
                  : 'Hasil analisis lebih mengarah ke non-diabetes, namun tetap disarankan menjaga pola hidup sehat dan melakukan pemantauan berkala.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '${result.labelRisikoDiabetes} diabetes: '
              '${result.risikoDiabetesPersen.toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.secondary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hasil ini bukan diagnosis medis. '
                      'Selalu konsultasikan dengan tenaga medis profesional '
                      'untuk pemeriksaan yang lebih akurat.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildPenjelasanProbabilitas(),

            const SizedBox(height: 20),

            _buildAnalisis(),

            const SizedBox(height: 20),

            _buildRekomendasi(),

            const SizedBox(height: 24),

            _buildActionButtons(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityCircle() {
    final persen = result.probabilitasPersen;
    final color = result.isDiabetes ? AppColors.error : AppColors.teal;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            result.isDiabetes ? 'Diabetes' : 'Non-Diabetes',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${persen.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const Text(
            'kecocokan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenjelasanProbabilitas() {
    return Container(
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
            'Apa Arti Angka Ini?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.ringkasanKecocokanModel,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            result.penjelasanProbabilitas,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalisis() {
    return Container(
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
            'Analisis',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...result.analisis.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRekomendasi() {
    return Container(
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
            'Rekomendasi',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...result.rekomendasi.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (result.isDiabetes)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FaskesScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Cari Fasilitas Kesehatan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        if (result.isDiabetes) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RutinitasHarianScreen(
                    hasScreening: true,
                    isDiabetes: result.isDiabetes,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Lihat Rutinitas Harian',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Kembali ke Dashboard',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
