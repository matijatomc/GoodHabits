import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'create_habit.dart';
import 'package:fl_chart/fl_chart.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: habitProvider.habits.length,
                  itemBuilder: (context, index) {
                    final habit = habitProvider.habits[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              habit.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddHabitScreen(habit: habit, index: index),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(context, habitProvider, index);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Column(
                          children: List.generate(5, (level) {
                            return RadioListTile(
                              title: Text(habit.completionLabels[level]),
                              value: level,
                              groupValue: habit.completionLevel,
                              onChanged: (int? value) {
                                if (value != null) {
                                  habitProvider.updateCompletionLevel(index, value);
                                }
                              },
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    habitProvider.calculateDailyAverage();
                  },
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    'Progress in the Last 7 Days',
                    style: Theme.of(context).textTheme.titleLarge
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getLast7DaysProgress(
                            habitProvider.last28DaysData.length >= 7
                                ? habitProvider.last28DaysData.sublist(habitProvider.last28DaysData.length - 7)
                                : habitProvider.last28DaysData,
                          ),
                          isCurved: true,
                          barWidth: 4,
                          color: Colors.teal,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 0.5,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 || value == 0.5 || value == 1) {
                                return Text('${(value * 100).toInt()}%');
                              }
                              return Container();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              if (value >= 0 && value < 7) {
                                return Text((value + 1).toInt().toString());
                              }
                              return Container();
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      maxY: 1,
                      minY: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Last 28 Days',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.black),
                        onPressed: () {
                          _showInfoDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                _buildCalendarGrid(habitProvider.last28DaysData),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, HabitProvider habitProvider, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: const Text('Are you sure you want to delete this habit?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                habitProvider.removeHabit(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  List<FlSpot> _getLast7DaysProgress(List<double> data) {
    return List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), data[index]);
    });
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Color Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColorInfo(Colors.teal, 'Completed > 75%'),
              _buildColorInfo(Colors.yellow, 'Completed 50% - 75%'),
              _buildColorInfo(Colors.orange, 'Completed 25% - 50%'),
              _buildColorInfo(Colors.red, 'Completed < 25%'),
              _buildColorInfo(const Color.fromARGB(255, 221, 219, 219), 'Not Completed (0%)'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorInfo(Color color, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            color: color,
          ),
          const SizedBox(width: 10),
          Text(description),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<double> last28DaysData) {
    List<Widget> calendarSquares = [];

    for (double completionRate in last28DaysData) {
      Color squareColor;
      if (completionRate == 0){
        squareColor = const Color.fromARGB(255, 221, 219, 219);
      }
      else if (completionRate <= 0.25){
        squareColor = Colors.red;
      }else if (completionRate <= 0.5){
        squareColor = Colors.orange;
      }else if (completionRate <= 0.75){
        squareColor = Colors.yellow;
      }else{
        squareColor = Colors.teal;
      }

      calendarSquares.add(Container(
        margin: const EdgeInsets.all(2),
        width: 16,
        height: 16,
        color: squareColor,
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      children: calendarSquares,
    );
  }
}
