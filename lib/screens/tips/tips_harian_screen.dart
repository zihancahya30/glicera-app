import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/tips_data.dart';
import '../../models/tips_model.dart';
import 'tips_detail_screen.dart';

class TipsHarianScreen extends StatefulWidget {
  const TipsHarianScreen({super.key});

  @override
  State<TipsHarianScreen> createState() => _TipsHarianScreenState();
}

class _TipsHarianScreenState extends State<TipsHarianScreen> {
  final int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
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

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return const Color(0xFF4A7EFF);
      case 'red':
        return const Color(0xFFFF6B6B);
      case 'yellow':
        return const Color(0xFFFFD966);
      case 'green':
        return const Color(0xFF26A69A);
      case 'purple':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipsList = TipsData.getTipsHarian();

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
          'Tips Harian',
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
              Navigator.pushNamed(context, '/pengaturan');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const Text(
            'Tips Harian',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Temukan tips singkat yang bisa langsung diterapkan untuk membantu menjaga pola hidup sehat setiap hari.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          ...tipsList.map((tips) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _buildTipsCard(context, tips),
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Beranda'),
      _NavItem(icon: Icons.camera_alt_outlined, activeIcon: Icons.camera_alt, label: 'Skrining'),
      _NavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'Riwayat'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
    ];

    return Hero(
      tag: 'mainNavbar',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withValues(alpha: 0.3),
              blurRadius: 12,
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
                          color: isActive ? const Color(0xFFFFC107) : Colors.white.withValues(alpha: 0.7),
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[index].label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? const Color(0xFFFFC107) : Colors.white.withValues(alpha: 0.7),
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
      ),
    );
  }

  Widget _buildTipsCard(BuildContext context, TipsModel tips) {
    final Color cardColor = _getColorFromString(tips.color);
    final isDarkColor =
        tips.color == 'blue' || tips.color == 'red' || tips.color == 'purple';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TipsDetailScreen(tips: tips),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardColor.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Tips Harian',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cardColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tips.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tips.description,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDarkColor
                      ? cardColor.withValues(alpha: 0.9)
                      : cardColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: isDarkColor ? Colors.white : cardColor,
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}
