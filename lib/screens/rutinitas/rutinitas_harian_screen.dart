import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../data/rutinitas_data.dart';
import '../../models/rutinitas_model.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import 'tambah_kebiasaan_screen.dart';

class RutinitasHarianScreen extends StatefulWidget {
  final bool hasScreening;
  final bool isDiabetes;

  const RutinitasHarianScreen({
    super.key,
    this.hasScreening = false,
    this.isDiabetes = false,
  });

  @override
  State<RutinitasHarianScreen> createState() => _RutinitasHarianScreenState();
}

class _RutinitasHarianScreenState extends State<RutinitasHarianScreen>
    with TickerProviderStateMixin {
  List<RutinitasModel> _rutinitas = [];
  final List<int> _expandedIndices = [];
  bool _isLoading = false;
  bool _localHasScreening = false;
  bool _localIsDiabetes = false;
  late TabController _tabController;
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final DateTime _today = DateTime.now();

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _localHasScreening = widget.hasScreening;
    _localIsDiabetes = widget.isDiabetes;
    _loadRutinitas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRutinitas() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = _authService.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      var hasScreening = _localHasScreening;
      var isDiabetes = _localIsDiabetes;

      if (!hasScreening) {
        final lastScan = await _supabaseService.getLatestScan(userId);
        if (lastScan == null) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        hasScreening = true;
        isDiabetes = lastScan.isDiabetes;
      }

      final defaultRoutines = isDiabetes
          ? RutinitasData.getDiabetesRutinitas()
          : RutinitasData.getNonDiabetesRutinitas();

      final customRoutines = await _supabaseService.getUserRoutines(userId);
      final allRoutines = [...defaultRoutines, ...customRoutines];

      final progress = await _supabaseService.getRoutineProgressForDate(
        userId: userId,
        date: _today,
      );

      final routines = _applyProgressToRoutines(
        _filterRoutinesForToday(allRoutines),
        progress,
      );

      _setupNotifications(allRoutines).catchError(
        (e) => debugPrint('Setup notifications error: $e'),
      );

      if (mounted) {
        setState(() {
          _localHasScreening = hasScreening;
          _localIsDiabetes = isDiabetes;
          _rutinitas = routines;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('_loadRutinitas error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setupNotifications(List<RutinitasModel> routines) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled =
        prefs.getBool('notifikasi_push_enabled') ?? true;
    if (!notificationsEnabled) return;

    final service = NotificationService();
    await service.cancelAllNotifications();

    for (int routineIndex = 0;
        routineIndex < routines.length;
        routineIndex++) {
      final routine = routines[routineIndex];
      final shouldNotify = routine.isDefault || routine.enableNotification;
      if (!shouldNotify) continue;

      if (routine.frequency == null ||
          routine.times == null ||
          routine.times!.isEmpty) {
        continue;
      }

      final notifBody = routine.getNotificationBody();

      try {
        if (routine.frequency == 'harian') {
          for (int i = 0; i < routine.times!.length; i++) {
            final parts = routine.times![i].split(':');
            if (parts.length != 2) continue;
            final hour = int.tryParse(parts[0]);
            final minute = int.tryParse(parts[1]);
            if (hour == null || minute == null) continue;

            await service.scheduleDailyNotification(
              id: NotificationService.buildNotifId(routineIndex, i),
              title: routine.title,
              body: notifBody,
              hour: hour,
              minute: minute,
            );
          }
        } else if (routine.frequency == 'mingguan') {
          final parts = routine.times!.first.split(':');
          if (parts.length != 2) continue;
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour == null || minute == null) continue;

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
          }
        } else if (routine.frequency == 'sekali' &&
            routine.dueDate != null) {
          // FIX: Bandingkan tanggal saja, bukan datetime penuh.
          // dueDate disimpan sebagai midnight (00:00), sehingga
          // isAfter(DateTime.now()) selalu false jika hari ini sudah
          // lewat tengah malam — padahal jamnya belum tentu lewat.
          final due = routine.dueDate!;
          final now = DateTime.now();
          final dueIsToday = due.year == now.year &&
              due.month == now.month &&
              due.day == now.day;
          final dueIsFuture = due.isAfter(now);

          if (!dueIsToday && !dueIsFuture) {
            // Tanggal sudah lewat, skip
          } else {
            final parts = routine.times!.first.split(':');
            final hour = int.tryParse(parts[0]) ?? 8;
            final minute =
                int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

            final scheduledTime = DateTime(
              due.year,
              due.month,
              due.day,
              hour,
              minute,
            );

            // Hanya schedule jika waktu spesifiknya belum lewat
            if (scheduledTime.isAfter(now)) {
              await service.scheduleOnceNotification(
                id: NotificationService.buildNotifId(routineIndex, 0),
                title: routine.title,
                body: notifBody,
                scheduledTime: scheduledTime,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Error notif "${routine.title}": $e');
      }
    }
  }

  Future<void> _rescheduleAllRoutineNotifications(String userId) async {
    final latestScan = await _supabaseService.getLatestScan(userId);
    final defaultRoutines = latestScan == null
        ? <RutinitasModel>[]
        : latestScan.isDiabetes
            ? RutinitasData.getDiabetesRutinitas()
            : RutinitasData.getNonDiabetesRutinitas();
    final customRoutines = await _supabaseService.getUserRoutines(userId);

    await _setupNotifications([...defaultRoutines, ...customRoutines]);
  }

  List<RutinitasModel> _filterRoutinesForToday(
      List<RutinitasModel> routines) {
    return routines.where(_isRoutineDueToday).toList();
  }

  bool _isRoutineDueToday(RutinitasModel routine) {
    if (routine.isDefault) return true;
    switch (routine.frequency) {
      case 'mingguan':
        return routine.selectedDays?.contains(_englishWeekday(_today)) ?? false;
      case 'sekali':
        final dueDate = routine.dueDate;
        return dueDate != null &&
            dueDate.year == _today.year &&
            dueDate.month == _today.month &&
            dueDate.day == _today.day;
      case 'harian':
      default:
        return true;
    }
  }

  String _englishWeekday(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return days[date.weekday - 1];
  }

  List<RutinitasModel> _applyProgressToRoutines(
    List<RutinitasModel> routines,
    Map<String, List<String>> progress,
  ) {
    return routines.map((routine) {
      final completedIds = progress[routine.id]?.toSet() ?? <String>{};
      final items = routine.checklistItems.map((item) {
        return item.copyWith(
          isCompleted: completedIds.contains(item.id),
          completedAt: completedIds.contains(item.id) ? _today : null,
        );
      }).toList();
      return routine.copyWith(
        checklistItems: items,
        isCompleted: items.isNotEmpty && items.every((item) => item.isCompleted),
      );
    }).toList();
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return const Color(0xFF6B9CFF);
      case 'red':
        return const Color(0xFFFF6B6B);
      case 'yellow':
        return const Color(0xFFFFB84D);
      default:
        return AppColors.primary;
    }
  }

  Future<void> _toggleChecklistItem(int habitIndex, int itemIndex) async {
    final previousRoutine = _cloneRoutine(_rutinitas[habitIndex]);
    late RutinitasModel updatedRoutine;

    setState(() {
      final currentRoutine = _rutinitas[habitIndex];
      final updatedItems =
          currentRoutine.checklistItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        if (index != itemIndex) return item.copyWith();
        final isCompleted = !item.isCompleted;
        return ChecklistItem(
          id: item.id,
          title: item.title,
          isCompleted: isCompleted,
          completedAt: isCompleted ? DateTime.now() : null,
        );
      }).toList();

      final allCompleted = updatedItems.every((item) => item.isCompleted);
      updatedRoutine = currentRoutine.copyWith(
        checklistItems: updatedItems,
        isCompleted: allCompleted,
      );
      _rutinitas[habitIndex] = updatedRoutine;
    });

    final isSaved = await _saveRoutineProgress(updatedRoutine);
    if (!isSaved && mounted) {
      setState(() => _rutinitas[habitIndex] = previousRoutine);
      _showProgressSaveError();
    }
  }

  void _toggleHabitExpanded(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  Future<void> _markHabitComplete(int index) async {
    final previousRoutine = _cloneRoutine(_rutinitas[index]);
    late RutinitasModel updatedRoutine;

    setState(() {
      final completedItems = _rutinitas[index]
          .checklistItems
          .map((item) => item.copyWith(
                isCompleted: true,
                completedAt: DateTime.now(),
              ))
          .toList();
      updatedRoutine = _rutinitas[index].copyWith(
        checklistItems: completedItems,
        isCompleted: true,
      );
      _rutinitas[index] = updatedRoutine;
    });

    final isSaved = await _saveRoutineProgress(updatedRoutine);
    if (!mounted) return;
    if (!isSaved) {
      setState(() => _rutinitas[index] = previousRoutine);
      _showProgressSaveError();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_rutinitas[index].title} selesai untuk hari ini! 🎉'),
        duration: const Duration(seconds: 2),
        backgroundColor: _getColorFromString(_rutinitas[index].color),
      ),
    );
  }

  // FIX MASALAH 3: Pisahkan delete DB dan cancel notifikasi.
  // Jika DB berhasil → update UI dulu, baru cancel notifikasi di background.
  // Error dari cancelRoutineNotifications tidak lagi menyebabkan snackbar
  // "gagal dihapus" yang misleading.
  Future<void> _deleteCustomRoutine(int index) async {
    final routine = _rutinitas[index];
    if (routine.isDefault) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Kebiasaan',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Yakin ingin menghapus "${routine.title}"? Kebiasaan ini tidak bisa dikembalikan.',
          style: const TextStyle(
              fontFamily: 'Poppins', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(fontFamily: 'Poppins', color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    // FIX: Simpan index SEBELUM operasi async apapun
    final routineIndex = _rutinitas.indexOf(routine);

    try {
      // Langkah 1: Hapus dari database dulu
      final deleteResult = await _supabaseService.deleteUserRoutine(
        userId: userId,
        routineId: routine.id,
      );

      if (!mounted) return;

      // FIX: Cek hasil DB secara eksplisit
      if (deleteResult['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deleteResult['message'] ?? 'Gagal menghapus kebiasaan'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Langkah 2: DB berhasil → update UI langsung
      setState(() {
        final updatedExpanded = _expandedIndices
            .where((i) => i != index)
            .map((i) => i > index ? i - 1 : i)
            .toList();
        _expandedIndices
          ..clear()
          ..addAll(updatedExpanded);
        _rutinitas.removeAt(index);
      });

      // Langkah 3: Cancel notifikasi di background (error di sini tidak
      // mempengaruhi UI karena data sudah terhapus dari DB dan list)
      if (routineIndex >= 0) {
        NotificationService()
            .cancelRoutineNotifications(routineIndex: routineIndex)
            .catchError((e) =>
                debugPrint('Cancel notif after delete error: $e'));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kebiasaan berhasil dihapus'),
          backgroundColor: AppColors.teal,
        ),
      );
    } catch (e) {
      debugPrint('_deleteCustomRoutine error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus kebiasaan. Silakan coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateToTambahKebiasaan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahKebiasaanScreen(),
      ),
    );

    if (!mounted) return;

    if (result != null && result is RutinitasModel) {
      final userId = _authService.currentUser?.id;
      if (userId == null || userId.isEmpty) return;

      final saveResult = await _supabaseService.saveUserRoutine(
        userId: userId,
        routine: result,
      );

      if (!mounted) return;

      if (saveResult['success'] == true) {
        if (_isRoutineDueToday(result)) {
          setState(() => _rutinitas.add(result));
        }
        _rescheduleAllRoutineNotifications(userId).catchError(
          (e) => debugPrint('Reschedule after add error: $e'),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kebiasaan berhasil disimpan'),
            backgroundColor: AppColors.teal,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(saveResult['message'] ?? 'Gagal menyimpan kebiasaan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  RutinitasModel _cloneRoutine(RutinitasModel routine) {
    return routine.copyWith(
      checklistItems: routine.checklistItems
          .map((item) => ChecklistItem(
                id: item.id,
                title: item.title,
                isCompleted: item.isCompleted,
                completedAt: item.completedAt,
              ))
          .toList(),
    );
  }

  void _showProgressSaveError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress belum bisa disimpan. Silakan coba lagi.'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<bool> _saveRoutineProgress(RutinitasModel routine) async {
    final userId = _authService.currentUser?.id;
    if (userId == null || userId.isEmpty) return false;
    final result = await _supabaseService.saveRoutineProgress(
      userId: userId,
      routine: routine,
      date: _today,
    );
    return result['success'] == true;
  }

  Future<void> _resetTodayProgress() async {
    if (_rutinitas.every((r) => r.getCompletedCount() == 0)) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress',
            style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
            'Yakin ingin mengosongkan semua checklist hari ini?',
            style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final userId = _authService.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    final result = await _supabaseService.resetRoutineProgressForDate(
      userId: userId,
      date: _today,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _rutinitas = _rutinitas.map((routine) {
          final items = routine.checklistItems
              .map((item) => item.copyWith(
                    isCompleted: false,
                    completedAt: null,
                  ))
              .toList();
          return routine.copyWith(checklistItems: items, isCompleted: false);
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress hari ini berhasil direset'),
          backgroundColor: AppColors.teal,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal reset progress'),
          backgroundColor: AppColors.error,
        ),
      );
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
          'Rutinitas Sehat',
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
            onPressed: () =>
                Navigator.pushNamed(context, '/pengaturan', arguments: 3),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _localHasScreening
              ? _buildRutinitas()
              : _buildNoScreeningMessage(),
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

    return Container(
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
              return GestureDetector(
                onTap: () => _onNavItemTapped(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[index].icon,
                          color: Colors.white.withValues(alpha: 0.7), size: 26),
                      const SizedBox(height: 4),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.7),
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

  Widget _buildNoScreeningMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner,
                size: 80, color: AppColors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            const Text(
              'Lakukan Skrining untuk Melihat Rutinitas Harian Kamu!',
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
              'Rutinitas harian akan disesuaikan dengan hasil skrining diabetes Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text(
                  'Mulai Skrining',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRutinitas() {
    final totalItems =
        _rutinitas.fold(0, (sum, r) => sum + r.checklistItems.length);
    final completedItems =
        _rutinitas.fold(0, (sum, r) => sum + r.getCompletedCount());
    final overallProgress =
        totalItems > 0 ? (completedItems / totalItems * 100).toInt() : 0;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progress Hari Ini',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text('$completedItems/$totalItems',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: totalItems > 0 ? completedItems / totalItems : 0,
                  minHeight: 8,
                  backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text('$overallProgress% Selesai',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed:
                      completedItems == 0 ? null : _resetTodayProgress,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset Progress Hari Ini',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    disabledForegroundColor: AppColors.grey,
                    side: BorderSide(
                      color: completedItems == 0
                          ? AppColors.grey.withValues(alpha: 0.4)
                          : AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _rutinitas.length,
            itemBuilder: (context, index) {
              final rutinitas = _rutinitas[index];
              final isExpanded = _expandedIndices.contains(index);
              final progress = rutinitas.getProgress();
              final completedCount = rutinitas.getCompletedCount();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildExpandableHabitCard(
                    rutinitas, index, isExpanded, progress, completedCount),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _navigateToTambahKebiasaan,
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text('Tambah Kebiasaan Baru',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableHabitCard(
    RutinitasModel rutinitas,
    int habitIndex,
    bool isExpanded,
    double progress,
    int completedCount,
  ) {
    final cardColor = _getColorFromString(rutinitas.color);
    final totalItems = rutinitas.checklistItems.length;
    final isCustom = !rutinitas.isDefault;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleHabitExpanded(habitIndex),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(rutinitas.title,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                ),
                                if (isCustom)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: cardColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('Custom',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: cardColor)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Progress: $completedCount/$totalItems',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: cardColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: cardColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: cardColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(rutinitas.checklistItems.length,
                            (itemIndex) {
                          final item = rutinitas.checklistItems[itemIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: InkWell(
                              onTap: () =>
                                  _toggleChecklistItem(habitIndex, itemIndex),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: item.isCompleted,
                                    onChanged: (_) => _toggleChecklistItem(
                                        habitIndex, itemIndex),
                                    activeColor: cardColor,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: item.isCompleted
                                            ? AppColors.textSecondary
                                            : AppColors.textPrimary,
                                        decoration: item.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        if (completedCount == totalItems && !rutinitas.isCompleted)
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => _markHabitComplete(habitIndex),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cardColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 18, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Tandai Selesai Hari Ini',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        if (rutinitas.isCompleted)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified,
                                    size: 18, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Selesai Hari Ini!',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        if (isCustom) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () => _deleteCustomRoutine(habitIndex),
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.error),
                              label: const Text('Hapus Kebiasaan Ini',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
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
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}
