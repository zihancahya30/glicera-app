import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../data/rutinitas_data.dart';
import '../../models/rutinitas_model.dart';

class PengaturanScreen extends StatefulWidget {
  final int initialIndex;
  const PengaturanScreen({super.key, this.initialIndex = 3});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  late SharedPreferences _prefs;
  bool _notifikasiPush = true;
  bool _suaraNotifikasi = true;
  late int _selectedIndex;
  bool _isRescheduling = false;

  final AuthService _authService = AuthService();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notifikasiPush = _prefs.getBool('notifikasi_push_enabled') ?? true;
        _suaraNotifikasi = _prefs.getBool('notifikasi_sound_enabled') ?? true;
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
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

  Future<void> _toggleNotifikasiPush(bool value) async {
    setState(() => _notifikasiPush = value);
    await _prefs.setBool('notifikasi_push_enabled', value);

    final service = NotificationService();

    if (!value) {
      await service.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi rutinitas dinonaktifkan'),
            backgroundColor: AppColors.textSecondary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      await service.initialize();
      final notificationsEnabled = await service.areNotificationsEnabled();
      if (!notificationsEnabled) {
        await _prefs.setBool('notifikasi_push_enabled', false);
        if (mounted) {
          setState(() => _notifikasiPush = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notifikasi belum diizinkan oleh sistem. Aktifkan izin notifikasi di pengaturan HP.',
              ),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      await _rescheduleAllNotifications();
      await service.showNotification(
        title: 'Notifikasi Glicera aktif',
        body: 'Pengingat rutinitas akan muncul sesuai jadwal yang kamu atur.',
      );
    }
  }

  // FIX MASALAH 1: Snackbar sekarang selalu muncul menggunakan finally,
  // baik reschedule berhasil sebagian, gagal total, maupun sukses penuh.
  Future<void> _rescheduleAllNotifications() async {
    if (_isRescheduling) { return; }
    if (mounted) { setState(() => _isRescheduling = true); }

    int scheduledCount = 0;

    try {
      final userId = _authService.currentUser?.id;

      // FIX: Jika userId null, tetap tampilkan snackbar (via finally)
      if (userId == null || userId.isEmpty) {
        debugPrint('Reschedule skipped: userId is null');
        return;
      }

      final service = NotificationService();
      await service.cancelAllNotifications();

      // FIX: Wrap getLatestScan dalam try-catch sendiri agar error di sini
      // tidak menghentikan seluruh fungsi
      List<RutinitasModel> defaultRoutines = [];
      try {
        final latestScan = await _supabaseService.getLatestScan(userId);
        if (latestScan != null) {
          defaultRoutines = latestScan.isDiabetes
              ? RutinitasData.getDiabetesRutinitas()
              : RutinitasData.getNonDiabetesRutinitas();
        }
      } catch (e) {
        debugPrint('getLatestScan error during reschedule: $e');
        // Lanjut dengan defaultRoutines kosong — custom routines tetap diproses
      }

      List<RutinitasModel> customRoutines = [];
      try {
        customRoutines = await _supabaseService.getUserRoutines(userId);
      } catch (e) {
        debugPrint('getUserRoutines error during reschedule: $e');
      }

      final allRoutines = [...defaultRoutines, ...customRoutines];

      for (int routineIndex = 0;
          routineIndex < allRoutines.length;
          routineIndex++) {
        final routine = allRoutines[routineIndex];
        final shouldNotify = routine.isDefault || routine.enableNotification;
        if (!shouldNotify) { continue; }

        if (routine.frequency == null ||
            routine.times == null ||
            routine.times!.isEmpty) { continue; }

        final notifBody = routine.getNotificationBody();

        try {
          if (routine.frequency == 'harian') {
            for (int i = 0; i < routine.times!.length; i++) {
              final parts = routine.times![i].split(':');
              if (parts.length != 2) { continue; }
              final hour = int.tryParse(parts[0]);
              final minute = int.tryParse(parts[1]);
              if (hour == null || minute == null) { continue; }

              await service.scheduleDailyNotification(
                id: NotificationService.buildNotifId(routineIndex, i),
                title: routine.title,
                body: notifBody,
                hour: hour,
                minute: minute,
              );
              scheduledCount++;
            }
          } else if (routine.frequency == 'mingguan') {
            final parts = routine.times!.first.split(':');
            if (parts.length != 2) { continue; }
            final hour = int.tryParse(parts[0]);
            final minute = int.tryParse(parts[1]);
            if (hour == null || minute == null) { continue; }

            const dayMap = {
              'Monday': 1, 'Tuesday': 2, 'Wednesday': 3,
              'Thursday': 4, 'Friday': 5, 'Saturday': 6, 'Sunday': 7,
            };
            final targetWeekdays = (routine.selectedDays ?? <String>[])
                .map((d) => dayMap[d])
                .whereType<int>()
                .toList();

            if (targetWeekdays.isNotEmpty) {
              await service.scheduleWeeklyNotifications(
                baseId: NotificationService.buildNotifId(routineIndex, 0),
                title: routine.title,
                body: notifBody,
                hour: hour,
                minute: minute,
                weekdays: targetWeekdays,
              );
              scheduledCount++;
            }
          } else if (routine.frequency == 'sekali' &&
              routine.dueDate != null) {
            final due = routine.dueDate!;
            final now = DateTime.now();
            final dueIsToday = due.year == now.year &&
                due.month == now.month &&
                due.day == now.day;
            final dueIsFuture = due.isAfter(now);

            if (dueIsToday || dueIsFuture) {
              final parts = routine.times!.first.split(':');
              final hour = int.tryParse(parts[0]) ?? 8;
              final minute =
                  int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

              final scheduledTime = DateTime(
                due.year, due.month, due.day, hour, minute,
              );

              if (scheduledTime.isAfter(now)) {
                await service.scheduleOnceNotification(
                  id: NotificationService.buildNotifId(routineIndex, 0),
                  title: routine.title,
                  body: notifBody,
                  scheduledTime: scheduledTime,
                );
                scheduledCount++;
              }
            }
          }
        } catch (e) {
          debugPrint('Reschedule error for "${routine.title}": $e');
        }
      }
    } catch (e) {
      debugPrint('_rescheduleAllNotifications outer error: $e');
    } finally {
      // FIX: finally memastikan state dan snackbar SELALU ditampilkan,
      // tidak peduli apakah ada error di atas atau tidak
      if (mounted) {
        setState(() => _isRescheduling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              scheduledCount > 0
                  ? 'Notifikasi diaktifkan ($scheduledCount jadwal terdaftar)'
                  : 'Notifikasi diaktifkan',
            ),
            backgroundColor: AppColors.teal,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client.auth.signOut();
        if (!mounted) { return; }
        navigator.pushNamedAndRemoveUntil('/onboarding', (route) => false);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Akun',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _buildMenuTile(
              icon: Icons.person_outline,
              iconColor: const Color(0xFF4E54C8),
              title: 'Edit Profil',
              subtitle: 'Ubah informasi pribadi Anda',
              onTap: () => Navigator.pushNamed(context, '/edit-profil'),
            ),
            const SizedBox(height: 32),
            const Text('Notifikasi',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFF4E54C8),
              title: 'Notifikasi Push',
              subtitle: _isRescheduling
                  ? 'Mendaftarkan ulang jadwal notifikasi...'
                  : 'Terima pemberitahuan rutinitas harian',
              value: _notifikasiPush,
              isLoading: _isRescheduling,
              onChanged: _isRescheduling ? null : _toggleNotifikasiPush,
            ),
            
            const SizedBox(height: 12),
            _buildSwitchTile(
              icon: Icons.volume_up_outlined,
              iconColor: const Color(0xFF4E54C8),
              title: 'Suara Notifikasi',
              subtitle: 'Aktifkan suara untuk notifikasi',
              value: _suaraNotifikasi,
              onChanged: (value) async {
                setState(() => _suaraNotifikasi = value);
                await _prefs.setBool('notifikasi_sound_enabled', value);
              },
            ),
            
            const SizedBox(height: 32),
            const Text('Aplikasi',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _buildMenuTile(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF4E54C8),
              title: 'Tentang Aplikasi',
              subtitle: 'Versi 1.0.0',
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Tentang Aplikasi',
                      style: TextStyle(fontFamily: 'Poppins')),
                  content: const Text(
                    'Glicera v1.0.0\n\nAplikasi deteksi dini risiko diabetes melalui foto lidah.\n\n© 2026 Glicera Team',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF4E54C8),
              title: 'Kebijakan Privasi',
              subtitle: 'Lihat kebijakan privasi kami',
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kebijakan Privasi',
                      style: TextStyle(fontFamily: 'Poppins')),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Kami menghargai privasi Anda. Data yang dikumpulkan hanya digunakan untuk keperluan aplikasi dan tidak dibagikan kepada pihak ketiga.\n\nData yang dikumpulkan:\n- Informasi profil\n- Hasil skrining\n- Riwayat penggunaan aplikasi\n\nSemua data disimpan dengan aman.',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.help_outline,
              iconColor: const Color(0xFF4E54C8),
              title: 'Bantuan',
              subtitle: 'Pusat bantuan dan FAQ',
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Bantuan',
                      style: TextStyle(fontFamily: 'Poppins')),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Pertanyaan Umum:\n\n1. Bagaimana cara melakukan skrining?\nBuka menu Skrining, ambil foto lidah dengan pencahayaan yang baik.\n\n2. Apakah hasil skrining akurat?\nAplikasi ini adalah alat bantu skrining awal, bukan pengganti diagnosis medis.\n\n3. Bagaimana cara melihat riwayat?\nBuka menu Riwayat di navigasi bawah.\n\nUntuk bantuan lebih lanjut, hubungi: support@glicera.app',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Keluar',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool isLoading = false,
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
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF4E54C8),
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
