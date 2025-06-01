import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/color/color_style.dart';

class RenderPopUpMenu extends StatelessWidget {
  final String label;
  final List<dynamic> items;
  final void Function(dynamic) onSelect;

  const RenderPopUpMenu({
    super.key,
    required this.label,
    required this.items,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        PopupMenuButton<dynamic>(
          padding: EdgeInsets.zero, // 버튼 바깥 padding 제거
          constraints: const BoxConstraints(), // 메뉴 항목의 기본 크기 제한 제거
          child:  Icon(Icons.arrow_drop_down, size: 18,color: ColorStyles.menuButtonColor,), // 작고 간단한 버튼 UI
          itemBuilder: (context) {
            return items
                .map(
                  (e) => PopupMenuItem<dynamic>(
                    child: GestureDetector(
                      onTap: () {
                        onSelect(e);
                        context.pop();
                      },
                      child: Text(e.toString()),
                    ),
                  ),
                )
                .toList();
          },
        ),
      ],
    );
  }
}
