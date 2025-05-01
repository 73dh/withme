import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/widget/width_height.dart';
import 'package:withme/presentation/home/pool/components/pool_card.dart';

class PoolPage extends StatelessWidget {
  const PoolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '등록월: 2021/01',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Column(children: [...List.generate(5, (index) => PoolCard())]),
              height20,
              Text(
                '등록월: 2021/02',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Column(children: [...List.generate(10, (index) => PoolCard())]),
            ],
          ),
        ),
      ),
    );
  }
}
