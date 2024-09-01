import 'dart:convert';

class Habit {
  String name;
  DateTime startDate;
  List<bool> progress;

  Habit({required this.name, required this.startDate, required this.progress});

  void updateProgress(int index, bool value) {
    progress[index] = value;
  }

  int getCompletedDays() {
    return progress.where((day) => day).length;
  }

  // Convert a Habit object to a Map object (encoding)
  Map<String, dynamic> toJson() => {
        'name': name,
        'startDate': startDate.toIso8601String(),
        'progress': progress.map((e) => e ? 1 : 0).toList(),
      };

  // Convert a Map object to a Habit object (decoding)
  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        name: json['name'],
        startDate: DateTime.parse(json['startDate']),
        progress: List<bool>.from(json['progress'].map((e) => e == 1)),
      );

  // Helper method to encode a list of habits into a JSON string
  static String encode(List<Habit> habits) => json.encode(
        habits.map<Map<String, dynamic>>((habit) => habit.toJson()).toList(),
      );

  // Helper method to decode a JSON string into a list of habits
  static List<Habit> decode(String habits) =>
      (json.decode(habits) as List<dynamic>)
          .map<Habit>((item) => Habit.fromJson(item))
          .toList();
}
