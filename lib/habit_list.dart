import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'create_habit.dart';
import 'package:fl_chart/fl_chart.dart';

class HabitListScreen extends StatelessWidget {
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
          return SingleChildScrollView(  // Enable scrolling
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Prevent ListView from scrolling independently
                  itemCount: habitProvider.habits.length,
                  itemBuilder: (context, index) {
                    final habit = habitProvider.habits[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          habit.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
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
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                habitProvider.removeHabit(index);
                              },
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    habitProvider.calculateDailyAverage();
                  },
                  child: Text('Submit'),
                ),
                SizedBox(height: 20),
                Text(
                  'Progress in the Last 7 Days',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getLast7DaysProgress(
                            habitProvider.last30DaysData.length >= 7
                                ? habitProvider.last30DaysData.sublist(habitProvider.last30DaysData.length - 7)
                                : habitProvider.last30DaysData,
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
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      maxY: 1,
                      minY: 0,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Last 30 Days',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _buildCalendarGrid(habitProvider.last30DaysData),
              ],
            ),
          );
        },
      ),
    );
  }

  List<FlSpot> _getLast7DaysProgress(List<double> data) {
    return List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), data[index]);
    });
  }

  Widget _buildCalendarGrid(List<double> last30DaysData) {
    List<Widget> calendarSquares = [];

    for (double completionRate in last30DaysData) {
      Color squareColor;
      if (completionRate == 0){
        squareColor = const Color.fromARGB(255, 221, 219, 219);
      }
      else{
        squareColor = Colors.teal.withOpacity(completionRate);
      }
      calendarSquares.add(Container(
        margin: EdgeInsets.all(2),
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
