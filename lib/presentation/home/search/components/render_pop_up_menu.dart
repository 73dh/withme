import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      children: [
        Text(label),
        PopupMenuButton<dynamic>(
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
