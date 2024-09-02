import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'habit.dart';

class AddHabitScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _completionLabelControllers = List.generate(
    5,
    (index) => TextEditingController(),
  );

  AddHabitScreen({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Habit Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ...List.generate(5, (index) {
                return TextFormField(
                  controller: _completionLabelControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Completion level ${getLevel(index)}',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter completion level ${getLevel(index)}';
                    }
                    return null;
                  },
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Provider.of<HabitProvider>(context, listen: false).addHabit(
                      Habit(
                        name: _nameController.text,
                        completionLabels: _completionLabelControllers
                            .map((controller) => controller.text)
                            .toList(),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
