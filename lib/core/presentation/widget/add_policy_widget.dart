import 'package:flutter/material.dart';
import 'package:withme/core/ui/const/duration.dart';
import 'package:withme/core/ui/icon/const.dart';

class AddPolicyWidget extends StatefulWidget {
  final void Function() onTap;
  final double size;

  const AddPolicyWidget({super.key, required this.onTap, this.size = 50});

  @override
  State<AddPolicyWidget> createState() => _AddPolicyWidgetState();
}

class _AddPolicyWidgetState extends State<AddPolicyWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.durationThreeSec,
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.blue,
    ).animate(_animationController!);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  shape: BoxShape.circle,
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 28,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
