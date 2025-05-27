import 'package:flutter/material.dart';

class MyCircularIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const MyCircularIndicator({super.key, this.size = 20, this.color=Colors.black38});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,

        child:  CircularProgressIndicator(color: color,),
      ),
    );
  }
}
