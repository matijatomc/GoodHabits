import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'notification.dart';

class HabitProgressScreen extends StatelessWidget {
  final int habitIndex; 
  final NotificationService notificationService;

  const HabitProgressScreen({super.key, 
    required this.habitIndex,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    final habit = Provider.of<HabitProvider>(context, listen: false).habits[habitIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
      ),
      body: Center(
        child: Column(
          children: List.generate(5, (level) {
            return RadioListTile(
              title: Text(habit.completionLabels[level]),
              value: level,
              groupValue: habit.completionLevel,
              onChanged: (int? value) {
                if (value != null) {
                  Provider.of<HabitProvider>(context, listen: false)
                      .updateCompletionLevel(habitIndex, value);

                  if (value < 4) {
                    final now = TimeOfDay.now();
                    notificationService.scheduleDailyNotification(
                      habit.hashCode,
                      'Reminder!',
                      'Don\'t forget to complete your habit today!',
                      now,
                    );
                  }
                }
              },
            );
          }),
        ),
      ),
    );
  }
}