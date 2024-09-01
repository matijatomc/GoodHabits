import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'notification.dart';

class HabitProgressScreen extends StatelessWidget {
  final int habitIndex; // Now taking index instead of habit
  final NotificationService notificationService;

  HabitProgressScreen({
    required this.habitIndex,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    // Get the habit from the provider using the index
    final habit = Provider.of<HabitProvider>(context, listen: false).habits[habitIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
      ),
      body: ListView.builder(
        itemCount: habit.progress.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text('Day ${index + 1}'),
            value: habit.progress[index],
            onChanged: (bool? value) {
              if (value != null) {
                Provider.of<HabitProvider>(context, listen: false)
                    .updateHabitProgress(habitIndex, index, value);

                // Schedule a notification when a habit is marked as completed
                if (value) {
                  final now = TimeOfDay.now();
                  notificationService.scheduleDailyNotification(
                    habit.hashCode,
                    'Good job!',
                    'You have completed your habit today!',
                    now,
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
