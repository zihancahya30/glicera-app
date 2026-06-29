import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../models/user_model.dart';
import '../../models/scan_result_model.dart';
import '../rutinitas/rutinitas_harian_screen.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';
import '../../main.dart' as app;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  int _selectedIndex = 0;
  UserModel? _currentUser;
  ScanResultModel? _latestScan;
  bool _isLoading = true;
  bool _isOnline = true;
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null) {
        app.routeObserver.subscribe(this, route as PageRoute<dynamic>);
      }
    });
  }

  @override
  void didPopNext() {
    setState(() => _selectedIndex = 0);
    _loadUserData();
  }

  @override
  void didPush() {}

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    app.routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    final isOnline = await ConnectivityHelper.checkConnection();
    if (!mounted) return;
    setState(() => _isOnline = isOnline);
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;
      setState(() => _isOnline = ConnectivityHelper.isOnlineResult(results));
    });
  }

  void _showOnlineFeatureMessage({String featureName = 'Fitur ini'}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Butuh koneksi internet',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '$featureName tersedia saat perangkat terhubung ke internet.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Mengerti',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final currentUser = await _authService.getUserData(user.id);
      final latestScan = await _supabaseService.getLatestScan(user.id);
      if (mounted) {
        setState(() {
          _currentUser = currentUser;
          _latestScan = latestScan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        setState(() => _selectedIndex = index);
        break;
      case 1:
        if (!_isOnline) {
          _showOnlineFeatureMessage(featureName: 'Skrining');
          return;
        }
        setState(() => _selectedIndex = index);
        Navigator.pushNamed(context, '/scan');
        break;
      case 2:
        setState(() => _selectedIndex = index);
        Navigator.pushNamed(context, '/riwayat');
        break;
      case 3:
        setState(() => _selectedIndex = index);
        Navigator.pushNamed(context, '/profil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildCustomNavBar(),
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 20),

                    // ── MENU GRID — pakai Column+Row agar tinggi card fleksibel ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Baris 1
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _buildMenuCard(
                                    imageAsset: 'assets/images/ikon_tips.png',
                                    title: 'Tips Harian',
                                    subtitle: 'Dapatkan tips sehat setiap hari',
                                    accentColor: const Color(0xFF42A5F5),
                                    bgColor: const Color(0xFFE3F2FD),
                                    onTap: () =>
                                        Navigator.pushNamed(context, '/tips'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildMenuCard(
                                    imageAsset:
                                        'assets/images/ikon_rutinitas.png',
                                    title: 'Rutinitas Sehat',
                                    subtitle:
                                        'Kelola rutinitas dan kebiasaanmu',
                                    accentColor: const Color(0xFF26C6DA),
                                    bgColor: const Color(0xFFE0F7FA),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RutinitasHarianScreen(
                                            hasScreening: _latestScan != null,
                                            isDiabetes:
                                                _latestScan?.isDiabetes ??
                                                    false,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Baris 2
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _buildMenuCard(
                                    imageAsset:
                                        'assets/images/ikon_edukasi.png',
                                    title: 'Edukasi Diabetes',
                                    subtitle:
                                        'Belajar seputar diabetes & kesehatan',
                                    accentColor: const Color(0xFF7E57C2),
                                    bgColor: const Color(0xFFEDE7F6),
                                    onTap: () => Navigator.pushNamed(
                                        context, '/edukasi'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildMenuCard(
                                    imageAsset:
                                        'assets/images/ikon_faskes.png',
                                    title: 'Rekomendasi Faskes',
                                    subtitle:
                                        'Rekomendasi fasilitas kesehatan untukmu',
                                    accentColor: const Color(0xFFEF5350),
                                    bgColor: const Color(0xFFFFEBEE),
                                    onTap: () => Navigator.pushNamed(
                                        context, '/faskes'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_isOnline) {
                              _showOnlineFeatureMessage(
                                  featureName: 'Skrining');
                              return;
                            }
                            Navigator.pushNamed(context, '/scan');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isOnline
                                ? const Color(0xFFFFC107)
                                : AppColors.grey.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: _isOnline ? 4 : 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: _isOnline
                                    ? const Color(0xFF0D47A1)
                                    : AppColors.textSecondary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Mulai Skrining Sekarang',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _isOnline
                                      ? const Color(0xFF0D47A1)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CUSTOM BOTTOM NAV BAR
  // ─────────────────────────────────────────────────────────────────
  Widget _buildCustomNavBar() {
    final items = [
      _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Beranda'),
      _NavItem(
          icon: Icons.camera_alt_outlined,
          activeIcon: Icons.camera_alt,
          label: 'Skrining'),
      _NavItem(
          icon: Icons.history_outlined,
          activeIcon: Icons.history,
          label: 'Riwayat'),
      _NavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profil'),
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
                        isActive
                            ? items[index].activeIcon
                            : items[index].icon,
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
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
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

  // ─────────────────────────────────────────────────────────────────
  // HEADER SECTION
  // ─────────────────────────────────────────────────────────────────
  Widget _buildHeaderSection() {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 52),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B6E),
              Color(0xFF1A3A9F),
              Color(0xFF2979FF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 2),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth),
                                child: Text(
                                  _currentUser?.nama ?? 'User',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/pengaturan',
                      arguments: 3, // selalu tab Profil (index 3)
                    ),
                    icon: const Icon(Icons.settings,
                        color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Yuk mulai jaga kesehatanmu hari ini!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.90),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: _buildHealthScoreCard(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HEALTH SCORE CARD
  // ─────────────────────────────────────────────────────────────────
  Widget _buildHealthScoreCard() {
    if (_latestScan == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HEALTH SCORE',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '0%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E9E9E)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Belum ada data',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Lakukan skrining pertama untuk mengetahui risiko kesehatan Anda',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.0,
                        strokeWidth: 7,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF9E9E9E)),
                      ),
                      const Text(
                        '0%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final probability = _latestScan!.risikoDiabetesPersen;
    final isDiabetes = _latestScan!.isDiabetes;

    Color progressColor;
    Color badgeColor;
    Color badgeTextColor;
    String statusMessage;
    String statusSubtitle;

    if (isDiabetes) {
      if (probability >= 80) {
        progressColor = const Color(0xFFD32F2F);
        badgeColor = const Color(0xFFD32F2F).withValues(alpha: 0.12);
        badgeTextColor = const Color(0xFFD32F2F);
        statusMessage = 'Risiko Sangat Tinggi';
        statusSubtitle = 'Segera konsultasi dengan dokter';
      } else if (probability >= 60) {
        progressColor = const Color(0xFFF57C00);
        badgeColor = const Color(0xFFF57C00).withValues(alpha: 0.12);
        badgeTextColor = const Color(0xFFF57C00);
        statusMessage = 'Risiko Tinggi';
        statusSubtitle = 'Tingkatkan aktivitas kesehatan';
      } else {
        progressColor = const Color(0xFFFBC02D);
        badgeColor = const Color(0xFFFBC02D).withValues(alpha: 0.15);
        badgeTextColor = const Color(0xFFF9A825);
        statusMessage = 'Risiko Sedang';
        statusSubtitle = 'Tetap jaga pola hidup sehat';
      }
    } else {
      if (probability <= 20) {
        progressColor = const Color(0xFF2E7D32);
        badgeColor = const Color(0xFF2E7D32).withValues(alpha: 0.12);
        badgeTextColor = const Color(0xFF2E7D32);
        statusMessage = 'Risiko Sangat Rendah';
        statusSubtitle = 'Pertahankan gaya hidup sehat Anda';
      } else if (probability <= 40) {
        progressColor = const Color(0xFF43A047);
        badgeColor = const Color(0xFF43A047).withValues(alpha: 0.12);
        badgeTextColor = const Color(0xFF2E7D32);
        statusMessage = 'Risiko Rendah';
        statusSubtitle = 'Terus jaga kesehatan dengan baik';
      } else {
        progressColor = const Color(0xFF1976D2);
        badgeColor = const Color(0xFF1976D2).withValues(alpha: 0.12);
        badgeTextColor = const Color(0xFF1565C0);
        statusMessage = 'Risiko Sedang';
        statusSubtitle = 'Perbanyak aktivitas fisik dan diet sehat';
      }
    }

    final tanggalScan = DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
        .format(_latestScan!.tanggal);
    final tanggalScanSingkat =
        DateFormat('dd MMM, HH:mm', 'id_ID').format(_latestScan!.tanggal);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 340;
              final dateChip = _buildLastScanChip(
                  isCompact ? tanggalScanSingkat : tanggalScan);
              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('HEALTH SCORE',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Color(0xFF1A237E),
                        )),
                    const SizedBox(height: 6),
                    dateChip,
                  ],
                );
              }
              return Row(
                children: [
                  const Text('HEALTH SCORE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF1A237E),
                      )),
                  const Spacer(),
                  Flexible(child: dateChip),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 340;
              final circleSize = isCompact ? 84.0 : 100.0;
              final progressSize = isCompact ? 66.0 : 80.0;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${probability.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: isCompact ? 30 : 36,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A237E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusMessage,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: circleSize,
                    height: circleSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: progressSize,
                          height: progressSize,
                          child: CircularProgressIndicator(
                            value: probability / 100,
                            strokeWidth: 7,
                            backgroundColor:
                                progressColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                progressColor),
                          ),
                        ),
                        Text(
                          '${probability.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: isCompact ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isDiabetes
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline,
                  color: badgeTextColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusSubtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: badgeTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastScanChip(String tanggalScan) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1A237E).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Text(
        'Terakhir: $tanggalScan',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          color: Color(0xFF1A237E),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // MENU CARD
  // Card putih full dengan gradasi warna halus.
  // Tinggi mengikuti konten karena pakai IntrinsicHeight di parent.
  // ─────────────────────────────────────────────────────────────────
  Widget _buildMenuCard({
    required String imageAsset,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Color bgColor,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled
          ? onTap
          : () => _showOnlineFeatureMessage(featureName: title),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.55,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                bgColor.withValues(alpha: 0.55),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // tinggi mengikuti konten
            children: [
              // Ikon dari asset Figma (sudah include background)
              Image.asset(
                imageAsset,
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_outlined,
                  size: 56,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                // Tidak pakai Expanded — biarkan teks tampil penuh
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Custom Clipper untuk lengkungan bawah header
// ─────────────────────────────────────────────────────────────────
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 36,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderClipper oldClipper) => false;
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}