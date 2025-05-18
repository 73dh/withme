import 'package:flutter/material.dart';

class PartBox extends StatelessWidget {
  final Widget child;
  final Color? color;

  const PartBox({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade500, width: 1.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
