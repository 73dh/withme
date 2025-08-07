import '../../../domain/model/todo_model.dart';
import '../core_presentation_import.dart';
import 'dart:async';

import '../../../domain/model/todo_model.dart';
import '../core_presentation_import.dart';

class StreamTodoText extends StatefulWidget {
  final List<TodoModel> todoList;

  const StreamTodoText({super.key, required this.todoList});

  @override
  State<StreamTodoText> createState() => _StreamTodoTextState();
}

class _StreamTodoTextState extends State<StreamTodoText>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _fadeController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late Timer _textTimer;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    widget.todoList.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    _slideController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.linear));

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    _fadeController.forward(); // 처음에 FadeIn

    _textTimer = Timer.periodic(const Duration(seconds: 7), (_) async {
      await _fadeController.reverse(); // FadeOut
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.todoList.length;
      });
      await _fadeController.forward(); // FadeIn
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _textTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.todoList.isEmpty) return const SizedBox.shrink();

    final currentTodo = widget.todoList[_currentIndex];

    return ClipRect(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            currentTodo.content,
            style: const TextStyle(fontSize: 12, color: Colors.purple),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
