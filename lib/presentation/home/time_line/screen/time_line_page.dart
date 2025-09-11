import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/model/todo_model.dart';
import '../time_line_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/model/todo_model.dart';
import '../time_line_view_model.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late final TimeLineViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = TimeLineViewModel();
    viewModel.fetchData(force: false);
    viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double timelineWidth = 40;
    const double dotRadius = 6;
    const double headerCircleRadius = 28;

    final todos = viewModel.allTodos; // ✅ ViewModel에서 제공
    final totalTodos = viewModel.totalTodos;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 45),

          // 전체 Todo 원
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 90),
              SizedBox(
                width: timelineWidth,
                child: CircleAvatar(
                  radius: headerCircleRadius,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Text(
                    "$totalTodos",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text("할 일이 없습니다."))
                : ListView.builder(
              padding: const EdgeInsets.only(top: 15),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final item = todos[index];
                final isLast = index == todos.length - 1;

                final dateText = DateFormat("MM/dd (E)", "ko_KR")
                    .format(item.todo.dueDate);

                Color dateColor;
                switch (item.todo.dueDate.weekday) {
                  case DateTime.saturday:
                    dateColor = colorScheme.primary;
                    break;
                  case DateTime.sunday:
                    dateColor = colorScheme.error;
                    break;
                  default:
                    dateColor = colorScheme.onSurfaceVariant;
                }

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration:
                  Duration(milliseconds: 800 + index * 150),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * -20),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          dateText,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: dateColor),
                        ),
                      ),
                      SizedBox(
                        width: timelineWidth,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: dotRadius,
                              backgroundColor:
                              colorScheme.primary,
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 40,
                                color: colorScheme.outline,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.customerName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                            Text(
                              item.todo.content,
                              style: TextStyle(
                                  color: colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
