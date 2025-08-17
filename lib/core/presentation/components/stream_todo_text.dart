import 'dart:async';

import '../../../domain/model/todo_model.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
import 'dart:async';

import '../../../domain/model/todo_model.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';
// stream_todo_text.dart
import 'package:flutter/material.dart';
import '../../../domain/model/todo_model.dart';



class StreamTodoText extends StatefulWidget {
  final List<TodoModel> todoList;
  final String sex;
  final Color? textColor;

  const StreamTodoText({
    super.key,
    required this.todoList,
    required this.sex,
    this.textColor,
  });

  @override
  State<StreamTodoText> createState() => _StreamTodoTextState();
}

class _StreamTodoTextState extends State<StreamTodoText>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.todoList.length;
        });
        _controller.reset();
        _controller.forward();
      }
    });

    if (widget.todoList.isNotEmpty) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant StreamTodoText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.todoList.isNotEmpty &&
        (oldWidget.todoList.isEmpty || oldWidget.todoList != widget.todoList)) {
      _currentIndex = 0;
      _controller.reset();
      _controller.forward();
    } else if (widget.todoList.isEmpty) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.todoList.isEmpty) return const SizedBox.shrink();
    final currentTodo = widget.todoList[_currentIndex];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 성별에 맞는 색상 지정 (ColorStyles 또는 colorScheme 활용)
    final Color textColor = widget.textColor ??
        (widget.sex == '남'
            ? ColorStyles.manColor // 예: 파랑
            : ColorStyles.womanColor); // 예: 핑크

    return ClipRect(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            currentTodo.content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
