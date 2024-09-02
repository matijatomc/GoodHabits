import 'dart:convert';

class Habit {
  String name;
  int completionLevel;
  List<String> completionLabels; 

  Habit({
    required this.name,
    this.completionLevel = 0,
    required this.completionLabels,
  });

  double getPercentage() {
    switch (completionLevel) {
      case 0:
        return 1.0;
      case 1:
        return 0.75;
      case 2:
        return 0.5;
      case 3:
        return 0.25;
      default:
        return 0.0;
    }
  }

  void resetForNextDay() {
    completionLevel = 0;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'completionLevel': completionLevel,
        'completionLabels': completionLabels,
      };


  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        name: json['name'],
        completionLevel: json['completionLevel'],
        completionLabels: List<String>.from(json['completionLabels']),
      );


  static String encode(List<Habit> habits) => json.encode(
        habits.map<Map<String, dynamic>>((habit) => habit.toJson()).toList(),
      );

 
  static List<Habit> decode(String habits) =>
      (json.decode(habits) as List<dynamic>)
          .map<Habit>((item) => Habit.fromJson(item))
          .toList();
}