import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
    saveToPreferences();
  }

  void removeHabit(int index) {
    _habits.removeAt(index);
    notifyListeners();
    saveToPreferences();
  }

  void updateHabitProgress(int habitIndex, int dayIndex, bool value) {
    _habits[habitIndex].updateProgress(dayIndex, value);
    notifyListeners();
    saveToPreferences();
  }

  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('habits', Habit.encode(_habits));
  }

  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? habitsString = prefs.getString('habits');
    if (habitsString != null) {
      _habits = Habit.decode(habitsString);
      notifyListeners();
    }
  }
}
