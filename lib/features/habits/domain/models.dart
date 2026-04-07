import 'package:flutter/material.dart' show Color;

// ─── Enums ────────────────────────────────────────────────────────────────────

enum HabitTime { morning, afternoon, evening, allDay }

extension HabitTimeX on HabitTime {
  String get label {
    const m = {
      HabitTime.morning: 'Morning', HabitTime.afternoon: 'Afternoon',
      HabitTime.evening: 'Evening', HabitTime.allDay:    'All Day',
    };
    return m[this]!;
  }

  String get key {
    const m = {
      HabitTime.morning: 'morning', HabitTime.afternoon: 'afternoon',
      HabitTime.evening: 'evening', HabitTime.allDay:    'all',
    };
    return m[this]!;
  }

  static HabitTime fromKey(String k) {
    return {
      'morning': HabitTime.morning, 'afternoon': HabitTime.afternoon,
      'evening': HabitTime.evening,
    }[k] ?? HabitTime.allDay;
  }
}

enum GoalType { count, timer, check }

// ─── Habit ────────────────────────────────────────────────────────────────────

class Habit {
  final String    id;
  final String    name;
  final String    icon;
  final Color     color;
  final HabitTime timeOfDay;
  final GoalType  goalType;
  final int       goalValue;
  final String    unit;
  final int       sortOrder;
  final DateTime  createdAt;
  final bool      isActive;

  const Habit({
    required this.id,        required this.name,
    required this.icon,      required this.color,
    required this.timeOfDay, required this.goalType,
    required this.goalValue, required this.unit,
    this.sortOrder = 0,
    required this.createdAt,
    this.isActive = true,
  });

  Habit copyWith({
    String? id, String? name, String? icon, Color? color,
    HabitTime? timeOfDay, GoalType? goalType, int? goalValue,
    String? unit, int? sortOrder, DateTime? createdAt, bool? isActive,
  }) => Habit(
    id: id ?? this.id, name: name ?? this.name,
    icon: icon ?? this.icon, color: color ?? this.color,
    timeOfDay: timeOfDay ?? this.timeOfDay, goalType: goalType ?? this.goalType,
    goalValue: goalValue ?? this.goalValue, unit: unit ?? this.unit,
    sortOrder: sortOrder ?? this.sortOrder, createdAt: createdAt ?? this.createdAt,
    isActive: isActive ?? this.isActive,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'icon': icon, 'color': color.value,
    'time_of_day': timeOfDay.key, 'goal_type': goalType.name,
    'goal_value': goalValue, 'unit': unit,
    'sort_order': sortOrder,
    'created_at': createdAt.toIso8601String(),
    'is_active': isActive ? 1 : 0,
  };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
    id: m['id'] as String, name: m['name'] as String,
    icon: m['icon'] as String, color: Color(m['color'] as int),
    timeOfDay: HabitTimeX.fromKey(m['time_of_day'] as String),
    goalType: GoalType.values.firstWhere((e) => e.name == m['goal_type'],
        orElse: () => GoalType.count),
    goalValue: m['goal_value'] as int,
    unit: m['unit'] as String,
    sortOrder: (m['sort_order'] as int?) ?? 0,
    createdAt: DateTime.parse(m['created_at'] as String),
    isActive: (m['is_active'] as int) == 1,
  );
}

// ─── HabitEntry ───────────────────────────────────────────────────────────────

class HabitEntry {
  final String    id;
  final String    habitId;
  final DateTime  date;
  final int       progress;
  final bool      isCompleted;
  final DateTime? completedAt;

  const HabitEntry({
    required this.id,       required this.habitId,
    required this.date,     this.progress = 0,
    this.isCompleted = false, this.completedAt,
  });

  HabitEntry copyWith({
    String? id, String? habitId, DateTime? date,
    int? progress, bool? isCompleted, DateTime? completedAt,
  }) => HabitEntry(
    id: id ?? this.id, habitId: habitId ?? this.habitId,
    date: date ?? this.date, progress: progress ?? this.progress,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt ?? this.completedAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'habit_id': habitId,
    'date': _fmt(date), 'progress': progress,
    'is_completed': isCompleted ? 1 : 0,
    'completed_at': completedAt?.toIso8601String(),
  };

  factory HabitEntry.fromMap(Map<String, dynamic> m) => HabitEntry(
    id: m['id'] as String, habitId: m['habit_id'] as String,
    date: DateTime.parse(m['date'] as String),
    progress: (m['progress'] as int?) ?? 0,
    isCompleted: ((m['is_completed'] as int?) ?? 0) == 1,
    completedAt: m['completed_at'] != null
        ? DateTime.parse(m['completed_at'] as String) : null,
  );

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
}

String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';