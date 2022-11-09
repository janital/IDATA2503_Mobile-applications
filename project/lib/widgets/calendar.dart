import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:project/models/project.dart';
import 'package:project/models/task.dart';
import 'package:project/styles/theme.dart';
import 'package:project/widgets/task_list_item.dart';
import 'package:table_calendar/table_calendar.dart';

/// Calendar spanning from 2021 to 2 years in the future.
class Calendar extends StatefulWidget {
  /// [Project] project to display deadline of tasks in calendar for.
  final Project project;

  /// Creates an instance of [Calendar], which displays the deadline of the tasks
  /// in the given `project`.
  const Calendar({super.key, required this.project});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  /// [List] of tasks for the day selected, notifies on value changes.
  late final ValueNotifier<List<dynamic>> _selectedTasks;

  /// [DateTime] day which is focused in the calendar.
  DateTime _focusedDay = DateTime.now();

  /// [Datetime] day which is selected in the calendar.
  DateTime? _selectedDay;

  /// [Map] over [DateTime] deadline as key and [List] of tasks as value.
  late Map<DateTime, dynamic> tasks = {};

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedTasks = ValueNotifier(_getTasksForDay(_selectedDay!));

    /// Creates and returns a [Map] where each deadline in the tasks is a key, and the values
    /// a list of tasks for the deadline.
    Map<DateTime, dynamic> groupTasks() {
      Map<DateTime, dynamic> groupedTasks = {};
      for (var task in widget.project.tasks) {
        DateTime key = DateFormat("dd/MM/yyyy").parse(task.deadline as String);

        List<Task> values = widget.project.tasks
            .where((element) =>
                DateFormat("dd/MM/yyyy").parse(element.deadline as String) ==
                key)
            .toList();
        groupedTasks[key] = values;
      }
      return groupedTasks;
    }

    tasks = LinkedHashMap<DateTime, dynamic>(
      equals: isSameDay,
      hashCode: (DateTime key) =>
          key.day * 1000000 + key.month * 10000 + key.year,
    )..addAll(groupTasks());
  }

  @override
  void dispose() {
    _selectedTasks.dispose();
    super.dispose();
  }

  /// Sets the selected day and focused day on an select day event in calendar.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedTasks.value = _getTasksForDay(selectedDay);
    }
  }

  /// Returns a [List] of tasks which has deadline for the given [DateTime] day.
  List<dynamic> _getTasksForDay(DateTime day) {
    return tasks[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TableCalendar(
          rowHeight: 45.0,
          headerStyle: Themes.calendarHeaderTheme,
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontWeight: FontWeight.w700,
            ),
            weekendStyle: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          firstDay: DateTime.utc(2021, 10, 16),
          lastDay: DateTime.utc(DateTime.now().year + 2, 3, 14),
          focusedDay: _focusedDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          eventLoader: _getTasksForDay,
          calendarStyle: Themes.calendarTheme,
          onPageChanged: (newFocusedDay) {
            _focusedDay = newFocusedDay;
          },
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _selectedTasks,
            builder: (context, List<dynamic> value, child) => ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemCount: value.isEmpty ? 0 : value.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      Jiffy(_selectedDay).format("EEEE, do of MMMM yyyy"),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return TaskListItem(task: value[index - 1]);
              },
            ),
          ),
        ),
      ],
    );
  }
}
