import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/domain/enum/payment_status.dart';
import '../../../../core/presentation/components/animated_text.dart';
import '../../../../core/presentation/components/birthday_badge.dart';
import '../../../../core/presentation/components/payment_status_icon.dart';
import '../../../../core/utils/check_payment_status.dart';
import '../time_line_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/components/animated_text.dart';
import '../../../../core/presentation/components/birthday_badge.dart';
import '../time_line_view_model.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/components/animated_text.dart';
import '../../../../core/presentation/components/birthday_badge.dart';
import '../time_line_view_model.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>
    with TickerProviderStateMixin {
  late final TimeLineViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = TimeLineViewModel();
    viewModel.fetchData();

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;

    const double timelineWidth = 40;
    const double dotRadius = 6;
    const double headerCircleRadius = 28;

    final todos = viewModel.allTodos;
    final totalTodos = viewModel.totalTodos;

    // ✅ 가망고객/계약자 색상
    final prospectColor = brightness == Brightness.light
        ? Colors.deepOrange.shade400
        : Colors.deepOrange.shade200;
    final customerColor = brightness == Brightness.light
        ? Colors.blue.shade500
        : Colors.blue.shade200;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          "할일목록",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // ✅ 범례(legend)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                _buildLegendDot(prospectColor, "가망고객"),
                const SizedBox(width: 8),
                _buildLegendDot(customerColor, "계약자"),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ 전체 Todo 수 원형
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

          // ✅ 할 일 리스트
          Expanded(
            child: Builder(
              builder: (context) {
                if (viewModel.isLoading) {
                  return Center(
                    child: AnimatedText(
                      text: '할일 확인중',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                } else if (viewModel.allTodos.isEmpty) {
                  return Center(
                    child: AnimatedText(
                      text: '등록된 할일이 없습니다.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 15),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final item = todos[index];
                      final isLast = index == todos.length - 1;

                      final date = item.todo.dueDate;
                      final dateText = DateFormat("MM/dd").format(date);
                      final isOverdue = item.todo.dueDate.isBefore(DateTime.now());
                      final bool showDate = index == 0 ||
                          !isSameDay(date, todos[index - 1].todo.dueDate);

                      // ✅ 고객 분류에 따른 색상
                      final isProspect = item.customer.policies.isEmpty;
                      final iconColor =
                      isProspect ? prospectColor : customerColor;

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 800 + index * 150),
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
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ 날짜 최초 1번만 표시
                                SizedBox(
                                  width: 90,
                                  child: showDate
                                      ? Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        dateText,
                                        style: TextStyle(
                                          color: colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      _buildWeekdayChip(context, date),
                                    ],
                                  )
                                      : const SizedBox.shrink(),
                                ),

                                // Dot + 세로선
                                SizedBox(
                                  width: timelineWidth,
                                  child: Column(
                                    children: [
                                      _BlinkingDot(
                                        isOverdue: isOverdue,
                                        radius: dotRadius * 1.6,
                                        backgroundColor: iconColor,
                                        label: item.customer.name.isNotEmpty
                                            ? item.customer.name[0]
                                            : "?",
                                        labelColor: brightness ==
                                            Brightness.light
                                            ? Colors.black
                                            : Colors.white,
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

                                // 고객명 + 생일뱃지 + 할 일 내용
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // ✅ 아이콘 옆에 이름 표시
                                          Text(
                                            item.customer.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: iconColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          BirthdayBadge(
                                            birth: item.customer.birth,
                                            cakeColor: Colors.pinkAccent,
                                            iconSize: 18,
                                            textSize: 12,
                                            isShowDate: true,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        item.todo.content,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontStyle: FontStyle.italic,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildWeekdayChip(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    Color? bgColor;
    Color textColor = theme.colorScheme.onSurfaceVariant;

    if (date.weekday == DateTime.saturday) {
      bgColor = isLight ? Colors.blue[100] : Colors.blue[900];
      textColor = isLight ? Colors.blue[800]! : Colors.blue[200]!;
    } else if (date.weekday == DateTime.sunday) {
      bgColor = isLight ? Colors.red[100] : Colors.red[900];
      textColor = isLight ? Colors.red[800]! : Colors.red[200]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        DateFormat('E', 'ko_KR').format(date),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// ✅ 깜빡이는 Dot
class _BlinkingDot extends StatefulWidget {
  final bool isOverdue;
  final double radius;
  final Color backgroundColor;
  final String label;
  final Color labelColor;

  const _BlinkingDot({
    required this.isOverdue,
    required this.radius,
    required this.backgroundColor,
    required this.label,
    required this.labelColor,
  });

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot({required double opacity}) {
    final theme = Theme.of(context);

    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:widget.backgroundColor.withValues(alpha: opacity * 0.6),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: widget.labelColor,
          shadows: [
            Shadow(
              offset: const Offset(0.5, 0.5),
              blurRadius: 1,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOverdue) {
      return _buildDot(opacity: 1);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return _buildDot(opacity: _controller.value);
      },
    );
  }
}
