// stream_todo_text.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/model/todo_model.dart';
import '../../ui/core_ui_import.dart';
import '../core_presentation_import.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'dart:async';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

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
    this.maxWidth = 70,
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
    if (widget.todoList.isNotEmpty) _startAnimation();
  }

  void _calculateWidths(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    _textWidth = painter.width;

    // 보이는 폭: 글자 길이 기반, 최대 70px
    _clipWidth = _textWidth < widget.maxWidth ? _textWidth : widget.maxWidth;
  }

  void _startAnimation() {
    _timer?.cancel();
    final currentText = widget.todoList[_currentIndex];
    _calculateWidths(currentText);

    // 오른쪽 끝에서 시작
    _offsetX = _clipWidth;

    _timer = Timer.periodic(widget.stepDelay, (timer) {
      if (!mounted) return;

      setState(() {
        _offsetX -= 1; // 한 스텝씩 왼쪽으로 이동
      });

      // 전체 텍스트가 왼쪽 끝을 지나가면
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
    final currentText = widget.todoList[_currentIndex];

    return ClipRect(
      child: SizedBox(
        width: _clipWidth, // 글자 길이에 맞춘 폭, 최대 70
        child: Transform.translate(
          offset: Offset(_offsetX, 0), // 오른쪽 → 왼쪽
          child: SizedBox(
            width: _textWidth, // 텍스트 전체 폭
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

























//
// class StreamTodoText extends StatefulWidget {
//   final List<TodoModel> todoList;
//   final String sex;
//   final Color? textColor;
//
//   const StreamTodoText({
//     super.key,
//     required this.todoList,
//     required this.sex,
//     this.textColor,
//   });
//
//   @override
//   State<StreamTodoText> createState() => _StreamTodoTextState();
// }
//
// class _StreamTodoTextState extends State<StreamTodoText>
//     with TickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<Offset> _slideAnimation;
//   late final Animation<double> _fadeAnimation;
//   int _currentIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       duration: const Duration(seconds: 6),
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(1.0, 0.0),
//       end: const Offset(-1.0, 0.0),
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
//
//     _fadeAnimation = TweenSequence<double>([
//       TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
//       TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
//       TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
//     ]).animate(_controller);
//
//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         setState(() {
//           _currentIndex = (_currentIndex + 1) % widget.todoList.length;
//         });
//         _controller.reset();
//         _controller.forward();
//       }
//     });
//
//     if (widget.todoList.isNotEmpty) _controller.forward();
//   }
//
//   @override
//   void didUpdateWidget(covariant StreamTodoText oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.todoList.isNotEmpty &&
//         (oldWidget.todoList.isEmpty || oldWidget.todoList != widget.todoList)) {
//       _currentIndex = 0;
//       _controller.reset();
//       _controller.forward();
//     } else if (widget.todoList.isEmpty) {
//       _controller.stop();
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.todoList.isEmpty) return const SizedBox.shrink();
//     final currentTodo = widget.todoList[_currentIndex];
//
//     final theme = Theme.of(context);
//
//     // 성별에 맞는 색상 지정 (ColorStyles 또는 colorScheme 활용)
//     final Color textColor =
//         widget.textColor ??
//         (widget.sex == '남'
//             ? ColorStyles
//                 .manColor // 예: 파랑
//             : ColorStyles.womanColor); // 예: 핑크
//
//     return ClipRect(
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: Text(
//             currentTodo.content,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: textColor,
//               fontWeight: FontWeight.bold,
//             ),
//             maxLines: 1,
//             // overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ),
//     );
//   }
// }
