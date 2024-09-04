import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'habit.dart';

class AddHabitScreen extends StatelessWidget {
  final Habit? habit;
  final int? index;

  AddHabitScreen({super.key, this.habit, this.index});

  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _completionControllers =
      List.generate(5, (index) => TextEditingController());

  int getLevel(int level){
    switch(level) {
      case 0:
        return 5;
      case 1:
        return 4;
      case 2:
        return 3;
      case 3:
        return 2;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (habit != null) {
      _nameController.text = habit!.name;
      for (int i = 0; i < 5; i++) {
        _completionControllers[i].text = habit!.completionLabels[i];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(habit == null ? 'Add New Habit' : 'Edit Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Habit Name'),
              style: const TextStyle(color: Colors.teal),
            ),
            const SizedBox(height: 10),
            ...List.generate(5, (index) {
              return TextField(
                controller: _completionControllers[index],
                decoration: InputDecoration(
                  labelText: 'Completion Level ${getLevel(index)}',
                ),
                style: const TextStyle(color: Colors.teal),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_validateInputs(context)) {
                  String name = _nameController.text;
                  List<String> completionLabels = _completionControllers
                      .map((controller) => controller.text)
                      .toList();

                  Habit newHabit = Habit(
                    name: name,
                    completionLabels: completionLabels,
                    completionLevel: habit?.completionLevel ?? 0,
                    completionData: habit?.completionData ?? {},
                  );

                  if (habit == null) {
                    Provider.of<HabitProvider>(context, listen: false)
                        .addHabit(newHabit);
                  } else {
                    Provider.of<HabitProvider>(context, listen: false)
                        .updateHabit(index!, newHabit);
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(habit == null ? 'Add Habit' : 'Update Habit'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateInputs(BuildContext context) {
    if (_nameController.text.isEmpty) {
      _showErrorMessage(context, 'Please enter a habit name.');
      return false;
    }

    for (int i = 0; i < _completionControllers.length; i++) {
      if (_completionControllers[i].text.isEmpty) {
        _showErrorMessage(context, 'Please fill in all completion labels.');
        return false;
      }
    }

    return true;
  }

  void _showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
