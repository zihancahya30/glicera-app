// Model untuk setiap checklist item dalam rutinitas
class ChecklistItem {
  final String id;
  final String title;
  bool isCompleted;
  DateTime? completedAt;

  ChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  // Copy with untuk update state
  ChecklistItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return ChecklistItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['is_completed'] ?? map['isCompleted'] ?? false,
      completedAt: parseDateTime(map['completed_at'] ?? map['completedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

// Model untuk history rutinitas harian
class DailyChecklistHistory {
  final String id;
  final String habitId;
  final DateTime date;
  final int totalItems;
  final int completedItems;
  final bool isCompleted; // true jika semua item selesai
  final List<ChecklistItem> items;

  DailyChecklistHistory({
    required this.id,
    required this.habitId,
    required this.date,
    required this.totalItems,
    required this.completedItems,
    required this.isCompleted,
    required this.items,
  });

  DailyChecklistHistory copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    int? totalItems,
    int? completedItems,
    bool? isCompleted,
    List<ChecklistItem>? items,
  }) {
    return DailyChecklistHistory(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
      isCompleted: isCompleted ?? this.isCompleted,
      items: items ?? this.items,
    );
  }
}

class RutinitasModel {
  final String id;
  final String title;
  final String description;
  final String color; // blue, red, yellow
  final bool isDefault; // true = default, false = user-added
  final String? frequency; // harian, sekali, mingguan
  final int? repetition; // berapa kali sehari (hanya untuk Harian)
  final List<String>? times; // jam berapa saja (format: HH:mm)
  final List<String>? selectedDays; // untuk Mingguan: ['Monday', 'Tuesday', ...]
  final DateTime? dueDate; // untuk rutinitas sekali
  final bool enableNotification; // Enable notification untuk rutinitas ini

  /// Pesan notifikasi khusus untuk rutinitas ini.
  /// Jika null, akan di-generate otomatis oleh [getNotificationBody].
  final String? notificationMessage;

  // Checklist items untuk setiap rutinitas
  final List<ChecklistItem> checklistItems;
  final int streakCount; // Berapa hari berturut-turut selesai

  bool isCompleted;

  // Daily history - untuk tracking riwayat
  DailyChecklistHistory? todayHistory;

  RutinitasModel({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    this.isDefault = true,
    this.frequency,
    this.repetition,
    this.times,
    this.selectedDays,
    this.dueDate,
    this.enableNotification = true,
    this.notificationMessage,
    this.checklistItems = const [],
    this.streakCount = 0,
    this.isCompleted = false,
    this.todayHistory,
  });

  // Get progress percentage
  double getProgress() {
    if (checklistItems.isEmpty) return 0;
    final completed = checklistItems.where((item) => item.isCompleted).length;
    return completed / checklistItems.length;
  }

  // Get completed count
  int getCompletedCount() {
    return checklistItems.where((item) => item.isCompleted).length;
  }

  /// Kembalikan body notifikasi yang tepat untuk rutinitas ini.
  /// Urutan prioritas:
  ///   1. [notificationMessage] jika sudah didefinisikan (rutinitas default).
  ///   2. Nama aktivitas generik untuk rutinitas custom.
  String getNotificationBody() {
    if (notificationMessage != null && notificationMessage!.isNotEmpty) {
      return notificationMessage!;
    }
    // Fallback untuk rutinitas custom: pakai nama rutinitas
    return 'Waktu untuk $title — yuk selesaikan rutinitas hari ini! 💪';
  }

  factory RutinitasModel.fromSupabaseMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final rawChecklistItems = map['checklist_items'];
    final checklistItems = rawChecklistItems is List
        ? rawChecklistItems
            .whereType<Map>()
            .map((item) =>
                ChecklistItem.fromMap(Map<String, dynamic>.from(item)))
            .toList()
        : <ChecklistItem>[];

    return RutinitasModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      color: map['color'] ?? 'blue',
      isDefault: false,
      frequency: map['frequency'],
      repetition: map['repetition'],
      times: List<String>.from(map['times'] ?? []),
      selectedDays: List<String>.from(map['selected_days'] ?? []),
      dueDate: parseDate(map['due_date']),
      enableNotification: map['enable_notification'] ?? true,
      // notificationMessage tidak disimpan di Supabase (hanya untuk default)
      checklistItems: checklistItems,
    );
  }

  Map<String, dynamic> toSupabaseMap(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'color': color,
      'frequency': frequency ?? 'harian',
      'repetition': repetition,
      'times': times ?? <String>[],
      'selected_days': selectedDays ?? <String>[],
      'due_date': dueDate != null
          ? '${dueDate!.year.toString().padLeft(4, '0')}-'
              '${dueDate!.month.toString().padLeft(2, '0')}-'
              '${dueDate!.day.toString().padLeft(2, '0')}'
          : null,
      'enable_notification': enableNotification,
      'checklist_items':
          checklistItems.map((item) => item.toMap()).toList(),
      'is_active': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  RutinitasModel copyWith({
    String? id,
    String? title,
    String? description,
    String? color,
    bool? isDefault,
    String? frequency,
    int? repetition,
    List<String>? times,
    List<String>? selectedDays,
    DateTime? dueDate,
    bool? enableNotification,
    String? notificationMessage,
    List<ChecklistItem>? checklistItems,
    int? streakCount,
    bool? isCompleted,
    DailyChecklistHistory? todayHistory,
  }) {
    return RutinitasModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      frequency: frequency ?? this.frequency,
      repetition: repetition ?? this.repetition,
      times: times ?? this.times,
      selectedDays: selectedDays ?? this.selectedDays,
      dueDate: dueDate ?? this.dueDate,
      enableNotification: enableNotification ?? this.enableNotification,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      checklistItems: checklistItems ?? this.checklistItems,
      streakCount: streakCount ?? this.streakCount,
      isCompleted: isCompleted ?? this.isCompleted,
      todayHistory: todayHistory ?? this.todayHistory,
    );
  }
}