import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('${GoRouterState.of(context).uri}'),);
    
  }
}
