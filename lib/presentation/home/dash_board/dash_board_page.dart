import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('${GoRouterState.of(context).path}'),);
    
  }
}
