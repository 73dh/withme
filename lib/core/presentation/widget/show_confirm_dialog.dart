import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/presentation/widget/width_height.dart';

Future<bool?> showConfirmDialog(BuildContext context,{required String text}) {
 return showDialog(
    context: context,
    barrierDismissible: false, // 바깥 탭 시 닫히지 않도록 설정
    builder: (BuildContext context) {
      return AlertDialog(
        content:  Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(text,textAlign: TextAlign.center,),
        ),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('취소'),
            ),
            width(20),
            ElevatedButton(
              onPressed: () =>context.pop(true),
              child: const Text('삭제'),
            ),
          ],),

        ],
      );
    },
 );
}