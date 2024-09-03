import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit.dart';
import 'dart:async';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  List<double> _last30DaysData = [];
  Map<DateTime, double> completionMap = {};
  Timer? _dailyResetTimer;

  HabitProvider() {
    _loadHabits();
    _scheduleDailyReset();
  }

  List<Habit> get habits => _habits;

  List<double> get last30DaysData => _last30DaysData;

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
    _saveToPreferences();
  }

  void updateHabit(int index, Habit habit) {
    _habits[index] = habit;
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
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    String todayString = today.toIso8601String().split('T').first;

    _habits[habitIndex].completionData[todayString] = _habits[habitIndex].getPercentage();

    notifyListeners();
    _saveToPreferences();
  }

  void calculateDailyAverage() {
    double totalCompletion = 0.0;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (var habit in _habits) {
      totalCompletion += habit.getPercentage(); 
    }
    double averageCompletion = totalCompletion / _habits.length;
    completionMap[today] = averageCompletion;

    _updateLast30DaysData(today);
    notifyListeners();
  }

  void _updateLast30DaysData(DateTime today) {
    _last30DaysData.clear();

    for (int i = 0; i < 30; i++) {
      DateTime day = today.subtract(Duration(days: 29 - i));
      String dayString = day.toIso8601String().split('T').first;

      double completionRate = 0.0;
      for (var habit in _habits) {
        completionRate += habit.completionData[dayString] ?? 0.0;
      }
      completionRate /= _habits.isNotEmpty ? _habits.length : 1;
      _last30DaysData.add(completionRate);
    }
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
