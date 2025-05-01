import 'package:flutter/material.dart';

import '../../../../core/widget/width_height.dart';

class PoolCard extends StatelessWidget {
  const PoolCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(

                color: Colors.grey,
                borderRadius: BorderRadius.circular(60),
              ),
              width: 60,
              height: 60,
              child: Center(child: Text('3',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
            ),
            width20,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('홍길동',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                Text('소개자: 아무개'),

              ],
            ),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('2025/01/01 통화'), Text('2025/01/01 통화'), Text('2025/01/01 통화'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
