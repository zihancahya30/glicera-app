import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  UserModel? _currentUser;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  int _selectedIndex = 3;

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
        Navigator.pushReplacementNamed(context, '/riwayat');
        break;
      case 3:
        // Already in Profil
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      
      if (user == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final userData = await _authService.getUserData(user.id);

      if (userData != null) {
        setState(() {
          _currentUser = userData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_off_outlined,
                        size: 80,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Data tidak ditemukan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/input-data-diri');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E54C8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Text(
                            'Lengkapi Profil',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Nama
                      Text(
                        _currentUser!.nama,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Email
                      Text(
                        _currentUser!.email,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Info Cards
                      _buildInfoCard(
                        icon: Icons.cake_outlined,
                        label: 'Usia',
                        value: '${_currentUser!.usia ?? '-'} tahun',
                      ),

                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Berat Badan',
                        value: '${_currentUser!.beratBadan ?? '-'} kg',
                      ),

                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.height_outlined,
                        label: 'Tinggi Badan',
                        value: '${_currentUser!.tinggiBadan ?? '-'} cm',
                      ),

                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.person_outline,
                        label: 'Jenis Kelamin',
                        value: _currentUser!.jenisKelamin ?? '-',
                      ),

                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.family_restroom_outlined,
                        label: 'Riwayat Keluarga Diabetes',
                        value: _currentUser!.riwayatKeluarga ?? '-',
                      ),

                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.speed_outlined,
                        label: 'BMI',
                        value: _currentUser!.bmi != null 
                            ? '${_currentUser!.bmi!.toStringAsFixed(1)} (${_currentUser!.kategoriBmi})'
                            : '-',
                      ),

                      const SizedBox(height: 32),

                      // Edit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/edit-profil');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E54C8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }
  // ─────────────────────────────────────────────────────────────────
  // CUSTOM BOTTOM NAV BAR dengan lengkungan atas
  // ikon aktif = kuning, tidak aktif = putih
  // ─────────────────────────────────────────────────────────────────
  Widget _buildCustomNavBar() {
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4E54C8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4E54C8),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
