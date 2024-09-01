import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'create_habit.dart';
import 'notification.dart';


class HabitListScreen extends StatelessWidget {
  final NotificationService notificationService;

  HabitListScreen({required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Habits'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddHabitScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) {
          return ListView.builder(
            itemCount: habitProvider.habits.length,
            itemBuilder: (context, index) {
              final habit = habitProvider.habits[index];
              return ListTile(
                title: Text(habit.name),
                subtitle: Text(
                    'Completed ${habit.getCompletedDays()} out of ${habit.progress.length} days'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    habitProvider.removeHabit(index);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitProgressScreen(
                        habitIndex: index,
                        notificationService: notificationService,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class HabitProgressScreen extends StatelessWidget {
  final int habitIndex;
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
