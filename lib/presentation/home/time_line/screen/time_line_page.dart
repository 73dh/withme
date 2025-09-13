import 'package:intl/intl.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';
import 'package:withme/domain/domain_import.dart';

import '../../../../core/presentation/components/birthday_badge.dart';
import '../../../../core/presentation/components/insured_members_icon.dart';
import '../time_line_view_model.dart';
import 'package:intl/intl.dart';
import 'package:withme/core/presentation/core_presentation_import.dart';

import '../../../../core/presentation/components/birthday_badge.dart';
import '../../../../core/presentation/components/insured_members_icon.dart';
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

    const double timelineWidth = 50;
    const double dotRadius = 6;
    const double headerCircleRadius = 18;

    final todos = viewModel.allTodos;
    final totalTodos = viewModel.totalTodos;

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
          Row(
            children: [
              _legendDot(
                color: getSexIconColor("남", colorScheme),
                label: "남성",
              ),
              const SizedBox(width: 12),
              _legendDot(
                color: getSexIconColor("여", colorScheme),
                label: "여성",
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 전체 Todo 수 원형(헤더)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 90),
                SizedBox(
                  width: timelineWidth,
                  child: _CircleDot(
                    size: headerCircleRadius * 2,
                    color: colorScheme.surfaceContainerHighest,
                    borderColor: colorScheme.onSurface,
                    customText: "$totalTodos",
                  ),
                ),
              ],
            ),

            // 할 일 리스트
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
                  } else if (todos.isEmpty) {
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
                      padding: const EdgeInsets.only(top: 14),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final item = todos[index];
                        final isLast = index == todos.length - 1;

                        final date = item.todo.dueDate;
                        final dateText = DateFormat("MM/dd").format(date);
                        final isOverdue = item.todo.dueDate.isBefore(
                          DateTime.now(),
                        );
                        final bool showDate =
                            index == 0 ||
                                !isSameDay(date, todos[index - 1].todo.dueDate);

                        final dotColor = getSexIconColor(
                          item.customer.sex,
                          colorScheme,
                        );

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
                              // 메인 Row: 날짜 | 타임라인(dot+line) | 콘텐츠
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 날짜 영역
                                  SizedBox(
                                    width: 90,
                                    child: showDate
                                        ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          dateText,
                                          style: TextStyle(
                                            color: colorScheme
                                                .onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        _buildWeekdayChip(
                                          context,
                                          date,
                                        ),
                                      ],
                                    )
                                        : const SizedBox.shrink(),
                                  ),

                                  // dot 영역
                                  SizedBox(
                                    width: timelineWidth,
                                    child: Column(
                                      children: [
                                        _BlinkingDot(
                                          isOverdue: isOverdue,
                                          size: dotRadius * 2.2,
                                          color: dotColor.withValues(alpha: 0.9),
                                          borderColor: dotColor,
                                        ),
                                        if (!isLast)
                                          Container(
                                            margin: const EdgeInsets.only(top: 0),
                                            width: 2,
                                            height: 57,
                                            color: colorScheme.outline,
                                          ),
                                      ],
                                    ),
                                  ),

                                  // const SizedBox(width: 6),

                                  // 콘텐츠 영역
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.customer.name,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: dotColor,
                                              ),
                                            ),
                                            // const SizedBox(width: 6),

                                            // ✅ BirthdayBadge + InsuranceAgeWidget 묶음
                                            Row(
                                              children: [
                                                const SizedBox(width: 2),
                                                BirthdayBadge(
                                                  birth: item.customer.birth,
                                                  cakeColor: Colors.pinkAccent,
                                                  iconSize: 16,
                                                  textSize: 12,
                                                  isShowDate: true,
                                                ),

                                                if (item.customer.insuranceInfo
                                                    .difference !=
                                                    null &&
                                                    item
                                                        .customer
                                                        .insuranceInfo
                                                        .insuranceChangeDate !=
                                                        null)

                                                  InsuranceAgeWidget(
                                                    difference: item.customer
                                                        .insuranceInfo
                                                        .difference!,
                                                    isUrgent: item.customer
                                                        .insuranceInfo.isUrgent,
                                                    insuranceChangeDate: item
                                                        .customer
                                                        .insuranceInfo
                                                        .insuranceChangeDate!,
                                                    colorScheme: colorScheme,
                                                    isShowText: false,
                                                  ),
                                              ],
                                            ),

                                            // 계약자일 경우 InsuredMembersIcon
                                            if (item.customer.policies
                                                .isNotEmpty) ...[
                                              const SizedBox(width: 6),
                                              Stack(
                                                clipBehavior: Clip.none,
                                                alignment: Alignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 15,
                                                    height: 15,
                                                  ),
                                                  Positioned(
                                                    top: -10,
                                                    child: InsuredMembersIcon(
                                                      customer: item.customer,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 5),

                                        // 할 일 내용
                                        Text(
                                          item.todo.content,
                                          style: TextStyle(
                                            fontSize: 12,
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
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

// ----------------------
// Dot / Blinking dot
// ----------------------

class _CircleDot extends StatelessWidget {
  final double size;
  final Color color;
  final Color borderColor;
  final String? customText;
  final Animation<double>? fadeAnimation;

  const _CircleDot({
    required this.size,
    required this.color,
    required this.borderColor,
    this.customText,
    this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final innerText = customText != null
        ? Text(
      customText!,
      style: TextStyle(
        fontSize: size * 0.4,
        fontWeight: FontWeight.bold,
        color: borderColor,
      ),
    )
        : null;

    if (fadeAnimation != null) {
      return AnimatedBuilder(
        animation: fadeAnimation!,
        builder: (_, __) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(fadeAnimation!.value),
            border: Border.all(color: borderColor, width: 1.6),
          ),
          alignment: Alignment.center,
          child: innerText,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderColor, width: 1.6),
      ),
      alignment: Alignment.center,
      child: innerText,
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  final bool isOverdue;
  final double size;
  final Color color;
  final Color borderColor;

  const _BlinkingDot({
    required this.isOverdue,
    required this.size,
    required this.color,
    required this.borderColor,
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
    );

    if (widget.isOverdue) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _BlinkingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOverdue && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isOverdue && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    if (_controller.isAnimating) _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CircleDot(
      size: widget.size,
      color: widget.color,
      borderColor: widget.borderColor,
      fadeAnimation: widget.isOverdue ? _controller : null,
    );
  }
}

// ----------------------
// 범례 Dot 위젯
// ----------------------

Widget _legendDot({
  required Color color,
  required String label,
}) {
  return Row(
    children: [
      _CircleDot(
        size: 12,
        color: color,
        borderColor: color,
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 11),
      ),
    ],
  );
}

//
// class TimelinePage extends StatefulWidget {
//   const TimelinePage({super.key});
//
//   @override
//   State<TimelinePage> createState() => _TimelinePageState();
// }
//
// class _TimelinePageState extends State<TimelinePage>
//     with TickerProviderStateMixin {
//   late final TimeLineViewModel viewModel;
//
//   @override
//   void initState() {
//     super.initState();
//     viewModel = TimeLineViewModel();
//     viewModel.fetchData();
//
//     viewModel.addListener(() {
//       if (mounted) setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     viewModel.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     const double timelineWidth = 50;
//     const double dotRadius = 6;
//     const double headerCircleRadius = 18;
//
//     final todos = viewModel.allTodos;
//     final totalTodos = viewModel.totalTodos;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         titleSpacing: 20,
//         title: const Text(
//           "할일목록",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontStyle: FontStyle.italic,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
//
//       actions: [
//         Row(
//           children: [
//             _legendDot(
//               color: getSexIconColor("남", colorScheme),
//               label: "남성",
//             ),
//             const SizedBox(width: 12),
//             _legendDot(
//               color: getSexIconColor("여", colorScheme),
//               label: "여성",
//             ),
//             const SizedBox(width: 16),
//           ],
//         ),
//       ],
//     ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             // 전체 Todo 수 원형(헤더)
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(width: 90),
//                 SizedBox(
//                   width: timelineWidth,
//                   child: _CircleDot(
//                     size: headerCircleRadius * 2,
//                     color: colorScheme.surfaceContainerHighest,
//                     borderColor: colorScheme.onSurface,
//                     customText: "$totalTodos",
//                   ),
//                 ),
//               ],
//             ),
//
//             // 할 일 리스트
//             Expanded(
//               child: Builder(
//                 builder: (context) {
//                   if (viewModel.isLoading) {
//                     return Center(
//                       child: AnimatedText(
//                         text: '할일 확인중',
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           color: colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                     );
//                   } else if (todos.isEmpty) {
//                     return Center(
//                       child: AnimatedText(
//                         text: '등록된 할일이 없습니다.',
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           color: colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                     );
//                   } else {
//                     return ListView.builder(
//                       padding: const EdgeInsets.only(top: 14),
//                       itemCount: todos.length,
//                       itemBuilder: (context, index) {
//                         final item = todos[index];
//                         final isLast = index == todos.length - 1;
//
//                         final date = item.todo.dueDate;
//                         final dateText = DateFormat("MM/dd").format(date);
//                         final isOverdue = item.todo.dueDate.isBefore(
//                           DateTime.now(),
//                         );
//                         final bool showDate =
//                             index == 0 ||
//                             !isSameDay(date, todos[index - 1].todo.dueDate);
//
//                         final dotColor = getSexIconColor(
//                           item.customer.sex,
//                           colorScheme,
//                         );
//
//                         return TweenAnimationBuilder<double>(
//                           tween: Tween(begin: 0, end: 1),
//                           duration: Duration(milliseconds: 800 + index * 150),
//                           curve: Curves.easeOutCubic,
//                           builder: (context, value, child) {
//                             return Opacity(
//                               opacity: value,
//                               child: Transform.translate(
//                                 offset: Offset(0, (1 - value) * -20),
//                                 child: child,
//                               ),
//                             );
//                           },
//                           child: Column(
//                             children: [
//                               // 메인 Row: 날짜 | 타임라인(dot+line) | 콘텐츠
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // 날짜 영역 — dot 중앙 기준으로 세로 가운데 정렬
//                                   SizedBox(
//                                     width: 90,
//                                     child:
//                                         showDate
//                                             ? Column(
//                                               mainAxisSize: MainAxisSize.min,
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.end,
//                                               children: [
//                                                 Text(
//                                                   dateText,
//                                                   style: TextStyle(
//                                                     color:
//                                                         colorScheme
//                                                             .onSurfaceVariant,
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 2),
//                                                 _buildWeekdayChip(
//                                                   context,
//                                                   date,
//                                                 ),
//                                               ],
//                                             )
//                                             : const SizedBox.shrink(),
//                                   ),
//
//                                   // dot 영역 — 높이 고정하고 내용 가운데 정렬
//                                   SizedBox(
//                                     width: timelineWidth,
//                                     child: Column(
//                                       children: [
//                                         // Dot
//
//                                         _BlinkingDot(
//                                           isOverdue: isOverdue,
//                                           size: dotRadius * 2.2,
//                                           color: dotColor.withValues(alpha: 0.9),
//                                           borderColor: dotColor,
//                                         ),
//
//                                         // 선 (dot 바로 아래에서 시작하도록)
//                                         if (!isLast)
//                                           Container(
//                                             margin: const EdgeInsets.only(top: 0), // dot과 바로 연결
//                                             width: 2,            // 선의 두께
//                                             height: 57,          // 선의 길이 (고정값)
//                                             color: colorScheme.outline,
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//
//
//
//
//                                   const SizedBox(width: 8),
//
//                                   // 콘텐츠 영역 — 첫 줄(이름)은 dotContainerHeight에 맞춰 세로 가운데 정렬
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         // 이름 행: 높이를 dotContainerHeight로 제한하여 dot과 정렬
//                                         SizedBox(
//                                           child: Align(
//                                             alignment: Alignment.topLeft,
//                                             child: Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   item.customer.name,
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.bold,
//                                                     color: dotColor,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 6),
//                                                 BirthdayBadge(
//                                                   birth: item.customer.birth,
//                                                   cakeColor: Colors.pinkAccent,
//                                                   iconSize: 16,
//                                                   textSize: 12,
//                                                   isShowDate: true,
//                                                 ),
//
//                                                 // 계약자일 경우 InsuredMembersIcon
//                                                 if (item
//                                                     .customer
//                                                     .policies
//                                                     .isNotEmpty) ...[
//                                                   const SizedBox(width: 6),
//                                                   Stack(
//                                                     clipBehavior: Clip.none,
//                                                     // Stack 영역 밖으로 나가도 보이게
//                                                     alignment: Alignment.center,
//                                                     children: [
//                                                       const SizedBox(
//                                                         width: 15,
//                                                         height: 15,
//                                                       ), // 기준 박스
//                                                       Positioned(
//                                                         top: -10, // ✅ 위로 살짝 올림
//                                                         child:
//                                                             InsuredMembersIcon(
//                                                               customer:
//                                                                   item.customer,
//                                                               size: 18,
//                                                             ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ],
//                                             ),
//                                           ),
//                                         ),
// height(5),
//                                         // 할 일 내용 (이름 행 아래로)
//                                         Text(
//                                           item.todo.content,
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             fontStyle: FontStyle.italic,
//                                             color: colorScheme.onSurface,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   bool isSameDay(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;
//
//   Widget _buildWeekdayChip(BuildContext context, DateTime date) {
//     final theme = Theme.of(context);
//     final isLight = theme.brightness == Brightness.light;
//
//     Color? bgColor;
//     Color textColor = theme.colorScheme.onSurfaceVariant;
//
//     if (date.weekday == DateTime.saturday) {
//       bgColor = isLight ? Colors.blue[100] : Colors.blue[900];
//       textColor = isLight ? Colors.blue[800]! : Colors.blue[200]!;
//     } else if (date.weekday == DateTime.sunday) {
//       bgColor = isLight ? Colors.red[100] : Colors.red[900];
//       textColor = isLight ? Colors.red[800]! : Colors.red[200]!;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         DateFormat('E', 'ko_KR').format(date),
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//       ),
//     );
//   }
// }
//
// // ----------------------
// // Dot / Blinking dot 구현
// // ----------------------
//
// class _CircleDot extends StatelessWidget {
//   final double size;
//   final Color color;
//   final Color borderColor;
//   final String? customText;
//   final Animation<double>? fadeAnimation;
//
//   const _CircleDot({
//     required this.size,
//     required this.color,
//     required this.borderColor,
//     this.customText,
//     this.fadeAnimation,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final innerText =
//         customText != null
//             ? Text(
//               customText!,
//               style: TextStyle(
//                 fontSize: size * 0.4,
//                 fontWeight: FontWeight.bold,
//                 color: borderColor,
//               ),
//             )
//             : null;
//
//     if (fadeAnimation != null) {
//       return AnimatedBuilder(
//         animation: fadeAnimation!,
//         builder:
//             (_, __) => Container(
//               width: size,
//               height: size,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: color.withOpacity(fadeAnimation!.value),
//                 border: Border.all(color: borderColor, width: 1.6),
//               ),
//               alignment: Alignment.center,
//               child: innerText,
//             ),
//       );
//     }
//
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: color,
//         border: Border.all(color: borderColor, width: 1.6),
//       ),
//       alignment: Alignment.center,
//       child: innerText,
//     );
//   }
// }
//
// class _BlinkingDot extends StatefulWidget {
//   final bool isOverdue;
//   final double size;
//   final Color color;
//   final Color borderColor;
//
//   const _BlinkingDot({
//     required this.isOverdue,
//     required this.size,
//     required this.color,
//     required this.borderColor,
//   });
//
//   @override
//   State<_BlinkingDot> createState() => _BlinkingDotState();
// }
//
// class _BlinkingDotState extends State<_BlinkingDot>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     if (widget.isOverdue) {
//       _controller.repeat(reverse: true);
//     }
//   }
//
//   @override
//   void didUpdateWidget(covariant _BlinkingDot oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isOverdue && !_controller.isAnimating) {
//       _controller.repeat(reverse: true);
//     } else if (!widget.isOverdue && _controller.isAnimating) {
//       _controller.stop();
//     }
//   }
//
//   @override
//   void dispose() {
//     if (_controller.isAnimating) _controller.stop();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _CircleDot(
//       size: widget.size,
//       color: widget.color,
//       borderColor: widget.borderColor,
//       fadeAnimation: widget.isOverdue ? _controller : null,
//     );
//   }
// }
//
// // ----------------------
// // 범례 Dot 위젯
// // ----------------------
//
// Widget _legendDot({
//   required Color color,
//   required String label,
// }) {
//   return Row(
//     children: [
//       _CircleDot(
//         size: 12,            // 타임라인 dot보다 살짝 작게
//         color: color,
//         borderColor: color,  // 동일한 border
//       ),
//       const SizedBox(width: 4),
//       Text(
//         label,
//         style: const TextStyle(fontSize: 11),
//       ),
//     ],
//   );
// }
