// stream_todo_text.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../core_presentation_import.dart';

class StreamTodoText extends StatefulWidget {
  final List<String> todoList;
  final TextStyle? style;
  final Duration stepDelay; // 글자 이동 속도
  final double maxWidth; // 최대 보이는 폭

  const StreamTodoText({
    super.key,
    required this.todoList,
    this.style,
    this.stepDelay = const Duration(milliseconds: 100),
    this.maxWidth = 50,
  });

  @override
  State<StreamTodoText> createState() => _StreamTodoTextState();
}

class _StreamTodoTextState extends State<StreamTodoText> {
  int _currentIndex = 0;
  double _offsetX = 0;
  Timer? _timer;
  double _textWidth = 0;
  double _clipWidth = 0;

  @override
  void initState() {
    super.initState();
    if (widget.todoList.isNotEmpty) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant StreamTodoText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.todoList.isEmpty) {
      _timer?.cancel();
      setState(() {
        _currentIndex = 0;
      });
    } else if (oldWidget.todoList != widget.todoList) {
      _timer?.cancel();
      setState(() {
        _currentIndex = 0;
      });
      _startAnimation();
    }
  }

  void _calculateWidths(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    _textWidth = painter.width;
    _clipWidth = _textWidth < widget.maxWidth ? _textWidth : widget.maxWidth;
  }

  void _startAnimation() {
    if (widget.todoList.isEmpty) return;

    _timer?.cancel();
    final currentText = widget.todoList[_currentIndex];
    _calculateWidths(currentText);

    _offsetX = _clipWidth;

    _timer = Timer.periodic(widget.stepDelay, (timer) {
      if (!mounted || widget.todoList.isEmpty) return;

      setState(() {
        _offsetX -= 1;
      });

      if (_offsetX <= -_textWidth) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 300), _nextTodo);
      }
    });
  }

  void _nextTodo() {
    if (!mounted || widget.todoList.isEmpty) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.todoList.length;
    });

    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.todoList.isEmpty) return const SizedBox.shrink();
    if (_currentIndex >= widget.todoList.length) return const SizedBox.shrink();

    final currentText = widget.todoList[_currentIndex];

    return ClipRect(
      child: SizedBox(
        width: _clipWidth,
        child: Transform.translate(
          offset: Offset(_offsetX, 0),
          child: SizedBox(
            width: _textWidth,
            child: Text(
              currentText,
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }
}
