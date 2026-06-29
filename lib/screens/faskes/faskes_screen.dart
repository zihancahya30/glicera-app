import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/faskes_data.dart';
import '../../models/faskes_model.dart';

class FaskesScreen extends StatefulWidget {
  const FaskesScreen({super.key});

  @override
  State<FaskesScreen> createState() => _FaskesScreenState();
}

class _FaskesScreenState extends State<FaskesScreen> {
  // Faskes tidak punya tab aktif di navbar (bukan bagian dari 4 tab utama)
  // Tidak ada _selectedIndex yang aktif
  final int _selectedIndex = -1; // Tidak ada yang aktif

  void _onNavItemTapped(int index) {
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
        Navigator.pushReplacementNamed(context, '/profil');
        break;
    }
  }

  final List<FaskesModel> _allFaskes = FaskesData.getAllFaskes();
  final Set<String> _expandedIds = {};

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
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
          'Fasilitas Kesehatan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/pengaturan',
                arguments: 3, // selalu tab Profil
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _allFaskes.length,
        itemBuilder: (context, index) {
          final faskes = _allFaskes[index];
          final isExpanded = _expandedIds.contains(faskes.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFaskesCard(faskes, isExpanded),
          );
        },
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CUSTOM BOTTOM NAV BAR — sama persis dengan halaman lain
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

  Widget _buildFaskesCard(FaskesModel faskes, bool isExpanded) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (Always Visible)
          InkWell(
            onTap: () => _toggleExpanded(faskes.id),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: AppColors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      faskes.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.white, thickness: 0.5),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      faskes.type == 'puskesmas'
                          ? 'PUSKESMAS'
                          : 'RUMAH SAKIT',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.place, faskes.address),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone, faskes.phone),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      Icons.access_time, faskes.operationalHours),
                  const SizedBox(height: 16),
                  const Text(
                    'Layanan:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...faskes.services.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.white)),
                          Expanded(
                            child: Text(
                              service,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.white,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.white,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}