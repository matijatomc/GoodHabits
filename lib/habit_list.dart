import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';
import 'create_habit.dart';
import 'notification.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitListScreen extends StatelessWidget {
  final NotificationService notificationService;

  const HabitListScreen({super.key, required this.notificationService});

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
      body: SingleChildScrollView( 
        child: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: habitProvider.habits.length,
                  itemBuilder: (context, index) {
                    final habit = habitProvider.habits[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name),
                        Column(
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
                      ],
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
                const SizedBox(height: 20),
                const Text('Progress in the Last 7 Days'),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getLast7DaysProgress(habitProvider.last7DaysData),
                          isCurved: true,
                          barWidth: 4,
                          color: Colors.blue,
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
                const Text('Progress in the Last 30 Days'),
                TableCalendar(
                  firstDay: DateTime.utc(2022, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      return _buildCalendarMarker(day, habitProvider.completionMap);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<FlSpot> _getLast7DaysProgress(List<double> data) {
    return List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), data[index]);
    });
  }

  Widget? _buildCalendarMarker(DateTime day, Map<DateTime, double> completionMap) {
    if (completionMap.containsKey(day)) {
      double completionRate = completionMap[day]!;
      Color color;
      if (completionRate >= 0.75) {
        color = Colors.green;
      } else if (completionRate >= 0.5) {
        color = Colors.yellow;
      } else if (completionRate >= 0.25) {
        color = Colors.orange;
      } else {
        color = Colors.red;
      }
      return Container(
        margin: const EdgeInsets.all(2),
        width: 16,
        height: 16,
        color: color,
      );
    }
    return null;
  }
}