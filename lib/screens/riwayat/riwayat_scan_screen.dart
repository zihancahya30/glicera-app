import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';
import '../../models/scan_result_model.dart';
import 'detail_scan_screen.dart';

class RiwayatScanScreen extends StatefulWidget {
  const RiwayatScanScreen({super.key});

  @override
  State<RiwayatScanScreen> createState() => _RiwayatScanScreenState();
}

class _RiwayatScanScreenState extends State<RiwayatScanScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final String userId = AuthService().currentUser?.id ?? '';
  int _selectedIndex = 2;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    final isOnline = await ConnectivityHelper.checkConnection();
    if (!mounted) return;

    setState(() {
      _isOnline = isOnline;
    });

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;
      setState(() {
        _isOnline = ConnectivityHelper.isOnlineResult(results);
      });
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/scan');
        break;
      case 2:
        // Already in Riwayat
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Skrining',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: !_isOnline
          ? _buildOfflineState()
          : FutureBuilder<List<ScanResultModel>>(
              future: _supabaseService.getScanHistory(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildEmptyState();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final results = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGrafikTren(results),
                      const SizedBox(height: 24),
                      const Text(
                        'Daftar Skrining',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...results.map((result) => _buildScanCard(result, results)),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: _buildInlineNavBar(),
    );
  }

  Widget _buildInlineNavBar() {
    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Beranda'),
      _NavItem(icon: Icons.camera_alt_outlined, activeIcon: Icons.camera_alt, label: 'Skrining'),
      _NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'Riwayat'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = _selectedIndex == index;
              return GestureDetector(
                onTap: () => _onNavItemTapped(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? items[index].activeIcon : items[index].icon,
                        color: isActive
                            ? const Color(0xFFFFC107)
                            : Colors.white.withValues(alpha: 0.7),
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFFFFC107)
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Riwayat Skrining',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lakukan skrining pertama untuk melihat riwayat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: AppColors.grey.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 24),
              const Text(
                'Riwayat membutuhkan koneksi internet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hubungkan internet untuk memuat hasil scan, grafik riwayat, dan gambar yang tersimpan di cloud.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrafikTren(List<ScanResultModel> results) {
    if (results.length < 2) return const SizedBox.shrink();

    // Sort by tanggal ascending
    final sortedResults = List<ScanResultModel>.from(results);
    sortedResults.sort((a, b) => a.tanggal.compareTo(b.tanggal));

    // Group by bulan dan ambil data terakhir setiap bulan
    final Map<String, ScanResultModel> monthlyData = {};
    for (var result in sortedResults) {
      final monthKey = DateFormat('yyyy-MM').format(result.tanggal);
      monthlyData[monthKey] = result; // Akan mengoverwrite dengan data terbaru bulan itu
    }

    // Ambil 6 bulan terakhir
    final sortedMonthlyKeys = monthlyData.keys.toList()..sort();
    final last6Months =
        sortedMonthlyKeys.length > 6 ? sortedMonthlyKeys.sublist(sortedMonthlyKeys.length - 6) : sortedMonthlyKeys;
    final monthlyResults = last6Months.map((key) => monthlyData[key]!).toList();

    if (monthlyResults.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
              decoration: BoxDecoration( // Mengganti withValues(alpha: 0.05) dengan withOpacity(0.05)
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Tren Risiko (Bulanan)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
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
                        if (value.toInt() >= 0 && value.toInt() < monthlyResults.length) {
                          final date = monthlyResults[value.toInt()].tanggal;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('MMM').format(date),
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
                barGroups: monthlyResults
                    .asMap()
                    .entries
                    .map((entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.risikoDiabetesPersen,
                              color: AppColors.primary,
                              width: 24,
                              borderRadius: BorderRadius.circular(6),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 100,
                                color: AppColors.primary.withValues(alpha: 0.08),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(ScanResultModel result, List<ScanResultModel> allResults) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScanScreen(
              result: result,
              allResults: allResults,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
          BoxShadow( // Mengganti withValues(alpha: 0.05) dengan withOpacity(0.05)
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          ],
        ),
        child: Row(
          children: [
            // Foto atau Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: result.isDiabetes
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.teal.withValues(alpha: 0.1),
              ),
              child: result.fotoUrl != null && result.fotoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        result.fotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.science_outlined,
                            color: result.isDiabetes
                                ? AppColors.error
                                : AppColors.teal,
                            size: 36,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.science_outlined,
                      color: result.isDiabetes ? AppColors.error : AppColors.teal,
                      size: 36,
                    ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
                        .format(result.tanggal),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.isDiabetes ? 'Diabetes' : 'Non-Diabetes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          result.isDiabetes ? AppColors.error : AppColors.teal,
                    ),
                  ),
                  Text(
                    'Probabilitas ${result.probabilitasPersen.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}
