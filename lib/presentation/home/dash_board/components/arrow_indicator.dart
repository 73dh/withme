import 'package:flutter/material.dart';

class ArrowIndicator extends StatelessWidget {
  final bool isRight;

  const ArrowIndicator({super.key, required this.isRight});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 30,
        alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isRight ? Alignment.centerLeft : Alignment.centerRight,
            end: isRight ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.8),
            ],
          ),
        ),
        child: Icon(
          isRight ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          size: 40,
          color: Colors.red,
        ),
      ),
    );
  }
}
