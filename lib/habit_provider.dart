import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit.dart';
import 'dart:async';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  List<double> last7DaysData = [];
  Map<DateTime, double> completionMap = {};
  Timer? _dailyResetTimer;

  HabitProvider() {
    _loadHabits();
    _scheduleDailyReset();
  }

  List<Habit> get habits => _habits;

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
    _saveToPreferences();
  }

  void removeHabit(int index) {
    _habits.removeAt(index);
    notifyListeners();
    _saveToPreferences();
  }

  void updateCompletionLevel(int habitIndex, int level) {
    _habits[habitIndex].completionLevel = level;
    notifyListeners();
    _saveToPreferences();
  }

  void calculateDailyAverage() {
    double totalCompletion = 0.0;
    for (var habit in _habits) {
      totalCompletion += habit.getPercentage(); 
    }
    double averageCompletion = totalCompletion / _habits.length;
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    completionMap[today] = averageCompletion;

    if (completionMap.length > 7) {
      completionMap.remove(completionMap.keys.first);
    }

    last7DaysData = completionMap.values.toList();
    notifyListeners();
  }

  void _resetAllHabitsForNextDay() {
    for (var habit in _habits) {
      habit.resetForNextDay();
    }
    notifyListeners();
    _saveToPreferences();
  }

  void _scheduleDailyReset() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = nextMidnight.difference(now);

    _dailyResetTimer = Timer(timeUntilMidnight, () {
      _resetAllHabitsForNextDay();
      _scheduleDailyReset();
    });
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('habits', Habit.encode(_habits));
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    String? habitsString = prefs.getString('habits');
    if (habitsString != null) {
      _habits = Habit.decode(habitsString);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _dailyResetTimer?.cancel();
    super.dispose();
  }
}