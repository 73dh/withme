import 'package:flutter/material.dart';

class MyCircularIndicator extends StatelessWidget {
  final double size;

  const MyCircularIndicator({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
